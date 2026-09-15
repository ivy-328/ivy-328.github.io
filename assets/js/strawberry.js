(() => {
  const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  // Reveal-on-scroll
  const revealEls = document.querySelectorAll(".reveal");
  if (!reduced && "IntersectionObserver" in window) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12 });
    revealEls.forEach((el) => observer.observe(el));
  } else {
    revealEls.forEach((el) => el.classList.add("is-visible"));
  }

  // Gentle hero parallax. Intentionally tiny: mood, not motion sickness.
  const hero = document.querySelector(".sc-hero");
  const floaters = document.querySelectorAll("[data-parallax]");
  if (hero && floaters.length && !reduced) {
    hero.addEventListener("pointermove", (event) => {
      const rect = hero.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - 0.5;
      const y = (event.clientY - rect.top) / rect.height - 0.5;
      floaters.forEach((el) => {
        const depth = Number(el.dataset.parallax || 4);
        el.style.setProperty("--px", `${x * depth}px`);
        el.style.setProperty("--py", `${y * depth}px`);
      });
    });
    hero.addEventListener("pointerleave", () => {
      floaters.forEach((el) => {
        el.style.setProperty("--px", "0px");
        el.style.setProperty("--py", "0px");
      });
    });
  }

  // Smooth in-page anchors
  document.querySelectorAll('a[href^="#"]').forEach((link) => {
    link.addEventListener("click", (event) => {
      const target = document.querySelector(link.getAttribute("href"));
      if (target) {
        event.preventDefault();
        target.scrollIntoView({ behavior: reduced ? "auto" : "smooth", block: "start" });
      }
    });
  });
})();
