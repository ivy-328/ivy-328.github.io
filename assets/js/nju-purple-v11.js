
(function () {
  "use strict";

  function compactText(el) {
    return (el && el.textContent ? el.textContent : "").replace(/\s+/g, "");
  }

  function findSectionByHeading(patterns) {
    const headings = Array.from(document.querySelectorAll("h1,h2,h3"));
    const heading = headings.find(h => patterns.some(p => p.test(h.textContent || "")));
    return heading ? (heading.closest("section") || heading.parentElement) : null;
  }

  function fixChineseHero() {
    if (!location.pathname.startsWith("/zh")) return;
    const nodes = Array.from(document.querySelectorAll("h1,h2,.hero-title,.hero__title,[class*='hero'] [class*='title']"));
    const hero = nodes.find(el => {
      const t = compactText(el);
      return t.includes("你好") && t.includes("梁蔡航");
    });
    if (!hero) return;
    hero.classList.add("v11-hero-fixed");
    hero.innerHTML =
      '<span class="v11-hero-line v11-hero-hi">你好</span>' +
      '<span class="v11-hero-line v11-hero-name">我是梁蔡航</span>';
  }

  function tightenAbout() {
    const section = findSectionByHeading([/About\s*Me/i, /^About$/i, /关于我/, /^关于$/]);
    if (section) section.classList.add("v11-about-section");
  }

  function makeResearchTextOnly() {
    const needles = [
      "网红节点转移",
      "村中一棵树",
      "Digital Literacy and Rural Platformization",
      "influencer nodes",
      "Village Tree"
    ];
    const candidates = Array.from(document.querySelectorAll(
      "article,.card,.research-card,.project-card,[class*='research'][class*='card'],[class*='project'][class*='card'],li"
    ));
    candidates.forEach(card => {
      const text = card.textContent || "";
      if (needles.some(n => text.includes(n))) {
        card.classList.add("v11-research-text-only");
      }
    });
  }

  function separateHonorImages() {
    const section = findSectionByHeading([/Selected\s*Honors/i, /^Honors$/i, /主要荣誉/, /荣誉与/]);
    if (!section || section.querySelector(".v11-cert-block")) return;

    const allImages = Array.from(section.querySelectorAll("img"))
      .filter(img => !img.closest(".v11-cert-block"));

    if (allImages.length < 2) return;

    const isZh = location.pathname.startsWith("/zh");
    const block = document.createElement("div");
    block.className = "v11-cert-block";
    block.innerHTML =
      "<h3>" + (isZh ? "精选证书" : "Selected Certificates") + "</h3>" +
      '<div class="v11-cert-gallery"></div>';

    const gallery = block.querySelector(".v11-cert-gallery");

    allImages.slice(0, 8).forEach(img => {
      const sourceAnchor = img.closest("a");
      const a = document.createElement("a");
      if (sourceAnchor && sourceAnchor.href) {
        a.href = sourceAnchor.href;
        a.target = sourceAnchor.target || "_blank";
        a.rel = "noopener";
      } else {
        a.href = img.currentSrc || img.src;
        a.target = "_blank";
        a.rel = "noopener";
      }
      const clone = img.cloneNode(true);
      clone.removeAttribute("style");
      a.appendChild(clone);
      gallery.appendChild(a);

      const media = img.closest("figure,[class*='image'],[class*='media'],[class*='cover']");
      if (media && media !== section) media.classList.add("v11-honor-original-media");
      else img.classList.add("v11-honor-original-media");
    });

    const firstListLike = section.querySelector("ul,ol,.honors-grid,[class*='honor'][class*='grid'],article,.card");
    if (firstListLike && firstListLike.parentElement) {
      firstListLike.parentElement.insertBefore(block, firstListLike);
    } else {
      section.appendChild(block);
    }
  }

  function run() {
    fixChineseHero();
    tightenAbout();
    makeResearchTextOnly();
    separateHonorImages();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
