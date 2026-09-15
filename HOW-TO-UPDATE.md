# HOW TO UPDATE YOUR WEBSITE — 不问 ChatGPT 也能自己改

The visual code is separate from your content. For ordinary updates, edit YAML files under `_data/` and add images under `images/`.

## 1. Before editing
```bash
cd /d/git_projects/ivy-328.github.io
git pull --rebase origin master
```
If `Gemfile` has local-only edits and Git refuses the pull, temporarily stash it:
```bash
git stash push -m "keep local Gemfile changes" -- Gemfile
git pull --rebase origin master
git stash pop
```

## 2. Where to edit
- Basic identity / email / hometown / advisor: `_data/profile.yml`
- Papers and research projects: `_data/research.yml`
- Internships / fieldwork / volunteering: `_data/experience.yml`
- Awards: `_data/honors.yml`
- Journalism and WeChat links: `_data/works.yml`

## 3. Example: add a new paper
Open `_data/research.yml` and add:
```yaml
- id: "new-paper"
  title_en: "Your New Paper"
  title_zh: "你的新论文"
  status_en: "Published"
  status_zh: "已发表"
  period: "2027"
  summary_en: "One or two sentences."
  summary_zh: "一两句话介绍。"
  methods:
    - "NLP"
    - "Causal Inference"
```

## 4. Example: add a new practice photo
Put the image into:
`images/nju/new-practice.jpg`
Then add an item to `_data/experience.yml` and set:
```yaml
image: "/images/nju/new-practice.jpg"
```

## 5. Preview locally
```bash
bundle exec jekyll serve
```
Open `http://127.0.0.1:4000/` and press `Ctrl + F5` if the browser caches old CSS.
Stop the server with `Ctrl + C`.

## 6. Publish
```bash
git status
```
Stage only the files you changed, e.g.:
```bash
git add _data/research.yml
git add images/nju/new-practice.jpg
git commit -m "Update research and practice"
git push
```

## 7. Change colors later
Open `assets/css/nju-purple.css` and edit the variables at the top:
```css
--nju-purple: #4d0099;
--nju-deep: #351052;
--nju-lav: #eee8f5;
--nju-gold: #bd9654;
```

## 8. Change fonts later
The site intentionally uses sans-serif Chinese body text:
`PingFang SC / Microsoft YaHei`.
The display headings use a restrained serif stack only for large editorial headings.
