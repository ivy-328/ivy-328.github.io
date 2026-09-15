# frozen_string_literal: true
# Caihang Liang · NJU Purple v1.1 patch installer
require "fileutils"
require "time"

ROOT = Dir.pwd
abort "Please run this command from the root of ivy-328.github.io (the folder containing _config.yml)." unless File.exist?(File.join(ROOT, "_config.yml"))

stamp = Time.now.strftime("%Y%m%d-%H%M%S")
backup = File.join(ROOT, "_backup_nju_v11_#{stamp}")
FileUtils.mkdir_p(backup)

def backup_file(path, backup_root)
  return unless File.exist?(path)
  rel = path.sub(Dir.pwd + File::SEPARATOR, "")
  target = File.join(backup_root, rel)
  FileUtils.mkdir_p(File.dirname(target))
  FileUtils.cp(path, target)
end

def front_matter_and_body(content)
  m = content.match(/\A(---\s*\n.*?\n---\s*\n)(.*)\z/m)
  return [m[1], m[2]] if m
  ["", content]
end

puts "Applying NJU Purple v1.1 refinement patch..."

# Back up files that this installer edits.
editable = [
  "_pages/work.md",
  "_pages/work-zh.md",
  "_pages/practice.md",
  "_pages/practice-zh.md",
  "_includes/head/custom.html"
]
editable.each { |p| backup_file(File.join(ROOT, p), backup) }

# Work: keep the existing front matter/layout, replace only body.
{
  "_pages/work.md" => '{% include nju-v11-work.html lang="en" %}',
  "_pages/work-zh.md" => '{% include nju-v11-work.html lang="zh" %}'
}.each do |rel, body|
  path = File.join(ROOT, rel)
  unless File.exist?(path)
    warn "Warning: #{rel} was not found; skipped."
    next
  end
  fm, = front_matter_and_body(File.read(path, encoding: "UTF-8"))
  File.write(path, fm + "\n" + body + "\n", encoding: "UTF-8")
  puts "Updated #{rel} (front matter preserved)."
end

# Practice: keep all existing content, append the linked-practice section once.
{
  "_pages/practice.md" => '{% include nju-v11-practice-links.html lang="en" %}',
  "_pages/practice-zh.md" => '{% include nju-v11-practice-links.html lang="zh" %}'
}.each do |rel, include_line|
  path = File.join(ROOT, rel)
  unless File.exist?(path)
    warn "Warning: #{rel} was not found; skipped."
    next
  end
  content = File.read(path, encoding: "UTF-8")
  unless content.include?("NJU-V11-PRACTICE-LINKS") || content.include?("nju-v11-practice-links.html")
    content = content.rstrip + "\n\n" + include_line + "\n"
    File.write(path, content, encoding: "UTF-8")
    puts "Appended linked practice stories to #{rel}."
  else
    puts "#{rel} already contains the v1.1 practice block; skipped duplicate."
  end
end

# Inject CSS + JS into Academic Pages' custom head include.
head = File.join(ROOT, "_includes/head/custom.html")
FileUtils.mkdir_p(File.dirname(head))
head_content = File.exist?(head) ? File.read(head, encoding: "UTF-8") : ""
marker = "<!-- NJU PURPLE V1.1 PATCH -->"
unless head_content.include?(marker)
  inject = <<~HTML

    #{marker}
    <link rel="stylesheet" href="{{ '/assets/css/nju-purple-v11.css' | relative_url }}">
    <script defer src="{{ '/assets/js/nju-purple-v11.js' | relative_url }}"></script>
  HTML
  File.write(head, head_content.rstrip + inject + "\n", encoding: "UTF-8")
  puts "Injected v1.1 CSS/JS into _includes/head/custom.html."
else
  puts "Head include already contains v1.1 assets; skipped duplicate."
end

puts
puts "Done."
puts "Backup created at: #{backup.sub(ROOT + File::SEPARATOR, '')}"
puts "Next: bundle exec jekyll serve"
