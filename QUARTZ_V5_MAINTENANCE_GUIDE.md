# Quartz v5 Maintenance Guide for salararchives

This note documents the current Quartz v5 setup, the issues that came up during migration, how they were fixed, and how to safely make future changes.

It is intentionally kept outside `content/`. The `content/` folder is managed by Quartz Syncer and can lag behind the remote repository until you pull. Keeping this guide in the repo root avoids accidentally publishing it or having Syncer overwrite it.

## Current Setup

Project root:

```text
F:\Documents\myquartz\homepage\quartz
```

Main Obsidian vault:

```text
F:\Documents\(07)Obsidian\obsidian_folder\heim
```

Quartz Syncer vault subfolder:

```text
200 Quartz/
```

Quartz repository content folder:

```text
content/
```

Git branch used for the live Quartz v5 site:

```text
v5
```

Vercel project:

```text
salararchives
```

Vercel production URL:

```text
https://salararchives.vercel.app
```

Current Vercel build command:

```shell
rm -rf .quartz/plugins && npx quartz plugin install && npx quartz build
```

This command removes the Vercel-cached plugin folder before reinstalling plugins from the lockfile. It is slower than the clean official command, but it avoids the plugin update/cache corruption failures we saw on Vercel.

Node is pinned in `package.json`:

```json
"engines": {
  "npm": ">=10.9.2",
  "node": "24.x"
}
```

This prevents Vercel from silently moving the project to a future Node major version.

## Golden Rules

1. Do not treat local `content/` as always current.

Quartz Syncer can push content changes directly from Obsidian to GitHub. If you later work locally, the local repo may be behind remote content.

2. Before editing Quartz code or config, pull first.

```shell
git status
git pull --rebase origin v5
```

3. After editing Quartz code or config, build locally if the change affects rendering.

```shell
npx quartz build
```

4. Commit only the files you meant to change.

```shell
git status --short
git diff -- path/to/file
git add path/to/file
git commit -m "clear message"
git pull --rebase origin v5
git push origin v5
```

5. Do not use `npx quartz sync` casually when Quartz Syncer is also active.

`npx quartz sync` pulls, stages everything, commits, and pushes from the current local checkout. That can include stale or unintended `content/` changes if you are not careful. For config/code changes, explicit Git commands are safer.

6. Do not edit `.quartz/plugins/...` as a permanent fix.

Vercel reinstalls `.quartz/plugins` during each build. Permanent local overrides belong under `quartz/extensions/`, `quartz/styles/custom.scss`, `quartz.ts`, or `quartz.config.yaml`.

7. Keep `quartz-themes` disabled unless there is a very specific reason to re-enable it.

It injected heavy, high-specificity CSS and fought the custom site identity. Disabling it solved several layout and background conflicts.

## Quartz v5 Architecture

Quartz is a static site generator. The important build flow is:

1. `npx quartz build` runs `quartz/bootstrap-cli.mjs`.
2. The CLI bundles TypeScript and SCSS with esbuild.
3. Quartz loads `quartz.ts`.
4. `quartz.ts` loads `quartz.config.yaml` and the resolved layout.
5. Quartz reads files from `content/`.
6. Transformer plugins parse Markdown into ASTs and metadata.
7. Filter plugins remove pages that should not publish.
8. Emitter plugins write output into `public/`.
9. Component resources become global CSS and JS bundles.
10. Vercel serves the generated `public/` directory.

The main architectural pieces are:

```text
quartz.config.yaml       plugin config, theme, layout positions
quartz.ts                TypeScript override layer for local custom behavior
quartz/styles/custom.scss custom project CSS
quartz/extensions/       local custom components and scripts
content/                 published notes and assets
quartz/static/           static site-wide files
.quartz/plugins/         installed community plugins, not permanent edits
quartz.lock.json         plugin lockfile
```

## v5 Plugin Types

Quartz v5 uses several plugin categories:

- Transformers parse or modify content.
- Filters decide whether a content file publishes.
- Emitters write files such as HTML, RSS, sitemap, assets, and content index.
- Page types define how a class of page renders.
- Components render pieces of the layout such as Explorer, Graph, Search, Backlinks, Reader Mode, Dark Mode, Article Title, and Tag List.
- Frames define the physical page shell and grid.

The active default frame is the normal three-column frame:

