---
name: view-as-html
description: >
  Renders the response as a self-contained, visually polished HTML page saved to /tmp and opened in
  the browser, replacing plain markdown or wall-of-text output. Triggers when the user says
  "/view-as-html", or asks to "view as html / show as a page / make a pretty page / 用 html 给我看 /
  做成网页 / 别给我干巴巴的文字 / 我想浏览不是阅读". Also applies when the response is structured
  information — comparisons, plans, status reports, research summaries, concept explainers, PR
  write-ups, design tokens, dashboards — even without an explicit "html" keyword, since a layout with
  cards, tables, SVG and color hierarchy reads faster than markdown for these shapes.
---

# View as HTML

When this skill triggers, the answer you owe the user is **a saved HTML file they open in a browser**,
not a chat reply that contains the content. The chat reply is just the receipt — a one-liner saying
"opened /tmp/&lt;slug&gt;.html, here's what's inside in one sentence". The information itself lives
in the file.

The design language follows Anthropic's: ivory background, slate text, clay accents, serif headings,
mono micro-labels. A 21-file reference gallery is bundled inside this skill at
[`references/gallery/`](references/gallery/) — you'll open one of those before writing anything.

## Before drafting: open one reference

The single most common failure of this skill is going straight from "I see the content shape" to
"I'll write the HTML from memory of what Anthropic-style looks like." That memory is wrong in five
specific, recoverable ways:

- **Density.** The gallery packs more per screen than you'd default to — 4-column summary bands,
  multi-column card grids, tables instead of bullet lists. Your default is sparser.
- **Palette.** You'll reach for indigo, teal, or a gradient. The gallery uses one warm clay accent
  (`#D97757`) on muted earth tones (ivory `#FAF9F5`, slate `#141413`, oat `#E3DACC`) and nothing else.
- **Type roles.** You'll pick one family. The gallery uses three — serif headings, sans body, mono
  micro-labels — with strict letter-spacing on the mono labels (0.06–0.08em uppercase).
- **Section signature.** You'll use emoji as section icons (📊, 🚀, 🛠). The gallery uses a small
  mono-uppercase eyebrow ("KEY METRICS") with a clay rule. Emoji-as-decoration is the strongest
  "AI-generated" tell.
- **Restraint.** You'll add gradient backgrounds, drop shadows, centered hero text. The gallery is
  left-aligned, flat, with a single clay border-left as the whole visual punch budget.

The 60-second fix: pick the closest reference for your content shape (via
[`references/patterns.md`](references/patterns.md) or
[`references/gallery.md`](references/gallery.md)), `Read` it, scan the `<style>` block, glance at
the body markup. That single read re-anchors your output. **Skip this step and the page looks
AI-default no matter how good the rest of the workflow is.**

## When to use this skill

