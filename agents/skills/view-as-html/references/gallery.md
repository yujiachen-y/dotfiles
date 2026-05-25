# Gallery Index — `references/gallery/`

21 standalone HTML files demonstrating the Anthropic visual language across
different content shapes. Bundled into this skill (no external clone required).
Source and license: see [`gallery/SOURCE.md`](gallery/SOURCE.md).

Each entry below is a **decision aid**: the file path, the patterns it
demonstrates, and one line of concrete structural detail so you can tell
whether reading it will pay off for your current task.

When you've matched a content shape, `Read` the listed file — focus on its
`<style>` block (the first ~150 lines), then skim the body markup. The CSS
tokens and class names are excellent learning material; copy patterns liberally
and rename to fit the task.

## Index

| # | File | Pattern | What this file shows you concretely |
|---|------|---------|-------------------------------------|
| 01 | [`gallery/01-exploration-code-approaches.html`](gallery/01-exploration-code-approaches.html) | P8 Exploration | 3 alternative implementations stacked vertically; each section has a name + pros/cons table + inline `<pre>` code snippet; ends in a "recommended" oat callout |
| 02 | [`gallery/02-exploration-visual-designs.html`](gallery/02-exploration-visual-designs.html) | P8 Exploration | 3 side-by-side large preview cards, each containing a hand-built SVG mock of the UI direction (not screenshots, not photos) |
| 03 | [`gallery/03-code-review-pr.html`](gallery/03-code-review-pr.html) | P5 PR Review | Repo path + PR title header card with +/- diff stats; findings as cards with a colored severity dot (olive/clay/rust); inline diff `<pre>` blocks with line highlighting |
| 04 | [`gallery/04-code-understanding.html`](gallery/04-code-understanding.html) | P6 Architecture | A page-wide inline SVG module diagram (boxes + arrows) at the top; below it, one section per module with the file path in mono + prose + public-surface list |
| 05 | [`gallery/05-design-system.html`](gallery/05-design-system.html) | P7 Design Tokens | Color swatches as cards (color fills top half, hex/name below); type specimens at multiple sizes per family; spacing scale as horizontal bars of increasing width |
| 06 | [`gallery/06-component-variants.html`](gallery/06-component-variants.html) | P1/P7 | Grid of button variants in every state (default/hover/active/disabled) shown as live HTML; mono labels above each row |
| 07 | [`gallery/07-prototype-animation.html`](gallery/07-prototype-animation.html) | P10 Prototype | Pure-CSS keyframe animations (no JS) shown in framed panels with their CSS source visible underneath |
| 08 | [`gallery/08-prototype-interaction.html`](gallery/08-prototype-interaction.html) | P10 Prototype | Small interactive demo (~60 lines of inline JS) with state + event handlers; hardcoded sample data in JS |
| 09 | [`gallery/09-slide-deck.html`](gallery/09-slide-deck.html) | P11 Slides | Full-viewport slides with arrow-key navigation (inline JS); per-slide layout: large serif title, subtitle, body, slide number in corner; type sizes 56-72px title / 22-26px body |
| 10 | [`gallery/10-svg-illustrations.html`](gallery/10-svg-illustrations.html) | P12 Diagrams | Grid of standalone SVG illustrations with mono captions — useful template for "I need 4 small diagrams on one page" |
| 11 | [`gallery/11-status-report.html`](gallery/11-status-report.html) | P3 Status | 4-card summary band with mono labels + a clay-accent border on one card; mid-page `table.data` shipped list with a severity dot column; inline SVG velocity bar chart ~600x180px; oat carryover callout at the bottom |
| 12 | [`gallery/12-incident-report.html`](gallery/12-incident-report.html) | P9 Incident | Rust-colored severity pill in the header; 4-card timing band (detected/mitigated/resolved/customer impact); vertical timeline with mono timestamps; action-item table with owner + due date |
| 13 | [`gallery/13-flowchart-diagram.html`](gallery/13-flowchart-diagram.html) | P12 Diagrams | A single full-page inline SVG (boxes + arrows + condition labels) occupying most of the viewport; legend at the bottom with color-coded entries; brief prose framing above |
| 14 | [`gallery/14-research-feature-explainer.html`](gallery/14-research-feature-explainer.html) | P4 Explainer | Hero block + key-concepts grid with small SVG glyph per concept; serif lead paragraph; multi-section "how it works" with diagrams |
| 15 | [`gallery/15-research-concept-explainer.html`](gallery/15-research-concept-explainer.html) | P4 Explainer | Two-column layout: main content + sticky sidebar TOC (240px wide); inline SVG ring visualization with sliders that mutate it via JS; `.term` dotted-underline for key vocabulary |
| 16 | [`gallery/16-implementation-plan.html`](gallery/16-implementation-plan.html) | P2 Plan | `.prompt-box` showing the original request as the document anchor; 4-card summary band (steps / ETA / blockers / risk); numbered sections each with file paths, mockups, code, acceptance criteria; risk table at the end |
| 17 | [`gallery/17-pr-writeup.html`](gallery/17-pr-writeup.html) | P5 PR Review | Rationale-first PR description with before/after panels side by side and a structured test-plan checklist; more prose-heavy than 03 |
| 18 | [`gallery/18-editor-triage-board.html`](gallery/18-editor-triage-board.html) | P10 Prototype | Full-width Kanban-style column-flow layout (3-4 columns of stacked item cards); inline JS for drag/move; deviates from the 920px max-width rule because Kanban demands width |
| 19 | [`gallery/19-editor-feature-flags.html`](gallery/19-editor-feature-flags.html) | P10 Prototype | Feature-flag admin panel: list of flags with toggles, metadata pills, last-modified mono timestamps, sticky search/filter row at the top |
| 20 | [`gallery/20-editor-prompt-tuner.html`](gallery/20-editor-prompt-tuner.html) | P10 Prototype | 3-pane editor UI: parameter sliders/toggles (left), prompt input (center), output preview (right); good template for any "playground" app |
| 21 | [`gallery/index.html`](gallery/index.html) | P13 Browse-index | The umbrella gallery: categorized card grid with hand-drawn SVG thumbnails per item; nice pattern when you need "browseable index of N items" |

## How to use these

When the user's content matches a content shape above:

1. Pick the closest example (by content shape, not visual similarity).
2. `Read` the file with the Read tool — start by scanning the `<style>` block,
   then skim the body markup.
3. Lift the CSS patterns and HTML structure that solve the same problem you
   have. Rename classes if needed; swap in the user's content.
4. Drop sections that don't apply. **A sparse page beats a padded one.**

## Avoid

- Copying example content (Acme product names, dummy data, fictional figures)
  into the user's page. The gallery is reference, not template.
- Reproducing every section of a reference file. If the user has 3 things to
  show, don't pad to fill the reference's 8 sections.
- Treating a reference as a strict template to fill out field-by-field. Adapt
  the shape to the user's content, not the other way around.

## A note on fidelity

These references are hand-crafted static examples. They occasionally use values
that diverge slightly across files — gray-100 vs g100, slightly different
padding, varying h1 sizes. The **canonical tokens** to use are the ones in
[`design-system.md`](design-system.md) — they're a normalized superset. Don't
get distracted reconciling small differences across reference files; pick from
design-system.md and move on.
