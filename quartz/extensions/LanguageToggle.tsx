// @ts-ignore
import langToggleScript from "./scripts/langtoggle.inline"
import langToggleStyle from "./styles/langtoggle.scss"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "../components/types"
import { classNames } from "../util/lang"

const LanguageToggle: QuartzComponent = ({ displayClass }: QuartzComponentProps) => {
  return (
    <button class={classNames(displayClass, "langtoggle")} aria-label="Toggle language">
      <span class="lang-icon lang-en">EN</span>
      <span class="lang-icon lang-ur">UR</span>
    </button>
  )
}

LanguageToggle.beforeDOMLoaded = langToggleScript
LanguageToggle.css = langToggleStyle

export default (() => LanguageToggle) satisfies QuartzComponentConstructor