import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"

const ArticleTitle: QuartzComponent = ({ fileData, displayClass }: QuartzComponentProps) => {
  const title = fileData.frontmatter?.title
  const urduTitle = fileData.frontmatter?.urdu_title
  if (title) {
    if (urduTitle) {
      return (
        <h1 class={classNames(displayClass, "article-title")}>
          <span class="lang-en">{title}</span>
          <span class="lang-ur">{urduTitle as string}</span>
        </h1>
      )
    }
    return <h1 class={classNames(displayClass, "article-title")}>{title}</h1>
  } else {
    return null
  }
}

ArticleTitle.css = `
.article-title {
  margin: 2rem 0 0 0;
}
`

export default (() => ArticleTitle) satisfies QuartzComponentConstructor
