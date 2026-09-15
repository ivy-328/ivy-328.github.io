网站小修改补丁（直接覆盖即可）
================================

这个补丁只做两件事：
1. 顶部导航删除 Publications / 发表。
2. Work / 作品页面删除大标题下面那段多余的说明小字。

【怎么用】
1. 解压 ivy_website_patch_ready_to_copy.zip。
2. 你会看到两个文件夹：_includes 和 _data。
3. 把这两个文件夹直接拖进你的 ivy-328.github.io 项目根目录。
4. 系统询问是否覆盖同名文件时，选择“替换/覆盖”。

【还要删除的模板残留】
请在原项目里删除：
- _pages/publications.html
- _publications/  整个文件夹

其中 _publications/ 里面是 Academic Pages 模板自带的
“Paper Title Number 1 / 2 / 3 ...”示例，不是你现在 Research 页的数据。

【千万不要删】
- _data/research.yml
- _pages/research.md
- _pages/research-zh.md
- _data/portfolio_v11.yml
- _pages/work.md
- _pages/work-zh.md

这些是你现在真正的网站内容。

【说明】
Research 页面仍然保留。这里只移除单独的 Publications/发表入口和旧模板残留，
不会删除你当前 Research 页里的真实研究内容。