```text
left sidebar | center content | right sidebar
```

Special page types can use special frames. For example, canvas and Excalidraw pages use custom frames so they can go full-screen or full-width without the ordinary article column constraints.

## Current Active Plugins

Important active plugins in `quartz.config.yaml`:

- `created-modified-date`
- `syntax-highlighting`
- `obsidian-flavored-markdown`
- `github-flavored-markdown`
- `table-of-contents`
- `crawl-links`
- `description`
- `latex`
- `hard-line-breaks`
- `remove-draft`
- `unlisted-pages`
- `encrypted-pages`
- `alias-redirects`
- `content-index`
- `favicon`
- `og-image`
- `cname`
- `canvas-page`
- `content-page`
- `folder-page`
- `tag-page`
- `explorer`
- `graph`
- `search`
- `backlinks`
- `article-title`
- `content-meta`
- `tag-list`
- `page-title`
- `darkmode`
- `reader-mode`
- `breadcrumbs`
- `footer`
- `spacer`
- `bases-page`
- `note-properties`
- `obsidian-plugin-excalidraw`

Important disabled plugin:

- `quartz-themes`

## What Changed During Migration

### 1. quartz-themes Was Disabled

Problem:

The `saberzero1/quartz-themes` plugin injected a lot of high-specificity CSS. It covered the starry background, affected column sizing, and interfered with Explorer collapse behavior.

Fix:

The plugin remains present in config but disabled:

```yaml
- source:
    name: quartz-themes
    repo: github:saberzero1/quartz-themes
    subdir: plugin
  enabled: false
```

Keep it disabled unless a future design explicitly requires it.

### 2. Starry Background Restored

Problem:

The migrated site no longer showed the dark-mode starry background. Opaque wrappers from Quartz v5 and plugin CSS covered it.

Fix:

`quartz/styles/custom.scss` puts the star background on `:root[saved-theme="dark"]` and makes page wrappers transparent:

```scss
:root[saved-theme="dark"] {
  background-color: var(--light);
  background-image: url("data:image/svg+xml;base64,...");
  background-repeat: repeat;
  background-size: 700px 700px;
  background-attachment: fixed;
}

:root[saved-theme="dark"] body,
:root[saved-theme="dark"] #quartz-root,
:root[saved-theme="dark"] #quartz-body,
:root[saved-theme="dark"] #quartz-body > .sidebar,
:root[saved-theme="dark"] #quartz-body > .center {
  background-color: transparent;
  background-image: none;
}
```

Light mode deliberately has no stars:

```scss
:root[saved-theme="light"] {
  background-image: none;
}
```

To change the background later, edit this section of `custom.scss`.

### 3. Center Column and Right Graph Overlay Fixed

Problem:

The center column exceeded its width, and the right sidebar felt like it was overlapping content. At one point the layout visually looked like it had spawned a fourth column.

Fix:

The custom grid in `custom.scss` explicitly bounds the layout:

```scss
grid-template-columns: minmax(13rem, 20rem) minmax(0, 50rem) minmax(12rem, 18rem);
```

The center content is capped:

```scss
> .center {
  max-width: 50rem;
  min-width: 0;
}
```

On tablet and mobile widths the right sidebar becomes static and stops behaving like a sticky side column:

```scss
@media all and (max-width: 1200px) {
  > .right.sidebar {
    position: static;
    height: auto;
    width: 100%;
    max-width: 100%;
  }
}
```

When changing layout, preserve `minmax(0, ...)` and `min-width: 0`. These prevent wide content, tables, code blocks, and sidebars from forcing the grid wider than the viewport.

### 4. Explorer Collapse Fixed

Problem:

When Explorer collapsed, the button itself disappeared and there was no visible control.

Fix:

`custom.scss` gives collapsed Explorer a small stable basis and hides only the content:

```scss
.explorer.collapsed {
  flex-basis: 2rem;
  min-height: 2rem;
}

.explorer.collapsed > .desktop-explorer {
  min-height: 1.5rem;
  overflow: visible;
}

.explorer.collapsed > .explorer-content {
  display: none;
}
```

### 5. Language Toggle Placement Fixed

Problem:

The language toggle appeared independently above the search bar instead of next to the Reader Mode and Dark Mode controls.

Fix:

`quartz.ts` wraps the toolbar component with the language toggle:

