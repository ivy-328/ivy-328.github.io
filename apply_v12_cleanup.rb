# frozen_string_literal: true

require "yaml"
require "fileutils"
require "time"

ROOT = Dir.pwd
STAMP = Time.now.strftime("%Y%m%d_%H%M%S")
BACKUP_ROOT = File.join(ROOT, "_backup_nju_v12_#{STAMP}")

def say(msg)
  puts msg
end

def read_text(path)
  File.read(path, encoding: "UTF-8")
end

def write_text(path, text)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, text, mode: "w", encoding: "UTF-8")
end

def backup(path)
  return unless File.exist?(path)
  rel = path.sub(/\A#{Regexp.escape(ROOT)}[\/\\]?/, "")
  dest = File.join(BACKUP_ROOT, rel)
  FileUtils.mkdir_p(File.dirname(dest))
  FileUtils.cp(path, dest)
end

def split_front_matter(text)
  if text.start_with?("---")
    parts = text.split(/^---\s*$\n?/, 3)
    if parts.length >= 3
      return ["---\n#{parts[1]}---\n", parts[2]]
    end
  end
  ["", text]
end

def permalink_from(text)
  fm, = split_front_matter(text)
  m = fm.match(/^\s*permalink\s*:\s*["']?([^"'\n]+)["']?\s*$/i)
  m ? m[1].strip : nil
end

def page_for_permalink(permalink)
  Dir.glob(File.join(ROOT, "_pages", "**", "*.{md,markdown,html}")).find do |path|
    begin
      permalink_from(read_text(path)) == permalink
    rescue
      false
    end
  end
end

def append_stylesheet
  custom = File.join(ROOT, "_includes", "head", "custom.html")
  return unless File.exist?(custom)
  line = %q{<link rel="stylesheet" href="{{ '/assets/css/nju-v12-cleanup.css' | relative_url }}">}
  txt = read_text(custom)
  return if txt.include?("nju-v12-cleanup.css")
  backup(custom)
  txt << "\n" unless txt.end_with?("\n")
  txt << "#{line}\n"
  write_text(custom, txt)
  say "✓ 已把 v1.2 样式表接入 head/custom.html"
end

def remove_html_section_containing(body, phrase)
  idx = body.index(phrase)
  return [body, false] unless idx

  start_idx = body.rindex(/<section\b/i, idx)
  end_match = body.match(/<\/section\s*>/i, idx)

  if start_idx && end_match
    finish = end_match.end(0)
    return [body[0...start_idx] + body[finish..], true]
  end

  # Fallback: remove a markdown/HTML heading block until the next major heading.
  lines = body.lines
  line_idx = lines.index { |l| l.include?(phrase) }
  return [body, false] unless line_idx

  start_line = line_idx
  while start_line > 0
    l = lines[start_line]
    break if l.match?(/^\s{0,3}#{1,3}\s+/) || l.match?(/<h[1-3]\b/i)
    start_line -= 1
  end

  finish_line = line_idx + 1
  while finish_line < lines.length
    l = lines[finish_line]
    break if finish_line > line_idx + 1 && (l.match?(/^\s{0,3}#{1,3}\s+/) || l.match?(/<h[1-3]\b/i))
    finish_line += 1
  end

  lines.slice!(start_line...finish_line)
  [lines.join, true]
end

def clean_homepage(permalink, phrases)
  path = page_for_permalink(permalink)
  unless path
    say "⚠ 未找到首页 #{permalink}，跳过首页清理。"
    return
  end

  txt = read_text(path)
  fm, body = split_front_matter(txt)
  changed = false

  phrases.each do |phrase|
    body, hit = remove_html_section_containing(body, phrase)
    changed ||= hit
  end

  # Remove leftover explanatory sentence if a container was unusual.
  leftovers = [
    "这里仅保留新闻、评论与视觉报道。社会实践已经移至“田野与实践”页面，让作品与经历各归其位。",
    "这里仅保留新闻、评论与视觉报道。社会实践已经移至“田野与实践”页面，让作品与经历各归其位",
    "This page keeps only journalism, commentary, and visual reporting. Social practice has moved to Fieldwork & Practice."
  ]
  leftovers.each do |s|
    if body.include?(s)
      body = body.gsub(s, "")
      changed = true
    end
  end

  if changed
    backup(path)
    write_text(path, fm + body)
    say "✓ 已从首页 #{permalink} 移除误放的 Work/精选新闻作品大区块"
  else
    say "• 首页 #{permalink} 未发现误放区块（可能你已经手动删过）"
  end
end

def load_yaml(path)
  return nil unless File.exist?(path)
  YAML.load_file(path)
rescue => e
  say "⚠ 无法读取 #{path}: #{e.message}"
  nil
end

def collect_records(obj, path = [], out = [])
  case obj
  when Hash
    keys = obj.keys.map(&:to_s)
    looks_like_record =
      (keys & %w[title title_zh title_en name heading]).any? &&
      (keys & %w[image cover url link href role date period organization institution]).any?
    out << [path, obj] if looks_like_record
    obj.each { |k, v| collect_records(v, path + [k.to_s], out) }
  when Array
    obj.each_with_index { |v, i| collect_records(v, path + [i.to_s], out) }
  end
  out
end

def val(h, *keys)
  keys.each do |k|
    v = h[k] || h[k.to_s] || h[k.to_sym]
    return v if !v.nil? && v.to_s.strip != ""
  end
  nil
end

def title_blob(path, h)
  [
    path.join(" "),
    val(h, "title_zh", "title_en", "title", "name", "heading"),
    val(h, "organization", "institution"),
    val(h, "summary_zh", "summary_en", "summary", "description_zh", "description_en", "description"),
    val(h, "category", "type")
  ].compact.join(" ")
end

def image_of(h)
  val(h, "image", "cover", "thumbnail", "photo")
end

def url_of(h)
  val(h, "url", "link", "href", "external_url")
end

def normalize_image(p)
  return "" if p.nil?
  p = p.to_s.strip
  return "" if p.empty?
  p.start_with?("/") ? p : "/#{p}"
end

def image_exists?(p)
  return false if p.nil? || p.to_s.strip.empty?
  rel = p.to_s.sub(%r{\A/}, "")
  File.exist?(File.join(ROOT, rel))
end

def first_existing_image(records, regexes)
  scored = records.map do |path, h|
    img = image_of(h)
    next unless image_exists?(img)
    blob = title_blob(path, h)
    score = regexes.sum { |rx| blob.match?(rx) ? 10 : 0 }
    score += 3 if url_of(h)
    [score, normalize_image(img), url_of(h), h, blob]
  end.compact.select { |x| x[0] > 0 }
  scored.max_by { |x| x[0] }
end

def find_image_by_filename(regexes)
  files = Dir.glob(File.join(ROOT, "images", "**", "*")).select do |p|
    File.file?(p) && p.match?(/\.(jpe?g|png|webp)$/i)
  end
  scored = files.map do |p|
    base = File.basename(p)
    score = regexes.sum { |rx| base.match?(rx) ? 10 : 0 }
    [score, "/" + p.sub(/\A#{Regexp.escape(ROOT)}[\/\\]?/, "").tr("\\", "/")]
  end.select { |x| x[0] > 0 }
  scored.max_by { |x| x[0] }&.last
end

PRACTICE_RX = /(practice|fieldwork|intern|实习|实践|新华|交汇点|融媒体|盱眙龙虾|支教|志愿|county stage|青年在.?县.?场)/i
WORK_RX = /(work|news|journal|comment|visual|作品|新闻|评论|视觉|报道)/i

portfolio_path = File.join(ROOT, "_data", "portfolio_v11.yml")
works_path = File.join(ROOT, "_data", "works.yml")
experience_path = File.join(ROOT, "_data", "experience.yml")

portfolio_data = load_yaml(portfolio_path)
works_data = load_yaml(works_path)
experience_data = load_yaml(experience_path)

records = []
records.concat(collect_records(portfolio_data)) if portfolio_data
records.concat(collect_records(works_data)) if works_data
records.uniq! { |path, h| [path.join("/"), h.object_id] }

# Build a clean Work dataset:
covered = records.select { |path, h| image_exists?(image_of(h)) }
work_candidates = covered.select do |path, h|
  blob = title_blob(path, h)
  !blob.match?(PRACTICE_RX) && (blob.match?(WORK_RX) || path.join(" ").match?(/work|news|portfolio/i))
end

if work_candidates.length < 5
  work_candidates = covered.reject { |path, h| title_blob(path, h).match?(PRACTICE_RX) }
end

# Deduplicate by URL/title and keep the intended covered works only.
seen = {}
work_items = []
work_candidates.each do |path, h|
  key = (url_of(h) || val(h, "title_zh", "title_en", "title", "name") || path.join("/")).to_s
  next if seen[key]
  seen[key] = true
  work_items << {
    "title_zh" => (val(h, "title_zh", "title", "name") || val(h, "title_en") || "新闻作品").to_s,
    "title_en" => (val(h, "title_en", "title", "name") || val(h, "title_zh") || "Journalism Work").to_s,
    "summary_zh" => (val(h, "summary_zh", "description_zh", "summary", "description") || "").to_s,
    "summary_en" => (val(h, "summary_en", "description_en", "summary", "description") || "").to_s,
    "image" => normalize_image(image_of(h)),
    "url" => (url_of(h) || "").to_s
  }
end

# The v1.1 page had 11 works: 8 with covers + 3 without covers.
# Rendering only covered records removes the last 3 unattractive no-cover items.
work_items = work_items.first(8) if work_items.length > 8

work_out = File.join(ROOT, "_data", "work_v12.yml")
backup(work_out)
FileUtils.mkdir_p(File.dirname(work_out))
File.write(work_out, work_items.to_yaml(line_width: -1), encoding: "UTF-8")
say "✓ Work 已整理为 #{work_items.length} 个有封面的作品；无封面的作品不会再显示"

# Practice image/link detection, using existing v1.1 data first.
practice_records = records.select { |path, h| title_blob(path, h).match?(PRACTICE_RX) }

xinhua_match = first_existing_image(practice_records, [/新华/i, /交汇点/i, /xhby/i, /visual center/i])
county_match = first_existing_image(practice_records, [/县级融媒/i, /融媒体/i, /盱眙发布/i, /county media/i])
lobster_match = first_existing_image(practice_records, [/龙虾/i, /livestream/i, /直播/i, /xuyi lobster/i])
bozhou_match = first_existing_image(practice_records, [/亳州/i, /bozhou/i, /支教/i, /teaching/i])
county_stage_match = first_existing_image(practice_records, [/青年在.?县.?场/i, /county stage/i])
community_match = first_existing_image(practice_records, [/志愿/i, /community/i])

xinhua_image = xinhua_match&.[](1) || find_image_by_filename([/xinhua/i, /jiaohui/i, /news[-_]?0?7/i, /work[-_]?0?7/i])
county_image = county_match&.[](1) || find_image_by_filename([/county.*media/i, /rongmei/i, /media.*center/i, /practice.*0?9/i, /work.*0?9/i])
lobster_image = lobster_match&.[](1) || find_image_by_filename([/xuyi.*livestream/i, /lobster/i, /livestream/i])
bozhou_image = bozhou_match&.[](1) || find_image_by_filename([/bozhou/i, /teaching/i])
county_stage_image = county_stage_match&.[](1) || find_image_by_filename([/county.*stage/i, /youth.*county/i])
community_image = community_match&.[](1) || find_image_by_filename([/community/i, /volunteer/i])

# Prefer a known XHBY report link for the Xinhua card if the current dataset does not expose it.
xinhua_url = xinhua_match&.[](2).to_s
if xinhua_url.empty?
  rec = records.find { |path, h| url_of(h).to_s.include?("xh.xhby.net/pad/con/202402/23/content_1298479") }
  xinhua_url = url_of(rec[1]).to_s if rec
end
xinhua_url = "https://xh.xhby.net/pad/con/202402/23/content_1298479.html" if xinhua_url.empty?

county_url = county_match&.[](2).to_s
lobster_url = lobster_match&.[](2).to_s
county_stage_url = county_stage_match&.[](2).to_s
community_url = community_match&.[](2).to_s

practice = {
  "featured" => [
    {
      "id" => "xinhua",
      "title_zh" => "新华日报 · 视觉新闻实践",
      "title_en" => "Xinhua Daily · Visual Journalism Practice",
      "meta_zh" => "2024.01–2024.03 · 视觉中心 · 新闻记者实习生",
      "meta_en" => "Jan–Mar 2024 · Visual Center · Journalism Intern",
      "description_zh" => "参与选题策划、采访联络、现场采访、视频主持与影像采集；作品发表于《新华日报》、交汇点 App 与视觉江苏等平台。",
      "description_en" => "Worked on story planning, interview coordination, on-site reporting, video hosting and visual production, with work published across Xinhua Daily, JiaoHuiDian and Visual Jiangsu.",
      "image" => xinhua_image.to_s,
      "url" => xinhua_url
    },
    {
      "id" => "county-media",
      "title_zh" => "盱眙县融媒体中心 · 县级融媒实践",
      "title_en" => "Xuyi County Media Center · County-level Converged Media",
      "meta_zh" => "2023.01–2023.03 · 采访部 · 新闻记者实习生",
      "meta_en" => "Jan–Mar 2023 · Reporting Desk · Journalism Intern",
      "description_zh" => "参与新闻采编、内容制作与拍摄，报道基层故事，并在“盱眙发布”等县级融媒平台参与内容生产。",
      "description_en" => "Participated in reporting, editing, content production and field photography, covering local stories for county-level converged media channels.",
      "image" => county_image.to_s,
      "url" => county_url
    }
  ],
  "compact" => [
    {
      "id" => "lobster",
      "title_zh" => "盱眙龙虾 · 直播与“数商兴农”",
      "title_en" => "Xuyi Lobster · Livestream & Digital Commerce",
      "meta_zh" => "2023.07–2023.09 · 直播运营实习",
      "meta_en" => "Jul–Sep 2023 · Livestream Operations",
      "description_zh" => "主持抖音直播20余场，并参与“数商兴农”调研与特色农产品新媒体传播。",
      "description_en" => "Hosted 20+ Douyin livestream sessions and participated in research on digital commerce for agricultural products.",
      "image" => lobster_image.to_s,
      "url" => lobster_url
    },
    {
      "id" => "bozhou",
      "title_zh" => "安徽亳州 · 支教与社会实践",
      "title_en" => "Bozhou, Anhui · Teaching Support",
      "meta_zh" => "社会实践 / 田野经历",
      "meta_en" => "Social Practice / Field Experience",
      "description_zh" => "以教学支持与基层观察为主的社会实践经历。",
      "description_en" => "A field experience centered on teaching support and community observation.",
      "image" => bozhou_image.to_s,
      "url" => ""
    },
    {
      "id" => "county-stage",
      "title_zh" => "青年在“县”场 · 县域观察",
      "title_en" => "Youth on the County Stage · County-level Observation",
      "meta_zh" => "县域农业与地方传播实践",
      "meta_en" => "County Development & Local Communication",
      "description_zh" => "围绕县域产业、地方传播与青年观察展开的实践记录。",
      "description_en" => "Field-based observation of county industries, local communication and youth participation.",
      "image" => county_stage_image.to_s,
      "url" => county_stage_url
    },
    {
      "id" => "community",
      "title_zh" => "社区服务 · 志愿实践",
      "title_en" => "Community Service · Volunteer Practice",
      "meta_zh" => "志愿与公共服务",
      "meta_en" => "Volunteer & Public Service",
      "description_zh" => "以社区服务与公共参与为核心的志愿实践记录。",
      "description_en" => "Volunteer practice focused on community service and public engagement.",
      "image" => community_image.to_s,
      "url" => community_url
    }
  ]
}

practice_out = File.join(ROOT, "_data", "practice_v12.yml")
backup(practice_out)
File.write(practice_out, practice.to_yaml(line_width: -1), encoding: "UTF-8")
say "✓ Practice 已改成“经历 + 封面 + 链接”一体化结构，不再把同一经历拆成上下两个重复卡片"
say "  新华日报封面: #{xinhua_image && xinhua_image != "" ? xinhua_image : "⚠ 未自动识别"}"
say "  县级融媒体封面: #{county_image && county_image != "" ? county_image : "⚠ 未自动识别"}"

work_zh = <<~'LIQUID'
<div class="v12-page v12-work-page">
  <header class="v12-page-head">
    <div class="v12-kicker">作品 / WORK</div>
    <h1>精选新闻作品</h1>
    <p>新闻、评论与视觉报道。</p>
  </header>

  <div class="v12-work-grid">
    {% for item in site.data.work_v12 %}
      <article class="v12-work-card">
        {% if item.url and item.url != "" %}
        <a class="v12-card-link" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">
        {% endif %}
          <div class="v12-work-cover">
            <img src="{{ item.image | relative_url }}" alt="{{ item.title_zh | escape }}" loading="lazy">
          </div>
          <div class="v12-work-copy">
            <h2>{{ item.title_zh }}</h2>
            {% if item.summary_zh and item.summary_zh != "" %}<p>{{ item.summary_zh }}</p>{% endif %}
            {% if item.url and item.url != "" %}<span class="v12-inline-link">查看原文 <span aria-hidden="true">↗</span></span>{% endif %}
          </div>
        {% if item.url and item.url != "" %}
        </a>
        {% endif %}
      </article>
    {% endfor %}
  </div>
</div>
LIQUID

work_en = <<~'LIQUID'
<div class="v12-page v12-work-page">
  <header class="v12-page-head">
    <div class="v12-kicker">WORK / 作品</div>
    <h1>Selected Journalism Works</h1>
    <p>Journalism, commentary, and visual reporting.</p>
  </header>

  <div class="v12-work-grid">
    {% for item in site.data.work_v12 %}
      <article class="v12-work-card">
        {% if item.url and item.url != "" %}
        <a class="v12-card-link" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">
        {% endif %}
          <div class="v12-work-cover">
            <img src="{{ item.image | relative_url }}" alt="{{ item.title_en | escape }}" loading="lazy">
          </div>
          <div class="v12-work-copy">
            <h2>{{ item.title_en }}</h2>
            {% if item.summary_en and item.summary_en != "" %}<p>{{ item.summary_en }}</p>{% endif %}
            {% if item.url and item.url != "" %}<span class="v12-inline-link">View original <span aria-hidden="true">↗</span></span>{% endif %}
          </div>
        {% if item.url and item.url != "" %}
        </a>
        {% endif %}
      </article>
    {% endfor %}
  </div>
</div>
LIQUID

practice_zh = <<~'LIQUID'
<div class="v12-page v12-practice-page">
  <header class="v12-page-head">
    <div class="v12-kicker">田野与实践 / FIELDWORK & PRACTICE</div>
    <h1>在现场</h1>
    <p>把媒体实践、县域观察与社会实践放回具体的现场中呈现。</p>
  </header>

  <section class="v12-practice-featured">
    {% for item in site.data.practice_v12.featured %}
      <article class="v12-practice-feature-card">
        {% if item.image and item.image != "" %}
          <div class="v12-practice-cover">
            <img src="{{ item.image | relative_url }}" alt="{{ item.title_zh | escape }}" loading="lazy">
          </div>
        {% endif %}
        <div class="v12-practice-copy">
          <div class="v12-practice-meta">{{ item.meta_zh }}</div>
          <h2>{{ item.title_zh }}</h2>
          <p>{{ item.description_zh }}</p>
          {% if item.url and item.url != "" %}
            <a class="v12-small-button" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">相关报道 <span aria-hidden="true">↗</span></a>
          {% endif %}
        </div>
      </article>
    {% endfor %}
  </section>

  <section class="v12-practice-more">
    <div class="v12-section-label">更多实践 / MORE FIELD NOTES</div>
    <div class="v12-compact-grid">
      {% for item in site.data.practice_v12.compact %}
        <article class="v12-compact-card">
          {% if item.image and item.image != "" %}
            <div class="v12-compact-cover"><img src="{{ item.image | relative_url }}" alt="{{ item.title_zh | escape }}" loading="lazy"></div>
          {% endif %}
          <div class="v12-compact-copy">
            <div class="v12-practice-meta">{{ item.meta_zh }}</div>
            <h3>{{ item.title_zh }}</h3>
            <p>{{ item.description_zh }}</p>
            {% if item.url and item.url != "" %}
              <a class="v12-text-link" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">查看相关内容 ↗</a>
            {% endif %}
          </div>
        </article>
      {% endfor %}
    </div>
  </section>
</div>
LIQUID

practice_en = <<~'LIQUID'
<div class="v12-page v12-practice-page">
  <header class="v12-page-head">
    <div class="v12-kicker">FIELDWORK & PRACTICE / 田野与实践</div>
    <h1>In the Field</h1>
    <p>Media practice, county-level observation, and social practice presented as situated experiences rather than separate link cards.</p>
  </header>

  <section class="v12-practice-featured">
    {% for item in site.data.practice_v12.featured %}
      <article class="v12-practice-feature-card">
        {% if item.image and item.image != "" %}
          <div class="v12-practice-cover">
            <img src="{{ item.image | relative_url }}" alt="{{ item.title_en | escape }}" loading="lazy">
          </div>
        {% endif %}
        <div class="v12-practice-copy">
          <div class="v12-practice-meta">{{ item.meta_en }}</div>
          <h2>{{ item.title_en }}</h2>
          <p>{{ item.description_en }}</p>
          {% if item.url and item.url != "" %}
            <a class="v12-small-button" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">Related story <span aria-hidden="true">↗</span></a>
          {% endif %}
        </div>
      </article>
    {% endfor %}
  </section>

  <section class="v12-practice-more">
    <div class="v12-section-label">MORE FIELD NOTES / 更多实践</div>
    <div class="v12-compact-grid">
      {% for item in site.data.practice_v12.compact %}
        <article class="v12-compact-card">
          {% if item.image and item.image != "" %}
            <div class="v12-compact-cover"><img src="{{ item.image | relative_url }}" alt="{{ item.title_en | escape }}" loading="lazy"></div>
          {% endif %}
          <div class="v12-compact-copy">
            <div class="v12-practice-meta">{{ item.meta_en }}</div>
            <h3>{{ item.title_en }}</h3>
            <p>{{ item.description_en }}</p>
            {% if item.url and item.url != "" %}
              <a class="v12-text-link" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">View related content ↗</a>
            {% endif %}
          </div>
        </article>
      {% endfor %}
    </div>
  </section>
</div>
LIQUID

def replace_body_for_permalink(permalink, body)
  path = page_for_permalink(permalink)
  unless path
    say "⚠ 未找到 #{permalink} 对应页面，未覆盖。"
    return
  end
  txt = read_text(path)
  fm, = split_front_matter(txt)
  backup(path)
  write_text(path, fm + "\n" + body)
  say "✓ 已重排 #{permalink}"
end

# Clean the accidental Work section from the homepage.
clean_homepage("/", ["精选新闻作品", "Selected Journalism Works", "Selected Works"])
clean_homepage("/zh/", ["精选新闻作品", "Selected Journalism Works", "Selected Works"])

# Replace Work and Practice bodies while preserving each page's original front matter/layout.
replace_body_for_permalink("/work/", work_en)
replace_body_for_permalink("/zh/work/", work_zh)
replace_body_for_permalink("/practice/", practice_en)
replace_body_for_permalink("/zh/practice/", practice_zh)

append_stylesheet

say ""
say "==================== v1.2 完成 ===================="
say "备份目录：#{BACKUP_ROOT}"
say "接下来运行：bundle exec jekyll serve"
say "重点检查：/、/zh/、/work/、/zh/work/、/practice/、/zh/practice/"
say "如果样式仍是旧缓存，请按 Ctrl + F5。"
say "===================================================="
