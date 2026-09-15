# Portfolio Patch v1

Copy the included files into the same paths in your `ivy-328.github.io` repository.

Preview:
- http://127.0.0.1:4000/work/
- http://127.0.0.1:4000/zh/work/

Because your local Gemfile is modified, do not use `git add .`.

Use:
```bash
git add _data/works.yml
git add _data/navigation.yml
git add _pages/work.md
git add _pages/work-zh.md
git add assets/css/portfolio.css
git commit -m "Add visual work portfolio"
git push
```

Later, add real covers under `images/work/` and update the `image:` field in `_data/works.yml`.
