const currentLang = localStorage.getItem("lang") ?? "ur"
document.documentElement.setAttribute("saved-lang", currentLang)

const urTranslations: Record<string, string> = {
  "page-title": "سالار کا ذخیرہ",
  "explorer-title": "ایکسپلورر",
  "graph-title": "گراف ویو",
  "backlinks-title": "بیک لنکس",
  "toc-title": "فہرست",
  "search-placeholder": "کچھ تلاش کریں",
  "search-title": "تلاش",
  "backlinks-empty": "کوئی بیک لنکس نہیں ملے",
}

const enTranslations: Record<string, string> = {
  "page-title": "salararchives",
  "explorer-title": "Explorer",
  "graph-title": "Graph View",
  "backlinks-title": "Backlinks",
  "toc-title": "Table of Contents",
  "search-placeholder": "Search for something",
  "search-title": "Search",
  "backlinks-empty": "No backlinks found",
}

function applyLang(lang: string) {
  const translations = lang === "ur" ? urTranslations : enTranslations

  document.documentElement.setAttribute("saved-lang", lang)

  // Page title
  const pageTitleLink = document.querySelector(".page-title a")
  if (pageTitleLink) pageTitleLink.textContent = translations["page-title"]!

  const explorerH2 = document.querySelector(".explorer h2")
  if (explorerH2) explorerH2.textContent = translations["explorer-title"]!

  const graphH3 = document.querySelector(".graph > h3")
  if (graphH3) graphH3.textContent = translations["graph-title"]!

  const backlinksH3 = document.querySelector(".backlinks > h3")
  if (backlinksH3) backlinksH3.textContent = translations["backlinks-title"]!

  const backlinksEmpty = document.querySelector(".backlinks > ul > li:only-child")
  if (backlinksEmpty && (backlinksEmpty.textContent === "No backlinks found" || backlinksEmpty.textContent === "کوئی بیک لنکس نہیں ملے")) {
    backlinksEmpty.textContent = translations["backlinks-empty"]!
  }

  const tocH3 = document.querySelector("button.toc-header h3")
  if (tocH3) tocH3.textContent = translations["toc-title"]!

  const searchInput = document.querySelector<HTMLInputElement>("#search-bar")
  if (searchInput) searchInput.placeholder = translations["search-placeholder"]!

  const searchP = document.querySelector(".search-button > p")
  if (searchP) searchP.textContent = translations["search-title"]!
}

function applyAutomaticTextDirection() {
  const textBlocks = document.querySelectorAll<HTMLElement>(
    "article p, article li, article h1, article h2, article h3, article h4, article h5, article h6",
  )

  for (const block of textBlocks) {
    if (!block.hasAttribute("dir")) {
      block.setAttribute("dir", "auto")
    }
  }
}

document.addEventListener("nav", () => {
  const lang = document.documentElement.getAttribute("saved-lang") ?? "ur"
  applyLang(lang)
  applyAutomaticTextDirection()

  const switchLang = () => {
    const current = document.documentElement.getAttribute("saved-lang") ?? "ur"
    const newLang = current === "en" ? "ur" : "en"
    localStorage.setItem("lang", newLang)
    applyLang(newLang)
  }

  for (const btn of document.getElementsByClassName("langtoggle")) {
    btn.addEventListener("click", switchLang)
    window.addCleanup(() => btn.removeEventListener("click", switchLang))
  }
})
