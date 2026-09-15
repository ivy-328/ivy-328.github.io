使用方法
========

这个压缩包只有一个独立页面：

update/index.html

它不会修改你的主页、导航栏、Research、Work 或其他现有页面。

上线步骤：

1. 解压 ZIP。
2. 把整个 update 文件夹复制到你的 ivy-328.github.io 项目根目录。
3. 最终结构应该是：

ivy-328.github.io/
├─ update/
│  └─ index.html
├─ _data/
├─ _pages/
├─ _includes/
└─ ...

4. 在 Git Bash 中运行：

cd /d/git_projects/ivy-328.github.io
git status
git add -A
git commit -m "Add website update guide"
git push origin master

5. GitHub Pages 部署完成后访问：

https://ivy-328.github.io/update/

这个页面完全独立，不需要加入主页导航。如果只把链接交给老师，也可以直接使用上面的 URL。
