# Caihang Liang — NJU Purple v1

This is an overlay patch for the current `ivy-328.github.io` Academic Pages/Jekyll repository.
It keeps Jekyll/GitHub Pages as the engine and replaces the visual layer with a custom NJU-purple identity.

## What is included
- Custom NJU-purple responsive header/footer
- Official NJU logo loaded from the official Nanjing University website
- English + Chinese home pages
- Dedicated Research & Publications pages
- Dedicated Fieldwork & Practice pages
- Dedicated Work/Portfolio pages
- Data-driven YAML content for research, experience, honors and work
- The photos you supplied, web-optimized and renamed
- Four selected award/certificate images extracted from the HUST application PDF
- Dynamic age calculation from `2005-03-28`
- Published article DOI wired to `10.16645/j.cnki.cn11-5281/c.2025.16.034`
- A maintenance guide for future updates

## Install
1. Back up your repo (Git history already helps):
```bash
cd /d/git_projects/ivy-328.github.io
git status
```
2. Extract this ZIP into `D:\git_projects\ivy-328.github.io` and allow folder merge / file replacement.
3. Stop an existing Jekyll server with `Ctrl + C`, then run:
```bash
bundle exec jekyll serve
```
4. Preview:
- http://127.0.0.1:4000/
- http://127.0.0.1:4000/zh/
- http://127.0.0.1:4000/research/
- http://127.0.0.1:4000/practice/
- http://127.0.0.1:4000/work/

## Important: your local Gemfile
You previously had local Windows/Jekyll changes in `Gemfile`.
Do **not** use `git add .` unless you intentionally want to commit it.

Stage this patch safely with:
```bash
git add _layouts/nju-home.html
git add _layouts/nju-page.html
git add _includes/nju-header.html
git add _includes/nju-footer.html
git add _includes/nju-home-content.html
git add _includes/head/custom.html
git add _pages/about.md
git add _pages/zh.md
git add _pages/research.md
git add _pages/research-zh.md
git add _pages/practice.md
git add _pages/practice-zh.md
git add _pages/work.md
git add _pages/work-zh.md
git add _data/profile.yml
git add _data/research.yml
git add _data/experience.yml
git add _data/honors.yml
git add _data/works.yml
git add _data/navigation.yml
git add assets/css/nju-purple.css
git add assets/js/nju-purple.js
git add images/profile.jpg
git add images/nju
git add images/honors
git add HOW-TO-UPDATE.md

git status
git commit -m "Redesign site with NJU purple visual system"
git push
```

## NJU logo note
The site uses the logo asset hosted by Nanjing University's official website:
`https://www.nju.edu.cn/__local/F/7A/1D/91723945F34FAA0A9C67700CF8F_13B47AE2_E3A7.png`
The official site states that university marks are institutional intangible assets and should be used in a standardized way. The footer therefore labels this as a personal academic website rather than an official NJU site.

## Known placeholder content
WeChat blocks reliable external crawling for several links. A few social-practice/news titles remain generalized in `_data/works.yml`. Replace those when you know the exact titles; the design does not need to change.
