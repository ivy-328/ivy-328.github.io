# Portfolio Patch v2

This version replaces the previous avant-garde layout with a calmer editorial portfolio:
- 2-column desktop grid
- 1-column mobile grid
- consistent 16:9 image cards
- restrained hover
- much more whitespace
- real cover images supported
- English + Chinese pages

Overwrite these files:
- `_pages/work.md`
- `_pages/work-zh.md`
- `assets/css/portfolio.css`

Keep your existing `_data/works.yml`.

Preview:
- http://127.0.0.1:4000/work/
- http://127.0.0.1:4000/zh/work/

Because your Gemfile is still locally modified, stage only:
```bash
git add _pages/work.md
git add _pages/work-zh.md
git add assets/css/portfolio.css
git commit -m "Refine portfolio layout"
git push
```