```ts
function withLanguageToggle(toolbar: QuartzComponent): QuartzComponent {
  const ToolbarWithLanguageToggle: QuartzComponent = (props) =>
    h("div", { class: "toolbar-with-language-toggle" }, [
      h(toolbar, props),
      h(LanguageToggleComponent, props),
    ])
}
```

This is why the toggle now sits to the right of the toolbar group rather than as an independent sidebar item.

### 6. Properties Dropdown Hidden

Problem:

The migrated site showed an editor-like `Properties` dropdown on public notes. The old site showed tags directly without exposing a properties panel.

Fix:

`note-properties` is still enabled, but its visible properties view is hidden:

```yaml
- source: github:quartz-community/note-properties
  enabled: true
  options:
    includeAll: false
    includedProperties:
      - description
      - tags
      - aliases
    hidePropertiesView: true
```

`tag-list` remains enabled in `beforeBody`, so tags still show as public tags without the dropdown.

### 7. Urdu RTL Restored

Problem:

After migration, Urdu content stopped behaving right-to-left.

Fix:

`quartz/extensions/scripts/langtoggle.inline.ts` adds `dir="auto"` to article text blocks:

```ts
const textBlocks = document.querySelectorAll<HTMLElement>(
  "article p, article li, article h1, article h2, article h3, article h4, article h5, article h6",
)

for (const block of textBlocks) {
  if (!block.hasAttribute("dir")) {
    block.setAttribute("dir", "auto")
  }
}
```

This lets the browser detect direction per text block. The CSS also applies Vazirmatn and RTL direction to Urdu UI text while `saved-lang="ur"` is active.

### 8. Search Tokenizer Fixed for Hyphenated Titles

Problem:

Searching `fatihah` did not find `1-Al-Fatihah`. It only appeared when searching `1`.

Root cause:

The community search tokenizer treated hyphenated strings as one token, so `1-Al-Fatihah` was indexed as a different token shape.

Fix:

A local search override lives at:

```text
quartz/extensions/Search.ts
```

It patches the community search script so hyphen, slash, underscore, en dash, and em dash act like separators:

```ts
${whitespaceCheck}||${codePoint}===45||${codePoint}===47||${codePoint}===95||${codePoint}===8211||${codePoint}===8212
```

`quartz.ts` registers this local `Search` component in place of the community one:

```ts
if (key === "search" || key === "Search" || key.endsWith("/Search")) {
  componentRegistry.register(key, Search, "local:search-tokenizer")
}
```

Do not patch `.quartz/plugins/search` directly. It will be reinstalled.

### 9. Vercel Plugin Install Failures Fixed

Problem:

Vercel failed with messages like:

```text
Installing plugins from lockfile...
article-title: failed to update
alias-redirects: failed to update
backlinks: failed to update
```

Root cause:

Vercel cache kept stale plugin Git folders under `.quartz/plugins`.

Fix:

The Vercel build command deletes `.quartz/plugins` first:

```shell
rm -rf .quartz/plugins && npx quartz plugin install && npx quartz build
```

Keep this command unless Vercel plugin cache errors stop being relevant and a cacheless redeploy confirms the official command is stable.

### 10. `.vercel` and `.env.local` Ignored

Problem:

`vercel link` created local project files. Those should not be committed.

Fix:

`.gitignore` includes:

```text
.vercel
.env*
```

## Quartz Syncer Setup

Quartz Syncer is installed in Obsidian and configured for the vault:

```text
F:\Documents\(07)Obsidian\obsidian_folder\heim
```

Current non-secret settings observed:

```text
pluginVersion: 1.15.3
vaultPath: 200 Quartz/
contentFolder: content
branch: v5
publishFrontmatterKey: publish
allNotesPublishableByDefault: true
useDataview: true
useCanvas: false
useBases: false
useExcalidraw: false
useCache: true
manageSyncerStyles: true
```

The important thing is that Syncer pushes the Obsidian subfolder:

```text
200 Quartz/
```

into the Quartz repo folder:

```text
content/
```

on GitHub branch:

```text
v5
```

This means the repo `content/` folder is a generated/published copy of part of the vault. It is not the source of truth for your notes.

### Syncer vs `npx quartz sync`

Quartz Syncer:

- Runs from Obsidian.
- Uses the configured Git remote, branch, token, and content folder.
- Publishes from the vault subfolder into GitHub.
- Can push content changes while your local Quartz repo is not open.

