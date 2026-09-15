# Caihang Liang · NJU Purple v1.1 Patch

This patch is for the **existing NJU Purple v1 / Academic Pages + Jekyll repository**.

## What this patch changes

1. Chinese Hero becomes two deliberate lines:
   - `你好`
   - `我是梁蔡航`
2. The About section no longer keeps an oversized empty lower half.
3. Top/bottom rubber-band scrolling no longer reveals a white blank strip; the page edge stays in the site cream background.
4. Research cards matching **“网红节点转移…”** and **“村中一棵树”** become text-only for visual consistency.
5. Honor certificate images are collected into a separate **Selected Certificates / 精选证书** gallery; the honors list underneath remains text-first.
6. Work is now **news/journalism only**.
7. Social Practice is removed from Work and appended to **Fieldwork & Practice**, with preserved external links.
8. Adds the 9 supplied cover images and the new links.

## Install

Unzip/copy the contents of this patch into:

`D:\git_projects\ivy-328.github.io`

Allow Windows to merge folders / replace same-name patch files if asked.

Then open Git Bash:

```bash
cd /d/git_projects/ivy-328.github.io
ruby apply_patch.rb
bundle exec jekyll serve
```

Open:

- English home: http://127.0.0.1:4000/
- Chinese home: http://127.0.0.1:4000/zh/
- Work: http://127.0.0.1:4000/work/
- Chinese Work: http://127.0.0.1:4000/zh/work/
- Practice: http://127.0.0.1:4000/practice/
- Chinese Practice: http://127.0.0.1:4000/zh/practice/
- Research: http://127.0.0.1:4000/research/

Use `Ctrl + F5` if the browser still shows old CSS.

## Safety / rollback

The installer automatically creates a timestamped folder such as:

`_backup_nju_v11_20260914-103800`

It contains backups of the existing Work, Practice and custom-head files before editing them.

## Before pushing to GitHub

Because your local `Gemfile` has intentionally remained modified for Windows/Jekyll, **do not use `git add .`**.

Use:

```bash
git status

git add _pages/work.md
git add _pages/work-zh.md
git add _pages/practice.md
git add _pages/practice-zh.md
git add _includes/head/custom.html
git add _includes/nju-v11-work.html
git add _includes/nju-v11-practice-links.html
git add _data/portfolio_v11.yml
git add assets/css/nju-purple-v11.css
git add assets/js/nju-purple-v11.js
git add images/work/
git add images/practice/

git commit -m "Refine NJU purple portfolio and practice pages"
git push
```

## Updating titles later

For the few external pages whose formal titles are not reliably readable from the public web, the patch uses conservative labels such as “视觉江苏｜影像作品 01”.  
You can rename them without touching HTML/CSS by editing:

`_data/portfolio_v11.yml`

Only change `title_zh` / `title_en`; the URL and cover can stay unchanged.
