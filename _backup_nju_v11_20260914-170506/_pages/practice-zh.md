---
layout: nju-page
permalink: /zh/practice/
title: "田野与实践"
lang: zh
nju_theme: true
---
{% assign lang = page.lang | default: 'en' %}
<section class="nju-inner-hero nju-inner-hero--practice">
  <span class="nju-eyebrow">FROM CAMPUS TO THE FIELD</span>
  <h1>{% if lang == 'zh' %}田野与实践{% else %}Fieldwork & Social Practice{% endif %}</h1>
  <p>{% if lang == 'zh' %}走向田野、连接现实，在媒体实践、乡村观察与公共服务中认识更真实的社会。{% else %}Through media practice, rural observation and public engagement, I try to understand society in a more grounded way.{% endif %}</p>
</section>
<section class="nju-inner-section">
  <div class="nju-practice-grid">
    {% for e in site.data.experience %}
    <article class="nju-practice-card" id="{{ e.id }}">
      <div class="nju-practice-card__media">{% if e.image and e.image != '' %}<img src="{{ e.image | relative_url }}" alt="{% if lang == 'zh' %}{{ e.title_zh }}{% else %}{{ e.title_en }}{% endif %}">{% else %}<div class="nju-practice-placeholder"><span>PROFESSIONAL EXPERIENCE</span><strong>{% if lang == 'zh' %}{{ e.org_zh }}{% else %}{{ e.org_en }}{% endif %}</strong></div>{% endif %}{% if e.secondary_image %}<img class="nju-practice-card__secondary" src="{{ e.secondary_image | relative_url }}" alt="">{% endif %}</div>
      <div class="nju-practice-card__copy"><span>{{ e.period }}</span><h2>{% if lang == 'zh' %}{{ e.title_zh }}{% else %}{{ e.title_en }}{% endif %}</h2><h4>{% if lang == 'zh' %}{{ e.org_zh }}{% else %}{{ e.org_en }}{% endif %}</h4><div class="nju-keyword-row">{% if lang == 'zh' %}{% for k in e.keywords_zh %}<span>{{ k }}</span>{% endfor %}{% else %}{% for k in e.keywords_en %}<span>{{ k }}</span>{% endfor %}{% endif %}</div><p>{% if lang == 'zh' %}{{ e.summary_zh }}{% else %}{{ e.summary_en }}{% endif %}</p>{% if e.url %}<a href="{{ e.url }}" target="_blank" rel="noopener">{% if lang == 'zh' %}查看相关报道{% else %}View related coverage{% endif %} ↗</a>{% endif %}</div>
    </article>
    {% endfor %}
  </div>
</section>
