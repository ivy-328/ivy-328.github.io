require "yaml"
require "fileutils"

ROOT = Dir.pwd
STAMP = Time.now.strftime("%Y%m%d_%H%M%S")
BACKUP = File.join(ROOT, "_backup_nju_v13_#{STAMP}")

def readf(p) = File.read(p, encoding: "UTF-8")
def writef(p,s); FileUtils.mkdir_p(File.dirname(p)); File.write(p,s,encoding:"UTF-8"); end
def backup(p)
  return unless p && File.exist?(p)
  rel=p.sub(/\A#{Regexp.escape(ROOT)}[\/\\]?/,"")
  dst=File.join(BACKUP,rel); FileUtils.mkdir_p(File.dirname(dst)); FileUtils.cp(p,dst)
end
def splitfm(s)
  return ["",s] unless s.start_with?("---")
  a=s.split(/^---\s*$\n?/,3)
  a.length>=3 ? ["---\n#{a[1]}---\n",a[2]] : ["",s]
end
def permalink(p)
  fm,_=splitfm(readf(p))
  m=fm.match(/^\s*permalink\s*:\s*["']?([^"'\n]+)["']?/i)
  m && m[1].strip
rescue
  nil
end
def page(url,names)
  names.each{|n| p=File.join(ROOT,"_pages",n); return p if File.exist?(p)}
  Dir.glob(File.join(ROOT,"_pages","**","*.{md,markdown,html}")).find{|p| permalink(p)==url}
end
def val(h,*ks)
  ks.each{|k| v=h[k]||h[k.to_sym]; return v if v && v.to_s.strip!=""}
  nil
end
def img(h)=val(h,"image","cover","photo","thumbnail")
def url(h)=val(h,"url","link","href","external_url")
def ipath(v)
  s=v.to_s.strip
  return "" if s==""
  s.start_with?("/") ? s : "/#{s}"
end
def iexists(v)
  p=ipath(v); p!="" && File.exist?(File.join(ROOT,p.sub(%r{\A/},"")))
end
def blob(path,h)
  [path.join(" "),val(h,"title_zh","title_en","title","name","heading"),val(h,"organization","institution"),
   val(h,"summary_zh","summary_en","summary","description_zh","description_en","description")].compact.join(" ")
end
def records(obj,path=[],out=[])
  case obj
  when Hash
    ks=obj.keys.map(&:to_s)
    out<<[path,obj] if (ks & %w[title title_zh title_en name heading]).any? &&
                       (ks & %w[image cover photo thumbnail url link href description summary organization institution]).any?
    obj.each{|k,v| records(v,path+[k.to_s],out)}
  when Array
    obj.each_with_index{|v,i| records(v,path+[i.to_s],out)}
  end
  out
end
def all_records
  out=[]
  Dir.glob(File.join(ROOT,"_data","**","*.{yml,yaml}")).each do |p|
    begin
      d=YAML.load_file(p)
      records(d).each{|path,h| out<<[[File.basename(p)]+path,h]}
    rescue
    end
  end
  out
end

PRACTICE=/(practice|fieldwork|实习|实践|新华|交汇点|融媒体|盱眙龙虾|直播|支教|志愿|青年在.?县.?场)/i
WORK=/(work|portfolio|news|journal|comment|visual|作品|新闻|评论|视觉|报道|city不city|meme|咖啡阿姨|残疾学生)/i

# 1) Directly remove the last 3 from any 11-item work-like array.
Dir.glob(File.join(ROOT,"_data","**","*.{yml,yaml}")).each do |p|
  begin
    d=YAML.load_file(p)
  rescue
    next
  end
  changed=false
  walk=lambda do |o,path|
    case o
    when Array
      if o.length==11 && o.count{|x| x.is_a?(Hash)}>=8
        score=o.count{|x| x.is_a?(Hash) && blob(path,x).match?(WORK)}
        unless path.join(" ").match?(PRACTICE)
          if score>=3 || File.basename(p).match?(/work|portfolio/i)
            o.slice!(8,3); changed=true
          end
        end
      end
      o.each_with_index{|v,i| walk.call(v,path+[i.to_s])}
    when Hash
      o.each{|k,v| walk.call(v,path+[k.to_s])}
    end
  end
  walk.call(d,[File.basename(p)])
  if changed
    backup(p); File.write(p,d.to_yaml(line_width:-1),encoding:"UTF-8")
    puts "✓ 已直接删除 #{File.basename(p)} 中最后三个作品"
  end
end

rs=all_records

# 2) Build exactly 8 covered Work items.
cands=rs.select{|path,h| iexists(img(h)) && !blob(path,h).match?(PRACTICE) &&
  (blob(path,h).match?(WORK) || path.join(" ").match?(/work|portfolio|news/i))}
cands=rs.select{|path,h| iexists(img(h)) && path.join(" ").match?(/work|portfolio|news/i) && !blob(path,h).match?(PRACTICE)} if cands.length<8
seen={}; works=[]
cands.each do |path,h|
  key=[url(h),val(h,"title_zh","title_en","title","name"),ipath(img(h))].join("|")
  next if seen[key]; seen[key]=1
  works<<{
    "title_zh"=>(val(h,"title_zh","title","name","title_en")||"新闻作品").to_s,
    "title_en"=>(val(h,"title_en","title","name","title_zh")||"Journalism Work").to_s,
    "summary_zh"=>val(h,"summary_zh","description_zh","summary","description").to_s,
    "summary_en"=>val(h,"summary_en","description_en","summary","description").to_s,
    "image"=>ipath(img(h)),"url"=>url(h).to_s}
end
works=works.first(8)
writef(File.join(ROOT,"_data","work_v13.yml"),works.to_yaml(line_width:-1))
puts "✓ Work 现在固定只显示 #{works.length} 个有封面的作品"

# 3) Merge Xinhua and county media: one card each, taking image and URL from duplicate records.
def merged(rs,rx,zh,en,meta_zh,meta_en,desc_zh,desc_en,fallback_url="")
  hits=rs.select{|path,h| blob(path,h).match?(rx)}
  im=hits.find{|path,h| iexists(img(h))}
  lk=hits.find{|path,h| url(h).to_s.strip!=""}
  {"title_zh"=>zh,"title_en"=>en,"meta_zh"=>meta_zh,"meta_en"=>meta_en,
   "description_zh"=>desc_zh,"description_en"=>desc_en,
   "image"=>im ? ipath(img(im[1])) : "",
   "url"=>lk ? url(lk[1]).to_s : fallback_url}
end

xinhua=merged(rs,/(新华|交汇点|xhby|xinhua|jiaohui)/i,
  "新华日报 · 视觉新闻实践","Xinhua Daily · Visual Journalism Practice",
  "2024.01–2024.03 · 视觉中心 · 新闻记者实习生","Jan–Mar 2024 · Visual Center · Journalism Intern",
  "参与选题策划、采访联络、现场采访、视频主持与影像采集；作品发表于《新华日报》、交汇点 App 与视觉江苏等平台。",
  "Worked on story planning, interview coordination, on-site reporting, video hosting and visual production.",
  "https://xh.xhby.net/pad/con/202402/23/content_1298479.html")

county=merged(rs,/(县级融媒|融媒体中心|盱眙发布|county media|media center)/i,
  "盱眙县融媒体中心 · 县级融媒实践","Xuyi County Media Center · County-level Converged Media",
  "2023.01–2023.03 · 采访部 · 新闻记者实习生","Jan–Mar 2023 · Reporting Desk · Journalism Intern",
  "参与新闻采编、内容制作与拍摄，报道基层故事，并参与县级融媒平台内容生产。",
  "Participated in reporting, editing, content production and field photography for county-level converged media.")

others=[]; seen={}
rs.each do |path,h|
  b=blob(path,h)
  next unless b.match?(PRACTICE) && iexists(img(h))
  next if b.match?(/新华|交汇点|xhby|xinhua|jiaohui|县级融媒|融媒体中心|盱眙发布|county media|media center/i)
  k=[val(h,"title_zh","title","name","title_en"),ipath(img(h))].join("|")
  next if seen[k]; seen[k]=1
  others<<{"title_zh"=>val(h,"title_zh","title","name","title_en").to_s,
           "title_en"=>val(h,"title_en","title","name","title_zh").to_s,
           "meta_zh"=>val(h,"date","period","role").to_s,
           "meta_en"=>val(h,"date","period","role").to_s,
           "description_zh"=>val(h,"summary_zh","description_zh","summary","description").to_s,
           "description_en"=>val(h,"summary_en","description_en","summary","description").to_s,
           "image"=>ipath(img(h)),"url"=>url(h).to_s}
end
others=others.first(4)
writef(File.join(ROOT,"_data","practice_v13.yml"),{"featured"=>[xinhua,county],"other"=>others}.to_yaml(line_width:-1))
puts "✓ 新华日报只保留一个合并卡；县级融媒体只保留一个合并卡"

STYLE=<<~'CSS'
<style>
.v13{width:min(1160px,calc(100% - 48px));margin:auto;padding:64px 0 96px}
.v13head{max-width:860px;margin-bottom:36px}.v13k{font-size:14px;font-weight:800;letter-spacing:.14em;color:#4d0099}
.v13head h1{margin:12px 0 14px;color:#351064;font-size:clamp(42px,5vw,72px);line-height:1}
.v13head p{margin:0;color:#766e7a;font-size:18px;line-height:1.7}
.v13works{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:24px}
.v13card{overflow:hidden;border:1px solid rgba(77,0,153,.13);border-radius:18px;background:#fff;box-shadow:0 10px 26px rgba(55,16,95,.05)}
.v13card>a{display:block;color:inherit!important;text-decoration:none!important}
.v13cover{aspect-ratio:16/10;overflow:hidden;background:#eee8f2}.v13cover img{width:100%;height:100%;object-fit:cover;display:block}
.v13copy{padding:16px 17px 18px}.v13copy h2{margin:0;color:#351064;font-size:19px;line-height:1.38}
.v13copy p{margin:8px 0 0;color:#766d7b;font-size:14px;line-height:1.6}
.v13link{display:inline!important;width:auto!important;min-width:0!important;min-height:0!important;margin-top:12px;padding:0!important;border:0!important;background:none!important;color:#4d0099!important;font-size:13px!important;font-weight:750;text-decoration:none!important}
.v13practice{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:28px}
.v13practice .v13card .v13cover{aspect-ratio:16/9}.v13meta{color:#4d0099;font-size:12px;font-weight:800}
.v13practice h2{font-size:24px!important;margin:8px 0 10px!important}.v13more{margin-top:42px;padding-top:28px;border-top:1px solid rgba(77,0,153,.13)}
.v13mini{display:grid;grid-template-columns:140px 1fr;overflow:hidden;border:1px solid rgba(77,0,153,.11);border-radius:16px;background:#fff}
.v13mini .v13cover{aspect-ratio:auto;min-height:145px}.v13mini .v13copy{padding:14px}.v13mini h3{margin:6px 0 8px;color:#351064;font-size:17px}
@media(max-width:920px){.v13works{grid-template-columns:repeat(2,1fr)}.v13practice{grid-template-columns:1fr}}
@media(max-width:640px){.v13{width:calc(100% - 24px);padding:42px 0 70px}.v13works{grid-template-columns:1fr}.v13mini{grid-template-columns:1fr}.v13mini .v13cover{aspect-ratio:16/9;min-height:0}}
</style>
CSS

def work_body(lang,style)
  zh=lang=="zh"
  style+%Q{
<div class="v13">
<header class="v13head"><div class="v13k">#{zh ? "作品 / WORK" : "WORK / 作品"}</div><h1>#{zh ? "精选新闻作品" : "Selected Journalism Works"}</h1><p>#{zh ? "新闻、评论与视觉报道。" : "Journalism, commentary, and visual reporting."}</p></header>
<div class="v13works">
{% for item in site.data.work_v13 %}
<article class="v13card">{% if item.url and item.url != "" %}<a href="{{ item.url }}" target="_blank" rel="noopener noreferrer">{% endif %}
<div class="v13cover"><img src="{{ item.image | relative_url }}" alt="" loading="lazy"></div>
<div class="v13copy"><h2>{{ item.title_#{zh ? "zh" : "en"} }}</h2>{% if item.summary_#{zh ? "zh" : "en"} and item.summary_#{zh ? "zh" : "en"} != "" %}<p>{{ item.summary_#{zh ? "zh" : "en"} }}</p>{% endif %}{% if item.url and item.url != "" %}<span class="v13link">#{zh ? "查看原文" : "View original"} ↗</span>{% endif %}</div>
{% if item.url and item.url != "" %}</a>{% endif %}</article>
{% endfor %}
</div></div>}
end

def practice_body(lang,style)
  zh=lang=="zh"
  style+%Q{
<div class="v13">
<header class="v13head"><div class="v13k">#{zh ? "田野与实践 / FIELDWORK & PRACTICE" : "FIELDWORK & PRACTICE / 田野与实践"}</div><h1>#{zh ? "在现场" : "In the Field"}</h1><p>#{zh ? "同一段经历只保留一个入口：照片作为封面，相关报道只放在同一张卡片里。" : "One entry per experience: the photo is the cover, and related reporting stays inside the same card."}</p></header>
<div class="v13practice">
{% for item in site.data.practice_v13.featured %}
<article class="v13card">{% if item.image and item.image != "" %}<div class="v13cover"><img src="{{ item.image | relative_url }}" alt="" loading="lazy"></div>{% endif %}
<div class="v13copy"><div class="v13meta">{{ item.meta_#{zh ? "zh" : "en"} }}</div><h2>{{ item.title_#{zh ? "zh" : "en"} }}</h2><p>{{ item.description_#{zh ? "zh" : "en"} }}</p>{% if item.url and item.url != "" %}<a class="v13link" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">#{zh ? "相关报道" : "Related story"} ↗</a>{% endif %}</div></article>
{% endfor %}
</div>
{% if site.data.practice_v13.other and site.data.practice_v13.other.size > 0 %}
<div class="v13more"><div class="v13k">#{zh ? "更多实践 / MORE" : "MORE FIELD NOTES / 更多实践"}</div>
<div class="v13practice">{% for item in site.data.practice_v13.other %}<article class="v13mini"><div class="v13cover"><img src="{{ item.image | relative_url }}" alt="" loading="lazy"></div><div class="v13copy"><div class="v13meta">{{ item.meta_#{zh ? "zh" : "en"} }}</div><h3>{{ item.title_#{zh ? "zh" : "en"} }}</h3>{% if item.url and item.url != "" %}<a class="v13link" href="{{ item.url }}" target="_blank" rel="noopener noreferrer">#{zh ? "查看相关内容" : "View related content"} ↗</a>{% endif %}</div></article>{% endfor %}</div></div>{% endif %}
</div>}
end

{
  "/work/"=>[["work.md"],work_body("en",STYLE)],
  "/zh/work/"=>[["work-zh.md"],work_body("zh",STYLE)],
  "/practice/"=>[["practice.md","fieldwork.md"],practice_body("en",STYLE)],
  "/zh/practice/"=>[["practice-zh.md","fieldwork-zh.md"],practice_body("zh",STYLE)]
}.each do |u,(names,body)|
  p=page(u,names)
  if p
    fm,_=splitfm(readf(p)); backup(p); writef(p,fm+"\n"+body); puts "✓ 强制替换 #{u}"
  else
    puts "⚠ 未找到 #{u} 页面"
  end
end

puts
puts "完成：1) 卡片缩小；2) 最后三个作品删除；3) 新华日报/县级融媒体各只保留一个。"
puts "备份：#{BACKUP}"
puts "现在运行：bundle exec jekyll serve"
