import { loadQuartzConfig, loadQuartzLayout } from "./quartz/plugins/loader/config-loader"
import { PageTypes } from "./quartz/plugins"
import { h } from "preact"
import type { FullPageLayout } from "./quartz/cfg"
import type { QuartzComponent } from "./quartz/components/types"
import { componentRegistry } from "./quartz/components/registry"
import { concatenateResources } from "./quartz/util/resources"
import LanguageToggle from "./quartz/extensions/LanguageToggle"
import ArticleTitle from "./quartz/extensions/ArticleTitle"
import Search from "./quartz/extensions/Search"

const config = await loadQuartzConfig()

for (const key of componentRegistry.getAll().keys()) {
  if (key === "search" || key === "Search" || key.endsWith("/Search")) {
    componentRegistry.register(key, Search, "local:search-tokenizer")
  }
}

export const layout = await loadQuartzLayout()

const LanguageToggleComponent = LanguageToggle()
const ArticleTitleComponent = ArticleTitle()

const toolbarLanguageCss = `
.toolbar-with-language-toggle {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  width: 100%;
}

.toolbar-with-language-toggle > .flex-component {
  flex: 1 1 auto;
  min-width: 0;
}

.toolbar-with-language-toggle > .langtoggle {
  flex: 0 0 20px;
}
`

function resourceText(resource: QuartzComponent["css"]): string {
  if (!resource) return ""
  return Array.isArray(resource) ? resource.join("\n") : resource
}

function isArticleTitle(component: QuartzComponent): boolean {
  return typeof component.css === "string" && component.css.includes("article-title")
}

function isToolbar(component: QuartzComponent): boolean {
  const css = resourceText(component.css)
  return css.includes("search-button") && (css.includes("readermode") || css.includes("darkmode"))
}

function withLanguageToggle(toolbar: QuartzComponent): QuartzComponent {
  const ToolbarWithLanguageToggle: QuartzComponent = (props) =>
    h("div", { class: "toolbar-with-language-toggle" }, [
      h(toolbar, props),
      h(LanguageToggleComponent, props),
    ])

  ToolbarWithLanguageToggle.css = concatenateResources(
    toolbar.css,
    LanguageToggleComponent.css,
    toolbarLanguageCss,
  )
  ToolbarWithLanguageToggle.beforeDOMLoaded = concatenateResources(
    toolbar.beforeDOMLoaded,
    LanguageToggleComponent.beforeDOMLoaded,
  )
  ToolbarWithLanguageToggle.afterDOMLoaded = concatenateResources(
    toolbar.afterDOMLoaded,
    LanguageToggleComponent.afterDOMLoaded,
  )

  return ToolbarWithLanguageToggle
}

function restoreCustomLayout(pageLayout: Partial<FullPageLayout>, addLanguageToggle = true) {
  if (pageLayout.beforeBody) {
    pageLayout.beforeBody = pageLayout.beforeBody.map((component) =>
      isArticleTitle(component) ? ArticleTitleComponent : component,
    )
  }

  if (addLanguageToggle) {
    const left = pageLayout.left ?? []
    const toolbarIndex = left.findIndex(isToolbar)

    if (toolbarIndex !== -1) {
      pageLayout.left = left.map((component, index) =>
        index === toolbarIndex ? withLanguageToggle(component) : component,
      )
    } else if (!left.includes(LanguageToggleComponent)) {
      pageLayout.left = [...left, LanguageToggleComponent]
    }
  }
}

restoreCustomLayout(layout.defaults)

for (const [pageType, pageLayout] of Object.entries(layout.byPageType)) {
  restoreCustomLayout(pageLayout, pageType !== "404")
}

config.plugins.emitters = [
  ...config.plugins.emitters.filter((emitter) => emitter.name !== "PageTypeDispatcher"),
  PageTypes.PageTypeDispatcher(layout),
]

export default config
