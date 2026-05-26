import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "../components/types"
import { classNames } from "../util/lang"

const ArticleTitle: QuartzComponent = ({ fileData, displayClass }: QuartzComponentProps) => {
  const title = fileData.frontmatter?.title
  const urduTitle = fileData.frontmatter?.urdu_title
  const enTranslation = fileData.frontmatter?.en_translation
  const urTranslation = fileData.frontmatter?.ur_translation
  
  if (title) {
    return (
      <div class={classNames(displayClass, "article-title-container", (urduTitle || urTranslation) ? "has-urdu" : "")}>
        <h1 class="article-title">
          <span class={urduTitle ? "lang-en" : ""}>{title as string}</span>
          {urduTitle && <span class="lang-ur">{urduTitle as string}</span>}
        </h1>
        {(enTranslation || urTranslation) && (
          <div class="article-subtitle" style={{ marginTop: "0.2rem", fontSize: "1.2rem", color: "var(--gray)", fontStyle: "italic" }}>
            {enTranslation && <span class={urTranslation ? "lang-en" : ""}>{enTranslation as string}</span>}
            {urTranslation && <span class={enTranslation ? "lang-ur" : ""}>{urTranslation as string}</span>}
          </div>
        )}
      </div>
    )
  } else {
    return null
  }
}

ArticleTitle.css = `
.article-title {
  margin: 2rem 0 0 0;
}
.article-subtitle {
  margin: 0;
}
`

export default (() => ArticleTitle) satisfies QuartzComponentConstructor
