import { Search as CommunitySearch } from "../../.quartz/plugins/search/dist/components/index.js"
import type { SearchOptions } from "../../.quartz/plugins/search/dist/components/index.js"
import type { QuartzComponent, QuartzComponentConstructor } from "../components/types"
import type { StringResource } from "../util/resources"

const whitespaceMatcher =
  /([A-Za-z_$][\w$]*)\s*===\s*32\s*\|\|\s*\1\s*===\s*9\s*\|\|\s*\1\s*===\s*10\s*\|\|\s*\1\s*===\s*13/

function addSeparatorTokenization(resource: StringResource): StringResource {
  const patch = (script: string) => {
    if (!whitespaceMatcher.test(script)) {
      throw new Error("Could not patch community search tokenizer: expected marker was not found")
    }

    return script.replace(
      whitespaceMatcher,
      (whitespaceCheck, codePoint) =>
        `${whitespaceCheck}||${codePoint}===45||${codePoint}===47||${codePoint}===95||${codePoint}===8211||${codePoint}===8212`,
    )
  }

  if (Array.isArray(resource)) return resource.map(patch)
  return typeof resource === "string" ? patch(resource) : resource
}

export default ((opts?: Partial<SearchOptions>) => {
  const Search = CommunitySearch(opts) as unknown as QuartzComponent
  Search.afterDOMLoaded = addSeparatorTokenization(Search.afterDOMLoaded)
  return Search
}) satisfies QuartzComponentConstructor<Partial<SearchOptions> | undefined>
