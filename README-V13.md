# NJU Purple v1.3 HARD FIX

这版不再用“叠加 CSS”的方式，而是直接替换 Work / Practice 页面正文，并处理原始 YAML。

执行：

```bash
cd /d/git_projects/ivy-328.github.io
ruby apply_v13_hard_fix.rb
bundle exec jekyll serve
```

然后按 `Ctrl + F5`，重点检查 `/work/`、`/zh/work/`、`/practice/`、`/zh/practice/`。

修改内容：
1. Work 卡片桌面端改为 3 列小卡，不再占满整个画幅。
2. 原作品列表如果是 11 项，直接删除第 9–11 项；新 Work 页也最多只显示 8 个有封面的作品。
3. 新华日报和县级融媒体各只保留一个合并卡：照片作为封面，链接只作为卡片里的小文字链接，不再出现上下重复。
4. 自动备份到 `_backup_nju_v13_时间/`。