`npx quartz sync`:

- Runs from the local Quartz repo.
- Uses the currently checked-out local Git branch.
- Pulls, stages all changes, commits, and pushes.
- Does not know about your separate Obsidian vault except whatever files are already in local `content/`.

Use Quartz Syncer for content publishing. Use explicit Git commands for code/config maintenance.

### Safe Local Workflow When Syncer Is Active

Before any code/config edit:

```shell
cd F:\Documents\myquartz\homepage\quartz
git status
git pull --rebase origin v5
```

After editing:

```shell
npx quartz build
git status --short
git diff -- path/to/file
git add path/to/file
git commit -m "fix: describe change"
git pull --rebase origin v5
git push origin v5
```

If the only changes are content changes from Syncer, do not edit or recommit them manually unless you intentionally want to manage content outside Obsidian.

### Branch Rule

Quartz Syncer publishes to the branch configured in the plugin settings:

```text
v5
```

Local Git commands operate on the branch you currently have checked out. Check it with:

```shell
git branch --show-current
```

or:

```shell
git status --short --branch
```

If you are not on `v5`, switch before making Quartz site changes:

```shell
git switch v5
git pull --rebase origin v5
```

## Vercel Setup

The repo is linked to Vercel project:

```text
salararchives
```

Local `.vercel/repo.json` identifies:

```text
project: salararchives
project id: prj_eDVif8lVJUm56Mh2NqJoptgkGZOr
remote: origin
directory: .
```

Vercel should deploy branch `v5` for production. Other branches can still appear as preview deployments. That is normal.

Important Vercel project settings:

```text
Framework preset: Other
Root directory: .
Node version: 24.x
Build command: rm -rf .quartz/plugins && npx quartz plugin install && npx quartz build
Output directory: public
```

If Vercel says production deployment settings differ from current project settings, save the project settings and redeploy. The project settings should match the values above.

## Excalidraw

### How Obsidian Excalidraw Works

Obsidian Excalidraw drawings can be stored as Markdown files containing:

- YAML frontmatter.
- readable `Text Elements`.
- hidden `%%` comment sections.
- compressed JSON scene data.

The drawing data looks like:

~~~markdown
%%
## Drawing
```compressed-json
...
```
%%
~~~

Obsidian can render this as a drawing because the Excalidraw plugin recognizes:

```yaml
excalidraw-plugin: parsed
```

and opens the note in Excalidraw view.

### Why HomeLab Workflow Did Not Render

The `HomeLab workflow` drawing was published as:

```text
content/HomeLab workflow.md
```

The original vault file was also:

```text
200 Quartz/HomeLab workflow.md
```

The file had Excalidraw data, but because it was a plain `.md` file and Quartz Syncer Excalidraw integration was disabled, Syncer compiled it as ordinary Markdown. That stripped the hidden `%%` drawing block and published only the text labels.

Quartz then had no shapes, coordinates, or scene JSON to render.

### Correct v5 Excalidraw Workflow

For Quartz v5, Excalidraw files should be real `.excalidraw.md` files.

In Obsidian Excalidraw settings:

```text
useExcalidrawExtension: true
```

In the UI, search the Excalidraw settings for:

```text
.excalidraw.md or .md
```

Turn that option on.

For existing drawings, rename inside Obsidian from:

```text
HomeLab workflow
```

to:

```text
HomeLab workflow.excalidraw
```

Obsidian should store it as:

```text
HomeLab workflow.excalidraw.md
```

Then enable Quartz Syncer Excalidraw integration:

```text
Settings > Community plugins > Quartz Syncer > Integration > Enable Excalidraw integration
```

After that:

1. Open Quartz Syncer publication center.
2. Unpublish the old text-only `HomeLab workflow.md` copy.
3. Publish the new `HomeLab workflow.excalidraw.md`.
4. Pull locally if you need to inspect it:

```shell
git pull --rebase origin v5
```

Expected repository file:

```text
content/HomeLab workflow.excalidraw.md
```

Expected Quartz route:

```text
/HomeLab-workflow.excalidraw
```

The Quartz Excalidraw plugin then renders the drawing as an interactive SVG page with pan and zoom.

## Adding an Element Below the Graph

The Graph component is positioned on the right sidebar:

