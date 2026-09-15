---
layout: nju-page
permalink: /zh/work/
title: "作品"
lang: zh
nju_theme: true
---
{% assign lang = page.lang | default: 'en' %}
<section class="nju-inner-hero nju-inner-hero--work"><span class="nju-eyebrow">SELECTED WORK</span><h1>{% if lang == 'zh' %}作品集{% else %}Media & Portfolio{% endif %}</h1><p>{% if lang == 'zh' %}从新闻评论到社会实践，用真实作品记录我的媒体训练。{% else %}From journalism and commentary to social practice — a visual archive of media work and public-facing storytelling.{% endif %}</p></section>
<section class="nju-inner-section">
  {% assign cats = 'practice,journalism' | split: ',' %}
  {% for cat in cats %}
  <div class="nju-work-block"><div class="nju-section__title"><div><span>0{{ forloop.index }}</span><h2>{% if cat == 'practice' %}{% if lang == 'zh' %}社会实践{% else %}Social Practice{% endif %}{% else %}{% if lang == 'zh' %}新闻作品{% else %}Journalism{% endif %}{% endif %}</h2></div></div>
    <div class="nju-work-grid">{% for w in site.data.works %}{% if w.category == cat %}<a class="nju-work-card" href="{{ w.url }}" target="_blank" rel="noopener"><img src="{{ w.image | relative_url }}" alt=""><div><div class="nju-keyword-row">{% if lang == 'zh' %}{% for k in w.keywords_zh %}<span>{{ k }}</span>{% endfor %}{% else %}{% for k in w.keywords_en %}<span>{{ k }}</span>{% endfor %}{% endif %}</div><h3>{% if lang == 'zh' %}{{ w.title_zh }}{% else %}{{ w.title_en }}{% endif %}</h3><span>{% if lang == 'zh' %}打开原文{% else %}Open original{% endif %} ↗</span></div></a>{% endif %}{% endfor %}</div>
  </div>
  {% endfor %}
</section>
