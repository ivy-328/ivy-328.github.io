# Work Page v3 — template-based

This version intentionally stops using custom colorful card experiments.

It adapts the mature horizontal `paper-box` composition from the MIT-licensed
`steven068zzy/academic-homepage-template`, which is itself based on the same
Minimal Mistakes / Academic Pages family as your current site.

Overwrite:
- `_pages/work.md`
- `_pages/work-zh.md`

Add:
- `assets/css/work-template.css`

Keep:
- `_data/works.yml`

Important behavior:
- If `image:` is blank, the project becomes a clean text-only card.
- If you later add a cover image, the same card automatically becomes image-left / text-right.
- On mobile it automatically stacks vertically.

Preview:
- http://127.0.0.1:4000/work/
- http://127.0.0.1:4000/zh/work/

Commit only these files because your Gemfile is still modified locally:

```bash
git add _pages/work.md
git add _pages/work-zh.md
git add assets/css/work-template.css
git commit -m "Use template-based work layout"
git push
```
