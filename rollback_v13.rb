# frozen_string_literal: true
require "fileutils"

root = Dir.pwd
backups = Dir.glob(File.join(root, "_backup_nju_v13_*")).select { |p| File.directory?(p) }.sort

if backups.empty?
  puts "没有找到 _backup_nju_v13_* 备份目录。"
  puts "如果你还没有运行 v1.3，不需要回滚，直接继续使用上一版即可。"
  exit 1
end

src = backups.last
puts "正在从备份恢复：#{File.basename(src)}"

Dir.glob(File.join(src, "**", "*"), File::FNM_DOTMATCH).each do |path|
  next if [".", ".."].include?(File.basename(path))
  next if File.directory?(path)

  rel = path.sub(/\A#{Regexp.escape(src)}[\/\\]?/, "")
  dest = File.join(root, rel)
  FileUtils.mkdir_p(File.dirname(dest))
  FileUtils.cp(path, dest)
  puts "恢复 #{rel}"
end

# Remove v1.3-only generated data files so they cannot accidentally be used later.
[
  File.join(root, "_data", "work_v13.yml"),
  File.join(root, "_data", "practice_v13.yml")
].each do |path|
  if File.exist?(path)
    File.delete(path)
    puts "删除 v1.3 临时文件 #{path.sub(root + File::SEPARATOR, '')}"
  end
end

puts
puts "回滚完成。现在请重新运行："
puts "bundle exec jekyll serve"
puts "然后浏览器按 Ctrl + F5。"
