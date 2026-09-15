---
layout: nju-page
permalink: /research/
title: "Research & Publications"
lang: en
nju_theme: true
---
{% assign lang = page.lang | default: 'en' %}
<section class="nju-inner-hero nju-inner-hero--research">
  <span class="nju-eyebrow">NANJING UNIVERSITY</span>
  <h1>{% if lang == 'zh' %}研究与发表{% else %}Research & Publications{% endif %}</h1>
  <p>{% if lang == 'zh' %}以数据读懂时代，以传播连接社会。{% else %}Research for a more connected society — with data, theory and grounded observation.{% endif %}</p>
</section>
<section class="nju-inner-section" id="publications">
  <div class="nju-section__title"><div><span>01</span><h2>{% if lang == 'zh' %}论文与研究{% else %}Academic Publications & Research{% endif %}</h2></div></div>
  <div class="nju-research-list">
    {% for r in site.data.research %}
    <article class="nju-paper-card" id="{{ r.id }}">
      <div class="nju-paper-card__meta"><span>{{ r.period }}</span><em>{% if lang == 'zh' %}{{ r.status_zh }}{% else %}{{ r.status_en }}{% endif %}</em></div>
      <h3>{% if lang == 'zh' %}{{ r.title_zh }}{% else %}{{ r.title_en }}{% endif %}</h3>
      {% if r.venue_en %}<p class="nju-paper-card__venue">{% if lang == 'zh' %}{{ r.venue_zh }}{% else %}{{ r.venue_en }}{% endif %}</p>{% endif %}
      <p>{% if lang == 'zh' %}{{ r.abstract_zh | default: r.summary_zh }}{% else %}{{ r.abstract_en | default: r.summary_en }}{% endif %}</p>
      {% if r.doi %}<a class="nju-doi" href="https://doi.org/{{ r.doi }}" target="_blank" rel="noopener">DOI {{ r.doi }} ↗</a>{% endif %}
      <div class="nju-mini-tags">{% for m in r.methods %}<span>{{ m }}</span>{% endfor %}</div>
      {% if r.image %}<img class="nju-paper-card__image" src="{{ r.image | relative_url }}" alt="">{% endif %}
    </article>
    {% endfor %}
  </div>
</section>
<section class="nju-inner-section">
  <div class="nju-section__title"><div><span>02</span><h2>{% if lang == 'zh' %}研究方法与工具{% else %}Research Methods & Tools{% endif %}</h2></div></div>
  <div class="nju-tool-cloud"><span>Python</span><span>R</span><span>SPSS</span><span>Gephi</span><span>NVivo</span><span>Git</span><span>NLP</span><span>Machine Learning</span><span>Quantitative Content Analysis</span><span>Causal Inference</span><span>Data Visualization</span><span>Multi-Agent Simulation</span></div>
</section>
<section class="nju-inner-section">
  <div class="nju-section__title"><div><span>03</span><h2>{% if lang == 'zh' %}主要荣誉{% else %}Selected Honors{% endif %}</h2></div></div>
  <div class="nju-honors-grid">{% for h in site.data.honors %}<article class="nju-honor-card">{% if h.image %}<img src="{{ h.image | relative_url }}" alt="">{% endif %}<span>{{ h.year }}</span><h3>{% if lang == 'zh' %}{{ h.title_zh }}{% else %}{{ h.title_en }}{% endif %}</h3>{% if h.note_en %}<p>{% if lang == 'zh' %}{{ h.note_zh }}{% else %}{{ h.note_en }}{% endif %}</p>{% endif %}</article>{% endfor %}</div>
</section>
