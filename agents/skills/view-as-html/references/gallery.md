# Gallery Index — `~/3rd/html-effectiveness/`

The reference repo from Anthropic's blog post *The unreasonable effectiveness of HTML* contains
20 standalone HTML files demonstrating different layout patterns. They're the canonical examples
of the Anthropic visual language applied across content shapes.

**Path on this machine**: `~/3rd/html-effectiveness/` (cloned locally).

**Source**: <https://github.com/anthropics/html-effectiveness> and accompanying blog post
<https://claude.com/blog/using-claude-code-the-unreasonable-effectiveness-of-html>.

When you're not sure how to lay out a specific content shape, find the closest analogue in the
table below and `Read` that file. The CSS and structure are excellent learning material; copy
patterns liberally, but adapt names and content to the current task.

If the path doesn't exist, that's fine — `references/patterns.md` and `references/design-system.md`
together are enough to produce good output without these references.

## Index

| # | File | Pattern | One-liner |
|---|------|---------|-----------|
| 01 | `01-exploration-code-approaches.html` | P8 Exploration | 3 alternative implementations of the same feature, with pros/cons |
| 02 | `02-exploration-visual-designs.html` | P8 Exploration | 3 visual directions for a UI, shown as mocks |
| 03 | `03-code-review-pr.html` | P5 PR Review | Full PR walkthrough: header card, findings, code snippets, severity dots |
| 04 | `04-code-understanding.html` | P6 Architecture | Module map of a codebase with inter-module arrows |
| 05 | `05-design-system.html` | P7 Design Tokens | Color swatches, type specimens, spacing scale, component samples |
| 06 | `06-component-variants.html` | P1 Comparison / P7 | Grid of button variants with state matrix |
| 07 | `07-prototype-animation.html` | P10 Prototype | CSS-only animations showcasing motion patterns |
| 08 | `08-prototype-interaction.html` | P10 Prototype | Small interactive demo with state and event handlers |
| 09 | `09-slide-deck.html` | P11 Slides | Keyboard-navigable slide deck with title + body layout |
| 10 | `10-svg-illustrations.html` | P12 Diagrams | Grid of standalone SVG illustrations with captions |
| 11 | `11-status-report.html` | P3 Status | Weekly engineering status: summary band, shipped table, velocity chart, carryover |
| 12 | `12-incident-report.html` | P9 Incident | Postmortem layout: severity pill, timeline, root cause, action table |
| 13 | `13-flowchart-diagram.html` | P12 Diagrams | Request flow as a full-page SVG flowchart with legend |
| 14 | `14-research-feature-explainer.html` | P4 Explainer | Feature deep-dive with hero, key concepts grid, illustrations |
| 15 | `15-research-concept-explainer.html` | P4 Explainer | Interactive consistent-hashing demo with sliders and live SVG |
| 16 | `16-implementation-plan.html` | P2 Plan | Implementation plan with prompt box, numbered sections, mocks, code, risk table |
| 17 | `17-pr-writeup.html` | P5 PR Review | PR description with rationale, before/after, test plan |
| 18 | `18-editor-triage-board.html` | P10 Prototype | Kanban-style triage board with column flow |
| 19 | `19-editor-feature-flags.html` | P10 Prototype | Feature flag panel with toggles and metadata |
| 20 | `20-editor-prompt-tuner.html` | P10 Prototype | Prompt-tuning UI with input / output / parameter panels |

The umbrella `index.html` in the same folder is itself an excellent gallery layout (categorized
cards with hand-drawn SVG thumbnails) and worth studying when you need a "browseable index of
things" pattern.

## How to use these

When you're producing HTML for a task and the user's content shape resembles one of the rows above:

1. Identify the closest example by content shape, not just visual similarity.
2. Use the `Read` tool on `~/3rd/html-effectiveness/<file>.html` to load the full source.
3. Extract the CSS patterns and HTML structure that solve the same problem you're solving.
4. Adapt — rename classes if needed, swap in your content, drop sections that don't apply, add
   sections that do.

Avoid:

- Copying the example's literal content (Acme product names, dummy data) into the user's page.
- Including more sections than the user's content actually fills. A sparse page beats a padded one.
- Treating the reference as a template to fill out field-by-field. The shape adapts to the content.

## A note on fidelity

These references are static, hand-crafted examples. They occasionally use values that diverge
slightly across files (gray-100 vs g100, gray-300 vs g300, slightly different padding). The
canonical tokens to use are the ones in `references/design-system.md` — they're a normalized
superset. Don't get distracted reconciling small differences; pick from design-system.md and move on.