```yaml
- source: github:quartz-community/graph
  enabled: true
  layout:
    position: right
    priority: 10
```

Backlinks are also on the right:

```yaml
- source: github:quartz-community/backlinks
  enabled: true
  layout:
    position: right
    priority: 30
```

There are two ways to add something below the Graph.

### Option A: Add a Community Component Plugin

If the element is reusable and plugin-like, create or install a component plugin and set:

```yaml
layout:
  position: right
  priority: 20
```

Priority `20` places it after Graph (`10`) and before Backlinks (`30`).

### Option B: Add a Local Component

For this archive, local project components are simpler.

Create:

```text
quartz/extensions/GraphNote.tsx
```

Example:

```tsx
import type { QuartzComponent, QuartzComponentConstructor } from "../components/types"

const GraphNote: QuartzComponent = () => {
  return (
    <div class="graph-note">
      <h3>Archive Note</h3>
      <p>Short custom text or links can go here.</p>
    </div>
  )
}

GraphNote.css = `
.graph-note {
  margin-top: 1rem;
  font-size: 0.9rem;
  color: var(--darkgray);
}
`

export default (() => GraphNote) satisfies QuartzComponentConstructor
```

Then import and add it in `quartz.ts`:

```ts
import GraphNote from "./quartz/extensions/GraphNote"

const GraphNoteComponent = GraphNote()
```

Inside `restoreCustomLayout`, append it to the right sidebar:

```ts
const right = pageLayout.right ?? []
if (!right.includes(GraphNoteComponent)) {
  pageLayout.right = [...right, GraphNoteComponent]
}
```

That adds it below the existing right sidebar components. If it must appear exactly below Graph and above Backlinks, splice it into the array after detecting the Graph component, or use a component plugin with layout priority `20`.

When adding right-sidebar widgets, test at desktop, tablet, and mobile sizes. The custom CSS deliberately changes right sidebar behavior below `1200px`.

## Changing the Background Theme

There are two layers:

1. Theme colors in `quartz.config.yaml`.
2. Custom background behavior in `quartz/styles/custom.scss`.

Theme colors:

```yaml
theme:
  typography:
    header: EB Garamond
    body: EB Garamond
    code: IBM Plex Mono
  colors:
    lightMode:
      light: "#faf8f8"
      secondary: "#284b63"
    darkMode:
      light: "#141414"
      secondary: "#7b97aa"
```

The dark-mode star field is not a normal theme token. It is custom CSS:

```scss
:root[saved-theme="dark"] {
  background-image: url("data:image/svg+xml;base64,...");
}
```

To replace it:

1. Change the `background-image`.
2. Keep the transparency rules below it.
3. Run `npx quartz build`.
4. Inspect dark mode and light mode.

Do not use `quartz-themes` for this unless you want to rework the whole CSS cascade.

## Urdu and Language Toggle Architecture

Current files:

```text
quartz/extensions/LanguageToggle.tsx
quartz/extensions/scripts/langtoggle.inline.ts
quartz/extensions/styles/langtoggle.scss
quartz/extensions/ArticleTitle.tsx
quartz.ts
quartz/styles/custom.scss
```

The toggle stores language in local storage:

```ts
localStorage.setItem("lang", newLang)
```

and reflects it on the root element:

```ts
document.documentElement.setAttribute("saved-lang", lang)
```

CSS switches visible language spans:

```scss
html[saved-lang="en"] .lang-ur { display: none !important; }
html[saved-lang="ur"] .lang-en { display: none !important; }
html[saved-lang="ur"] .lang-ur { display: inline !important; }
html[saved-lang="en"] .lang-en { display: inline !important; }
```

The article title component supports:

```yaml
title: English title
urdu_title: اردو عنوان
en_translation: English subtitle
ur_translation: اردو ذیلی عنوان
```

`ArticleTitle.tsx` renders both languages and uses `.lang-en` / `.lang-ur`.

### Adding More Urdu UI Strings

Edit:

```text
quartz/extensions/scripts/langtoggle.inline.ts
```

Add a key to both dictionaries:

```ts
const urTranslations = {
  "new-widget-title": "اردو متن",
}

const enTranslations = {
  "new-widget-title": "English text",
}
```

Then update `applyLang` to select the target element:

