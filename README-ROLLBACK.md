# 回滚 NJU Purple v1.3

如果你已经运行过 `apply_v13_hard_fix.rb`，把这个包解压到网站仓库根目录：

```text
D:\git_projects\ivy-328.github.io
```

然后在 Git Bash 运行：

```bash
cd /d/git_projects/ivy-328.github.io
ruby rollback_v13.rb
bundle exec jekyll serve
```

脚本会自动找到最近的 `_backup_nju_v13_*` 备份并把 v1.3 修改过的原文件恢复回来，同时删除 v1.3 新增的临时数据文件。

如果你根本没有运行过 v1.3，就不需要运行这个回滚脚本。