The user asked for it explicitly (`/view-as-html`, "用 html 给我看", "make a pretty page", "show me a
view") — easy case, just do it.

The harder case: the user asked a question whose **answer is structured information** — three options
to compare, a multi-week plan, a status report, a concept explainer with parts and relationships,
a PR walkthrough. In those cases markdown turns into a wall of bullets that the user scrolls and
re-reads. An HTML page with a summary band, sectioned layout, and a small diagram or table lets them
scan once and grasp the shape. If you find yourself about to write 800 lines of markdown with H2s and
bullet lists, that's the signal — offer this skill or just use it.

Skip this skill for short factual answers, code-only responses, single-paragraph thoughts, or anywhere
the user is mid-debug and needs the answer in the terminal stream.

## Workflow

1. **Pick a slug** — kebab-case, 2-5 words, derived from the content's core noun phrase. Examples:
   `pinia-vs-zustand`, `q4-status`, `oauth-flow`, `consistent-hashing`. The file path is always
   `/tmp/<slug>.html`. If a file at that path already exists from this session and you're iterating,
   overwrite it; otherwise pick a fresh slug.

2. **Match content shape → pattern → reference file.** Open
   [`references/patterns.md`](references/patterns.md) if you're not sure which of P1–P13 fits.
   Each pattern names one or two reference files in [`references/gallery/`](references/gallery/) to
   open. If the shape is obvious, skip patterns.md and go straight to
   [`references/gallery.md`](references/gallery.md) for one-line teasers of all 21 files.

3. **`Read` the reference.** This is the calibration step from the section above — don't skip it.
   Focus on the `<style>` block (usually the first ~150 lines) and the high-level body structure.
   You're looking for: the page's max-width, the type sizes, how sections are marked, where the
   mono labels live, what the one SVG on the page is doing.

4. **Write the HTML as a single self-contained file.** All CSS in a `<style>` block in `<head>`.
   No external fonts, no CDNs, no images from URLs. SVG inline. JS inline if needed (rarely).
   The design tokens (color, type, spacing) and reusable component CSS live in
   [`references/design-system.md`](references/design-system.md) — copy the `:root` variables and the
   components you need straight into the file. [`assets/starter.html`](assets/starter.html) is a
   pre-wired skeleton with the tokens already in place if you want a faster start — it's a chassis,
   not a substitute for opening a reference.

5. **Save and open.** Write to `/tmp/<slug>.html`, then run `open /tmp/<slug>.html`. On macOS this
   opens the user's default browser. Do this in one step — don't ask "should I open it now?".

6. **Reply in chat with one short line**, e.g. "Opened `/tmp/pinia-vs-zustand.html` — compares the
   two on store API, reactivity model, and devtools." Don't paste the HTML. Don't recap the content
   in markdown. The file is the answer.

## Core design principles

Four rules keep the output recognizable as part of the gallery rather than generic web work. Copy
the tokens from [`references/design-system.md`](references/design-system.md) and these fall out for
free — the exact hex values, type stacks, sizes, and the *why* for each live there:

- Three type roles, never mixed: serif headings, sans body, mono micro-labels
- Ivory + slate + clay palette only — no Material blue, no Tailwind indigo, no gradients
- Space and 1.5px `--g300` borders separate things, not `<hr>` or drop shadows
- Mono-uppercase 11–12px with letter-spacing 0.06–0.08em is the metadata signature

**Information density matters.** The reference pages pack a lot per screen — 4-column summary bands,
multi-column card grids, tables with hover states. Don't pad with one-card-per-row layouts unless
the content is genuinely one item.

## Content fits layout, not the other way around

The most common failure mode after "didn't read a reference" is taking the right content into the
wrong layout — putting a 5-step plan into a card grid (loses the sequence), or putting a comparison
of 3 things into a long article (makes the reader hunt for the table). Spend a moment matching
shape to content:

| Content shape | Layout |
|---|---|
| Comparing N options on M dimensions | Wide table or N-column cards, dimensions as rows |
| Sequential steps, plan, milestones | Numbered sections, vertical timeline with dots |
| Concept with parts that relate | Article with inline SVG diagram |
| Status / metrics / progress | Summary band of stat cards + sectioned report |
| Many things to triage / browse | Card grid with thumbnails |
| Code change / PR / review | Header card + finding cards + diff snippets |
| Single concept needing emphasis | Hero block + 2-3 supporting panels |

More combinations and their reference files in [`references/patterns.md`](references/patterns.md).

## Self-contained is the contract

The user opens the file from `/tmp/`, possibly offline, possibly months later. The file must render
identically without any network call:

- Fonts: system stack only (`ui-serif`, `system-ui`, `ui-monospace` and fallbacks). No
  `fonts.googleapis.com`.
- Images: inline SVG, or omit. No `<img src="https://...">`.
- Icons: inline SVG. No icon-font CDN.
- Scripts: inline if any. No `<script src="...">`.
- CSS: inline `<style>` block. No `<link rel="stylesheet">`.

If you need a chart, draw it as SVG with explicit `<rect>` / `<path>` / `<line>` — the reference
gallery has many examples of this in the diagram and explainer files. Don't pull in Chart.js or D3.

## Things to actively avoid

These are the patterns that make HTML output look AI-generated rather than crafted. The reference
gallery does none of these.

- **Emoji as section icons** — 📊 Key Metrics / 🚀 Next Steps / 🛠 Implementation. The Anthropic
  style uses small mono-uppercase labels ("KEY METRICS") and a clay accent line instead. The only
  acceptable emoji use is a single reactive one tied to a specific moment, not as decoration.

- **Gradient backgrounds and neon accents.** The palette is muted earth tones. A single clay
  accent line or border-left is the whole "visual punch" budget.

- **Centered hero text spanning the full page.** The gallery is left-aligned, max-width ~900px,
  with intentional asymmetry (a sidebar TOC, a 2-column hero) — not centered marketing-page layout.

- **Tailwind utility-class soup in the HTML.** The reference files use semantic class names
  (`.summary-band`, `.stat-card`, `.milestone`). Readable HTML is part of the deliverable —
  the user may inspect the source.

- **"Generated by AI" footers, robot icons, sparkle motifs.** The page should look like a person
  made it for a specific purpose.

- **Recapping the content as markdown in chat after generating.** The whole point is the user
  reads the page, not the chat. One line in chat is enough.

- **Copying Acme / sample data from the reference into the user's page.** The references contain
  fictional placeholder names ("Acme", made-up product names, fictional figures). Lift the
  structure and CSS, write the actual content fresh for the user's task.

## When the user iterates

If the user says "change the title" / "add a section" / "use a darker accent" / "drop the timeline,
make it a table":

1. Read the existing `/tmp/<slug>.html` first to see current state.
2. Edit in place (don't pick a new slug for the same content).
3. Re-run `open /tmp/<slug>.html` so the browser tab refreshes. Most browsers will reload the file
   when the user clicks the tab; `open` brings the tab to focus.
4. Reply in chat with one line describing what changed.

For a structural shift ("turn this status report into a slide deck"), it's fine to swap to a new
reference file and start a fresh draft — note in chat that the layout pattern changed.

## Quick checks before saving

- [ ] I `Read` at least one file from `references/gallery/` this session (if no, stop and do it now
      — the output will look generic otherwise)
- [ ] `<!doctype html>` + `<meta charset="utf-8">` + `<meta name="viewport" content="width=device-width, initial-scale=1">`
- [ ] All CSS in one `<style>` block, no external references
- [ ] `:root` design tokens present, palette matches the gallery (clay-on-ivory, no indigo/teal)
- [ ] At least one mono-uppercase eyebrow / label somewhere — the typographic signature
- [ ] Responsive: works at 900px and at 600px (media query for grids)
- [ ] No emoji decoration in headings or as section bullets
- [ ] No literal "Acme" / placeholder content carried over from the reference
- [ ] File saved to `/tmp/<slug>.html` and `open` ran successfully