```ts
const widgetTitle = document.querySelector(".my-widget h3")
if (widgetTitle) widgetTitle.textContent = translations["new-widget-title"]!
```

### Adding Urdu Note Content

For small bilingual sections, use spans:

```markdown
<span class="lang-en">English sentence.</span>
<span class="lang-ur">اردو جملہ۔</span>
```

For larger sections, use divs:

```markdown
<div class="lang-en">

English paragraphs here.

</div>

<div class="lang-ur" dir="rtl">

اردو پیراگراف یہاں۔

</div>
```

The existing CSS hides the inactive language.

For whole-page translated content, a cleaner long-term architecture would be:

- English page and Urdu page as separate notes, linked by frontmatter.
- Or a custom page component that reads frontmatter fields and renders a language-aware title/body selector.

Do not duplicate massive bodies inside one note unless the page is short. It can make search indexes and HTML output much heavier.

## Adding Images and Videos

Use `content/assets/` for note media that should be available at public `/assets/...` URLs.

Current example asset:

```text
content/assets/it-is-time-to-triumph.mp4
```

Public URL:

```text
/assets/it-is-time-to-triumph.mp4
```

Your HTML video embed:

```html
<div style="text-align: center;">

  <video
    src="/assets/it-is-time-to-triumph.mp4"
    autoplay
    muted
    loop
    controls
    playsinline
    style="width: 100%; max-width: 700px; height: auto;">
  </video>

</div>
```

This works because the file is under:

```text
content/assets/
```

For images in Markdown:

```markdown
![[assets/rafael.png]]
```

or:

```markdown
![Rafael](/assets/rafael.png)
```

For Open Graph/social previews:

```yaml
socialImage: /assets/rafael.png
```

Use `quartz/static/` for site-wide files that are not content-note media, such as verification files:

```text
quartz/static/verification/discord
```

This is served under:

```text
/static/verification/discord
```

## Where to Make Common Changes

### Change Theme Colors

Edit:

```text
quartz.config.yaml
```

Look under:

```yaml
theme:
  colors:
```

### Change Star Background

Edit:

```text
quartz/styles/custom.scss
```

Look for:

```scss
// ===== 5. Stars Background
```

### Change Column Widths

Edit:

```text
quartz/styles/custom.scss
```

Look for:

```scss
grid-template-columns: minmax(13rem, 20rem) minmax(0, 50rem) minmax(12rem, 18rem);
```

The center width is also capped at:

```scss
max-width: 50rem;
```

### Change Toolbar Language Toggle

Edit:

```text
quartz.ts
quartz/extensions/LanguageToggle.tsx
quartz/extensions/styles/langtoggle.scss
quartz/extensions/scripts/langtoggle.inline.ts
```

### Change Article Title Behavior

Edit:

```text
quartz/extensions/ArticleTitle.tsx
```

### Change Search Tokenization

Edit:

```text
quartz/extensions/Search.ts
```

Then confirm the marker still patches correctly:

```shell
npx quartz build
```

If the community search plugin changes and the marker is not found, the build will fail loudly instead of silently losing the tokenizer fix.

### Change Explorer Behavior

First inspect the community Explorer plugin, but do not permanently edit `.quartz/plugins/explorer`.

Permanent overrides should go into:

```text
quartz/styles/custom.scss
quartz.ts
```

or a local component in:

```text
quartz/extensions/
```

### Change Graph Behavior

Graph placement is in `quartz.config.yaml`:

```yaml
- source: github:quartz-community/graph
  layout:
    position: right
    priority: 10
```

Styling overrides go in `custom.scss`.

For an element below Graph, use the local component approach described above.

## Testing Checklist

For CSS or layout changes:

```shell
npx quartz build
```

For local preview:

```shell
npx quartz build --serve
```

Then inspect:

- desktop width above `1200px`
- tablet width between `800px` and `1200px`
- mobile width below `800px`
- dark mode
- light mode
- Urdu toggle
- Explorer collapsed and expanded
- pages with Graph and Backlinks
- a Quran page with numbered/hyphenated title search
- Excalidraw page if enabled

For Git cleanliness:

```shell
git status --short --branch
git diff --check
```

For Vercel:

- Check the deployment branch is `v5`.
- Check the build command still includes `.quartz/plugins` cleanup.
- Check Node version is `24.x`.
- If plugin install errors return, keep the cleanup command.

## Common Failure Modes

### Star Background Disappears

Likely causes:

- `quartz-themes` got re-enabled.
- A wrapper regained opaque background.
- The star CSS was moved from `:root[saved-theme="dark"]`.

Check:

```text
quartz.config.yaml
quartz/styles/custom.scss
```

### Right Sidebar Overlaps Center Content

Likely causes:

- Grid column widths changed.
- `minmax(0, ...)` was removed.
- `.center` lost `min-width: 0`.
- right sidebar became sticky/static at the wrong breakpoint.

Check the first section of `custom.scss`.

### Language Toggle Floats Somewhere Wrong

Likely causes:

- `quartz.ts` no longer wraps the toolbar.
- Search/Darkmode/ReaderMode toolbar CSS changed and `isToolbar` no longer detects it.

Check:

```text
quartz.ts
```

### Urdu Direction Breaks

Likely causes:

- `applyAutomaticTextDirection` is not running on `nav`.
- `dir="auto"` is missing.
- CSS is overriding direction.

Check:

```text
quartz/extensions/scripts/langtoggle.inline.ts
quartz/extensions/styles/langtoggle.scss
quartz/styles/custom.scss
```

### Search Does Not Find Hyphenated Titles

Likely causes:

- Local search override was not registered.
- Community search script changed and the patch marker no longer matches.

Check:

```text
quartz.ts
quartz/extensions/Search.ts
```

Then run:

```shell
npx quartz build
```

### Excalidraw Shows Text Instead of Drawing

Likely causes:

- File is plain `.md` instead of `.excalidraw.md`.
- Quartz Syncer Excalidraw integration is disabled.
- Obsidian Excalidraw `useExcalidrawExtension` is disabled.
- Syncer published the file as ordinary Markdown and stripped the hidden drawing block.

Correct state:

```text
Obsidian filename: Something.excalidraw.md
Quartz Syncer useExcalidraw: true
Quartz config obsidian-plugin-excalidraw: enabled
Repo file: content/Something.excalidraw.md
```

### Vercel Plugin Install Fails

Likely cause:

- Stale cached `.quartz/plugins`.

Keep:

```shell
rm -rf .quartz/plugins && npx quartz plugin install && npx quartz build
```

### Local `content/` Looks Old

Likely cause:

- Quartz Syncer pushed new content to GitHub from Obsidian, but local repo was not pulled.

Fix:

```shell
git pull --rebase origin v5
```

Do this before local code work.

## Recommended Future Improvements

These are optional, not urgent:

1. Enable Excalidraw integration properly if drawings should publish as interactive pages.
2. Consider disabling unused plugins if performance becomes an issue:
   - `encrypted-pages` if no encrypted pages are used.
   - `canvas-page` if no `.canvas` files are published.
   - `bases-page` if no `.base` files are published.
   - `latex` if no math pages use it.
3. Consider `lazyLoad: true` under `crawl-links` if initial content index size becomes a practical performance problem.
4. Add a small custom component below the Graph for archive notices, Quran links, or recently updated content.
5. Formalize bilingual note structure if Urdu/English parallel content grows.

## Quick Command Reference

Pull current remote:

```shell
git pull --rebase origin v5
```

Build:

```shell
npx quartz build
```

Serve locally:

```shell
npx quartz build --serve
```

Commit config/code change:

```shell
git status --short
git diff -- path/to/file
git add path/to/file
git commit -m "fix: describe change"
git pull --rebase origin v5
git push origin v5
```

Check branch:

```shell
git branch --show-current
```

Quartz CLI sync, only when you truly want to stage/commit/push everything in the local checkout:

```shell
npx quartz sync
```

Sync from remote only:

```shell
npx quartz sync --no-push --no-commit
```

Vercel inspect from user terminal:

```shell
vercel whoami
vercel project inspect salararchives
```

## Mental Model

Think of this project as three layers:

1. Obsidian vault

This is the source of truth for notes.

2. Quartz repo

This is the website engine plus a published copy of selected notes under `content/`.

3. Vercel

This is the build and hosting system. It clones branch `v5`, installs Quartz plugins, builds, and serves `public/`.

Most content work should happen in Obsidian and publish through Quartz Syncer. Most website behavior work should happen in the Quartz repo and push through Git. Mixing those workflows is fine, but always pull remote first so Syncer changes do not surprise you.
