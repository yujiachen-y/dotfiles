# Layout Patterns — Content Shape to Page Structure

A generated HTML page feels "made for this content" when the **shape of the
information** matches the right structural pattern. Wrong match → the reader
has to hunt for the point. This file is the mapping.

Each pattern below lists:

- The content shape that triggers it
- The structural ingredients (sections, layout primitives)
- The reference file(s) in [`gallery/`](gallery/) that demonstrate it best

**The references aren't optional reading.** Memory of "Anthropic-style HTML" is
unreliable — open the listed reference file before drafting and the visual
density, type roles, and label signature recalibrate in under a minute. The
file paths below all resolve inside this skill, so `Read` them directly.

## Contents

- **How to choose** — the question to ask when matching content to layout
- **P1 — Comparison** — N options × M dimensions (table or N-column cards)
- **P2 — Step-by-step plan or sequence** — ordered steps with numbered sections
- **P3 — Status report / dashboard** — summary band + sectioned report + shipped table
- **P4 — Concept explainer with interactive demo** — article + sidebar TOC + inline SVG demo
- **P5 — Code review / PR walkthrough** — header card + finding cards + diff snippets
- **P6 — Architectural / code understanding** — module map + per-module detail
- **P7 — Design system / token reference** — swatches + type specimens + components
- **P8 — Exploration / option laydown** — 2–3 alternative approaches or directions
- **P9 — Incident or postmortem** — severity pill + timeline + RCA + action table
- **P10 — Prototype interaction / micro-app** — full-bleed UI with inline JS
- **P11 — Slide deck** — full-viewport slides with arrow-key navigation
- **P12 — Diagram / flowchart** — single full-page SVG with legend
- **P13 — Browseable index** — categorized card grid with SVG thumbnails
- **Cross-cutting tips** — auto-pill, prompt-box, inline SVG

## How to choose

Read the user's request and ask: *what is the user actually trying to take away
from this page?*

- Take away a **comparison verdict** → comparison table or side-by-side cards (P1)
- Take away a **sequence of actions** → numbered sections or timeline (P2)
- Take away a **mental model of a system** → article + inline diagram (P4 / P6)
- Take away a **snapshot of where we are** → summary band + sectioned report (P3)
- Take away **a list of items to choose from** → card grid (P13)
- Take away **the impact of a change** → before/after, diff-style annotation (P5)
- Take away **how a value was reached** → step-by-step derivation with annotations (P2)

Below are the recurring shapes.

---

## P1 — Comparison (N options × M dimensions)

**Triggered by**: "compare X and Y", "what's the difference between A, B, C",
"which library should I use", "Pinia vs Zustand vs Jotai".

**Structure**:

- Header with eyebrow + h1 + one-line lead
- Either:
  - **Wide comparison table** with dimensions as rows, options as columns
  - **N-column side-by-side cards** when each option needs prose, not data
    points
- Optional verdict callout at the end ("If you need X, go with A. If you need Y,
  B is the better fit.")
- No summary band — the table *is* the summary

**Open before drafting**: [`gallery/01-exploration-code-approaches.html`](gallery/01-exploration-code-approaches.html),
[`gallery/06-component-variants.html`](gallery/06-component-variants.html)

---

## P2 — Step-by-step plan or sequence

**Triggered by**: "what's the plan for shipping X", "outline the migration",
"give me an implementation plan", "walk me through the steps to set up Y".

**Structure**:

- Header + `prompt-box` showing the original request (anchors the page in what
  was asked)
- Summary band: counts (steps, ETA, blockers, risk level)
- Sequential numbered sections (`.sec-head .num` with `01`, `02`, …) — each
  section is one step
- Inside each section: a paragraph of "what we do here", then specific
  artifacts (file paths, code snippets, mockups, tables of acceptance criteria)
- Optional final section: "open questions" or "risks" as a callout

**Open before drafting**: [`gallery/16-implementation-plan.html`](gallery/16-implementation-plan.html),
[`gallery/17-pr-writeup.html`](gallery/17-pr-writeup.html)

---

## P3 — Status report / dashboard

**Triggered by**: "weekly status", "what did we ship", "Q4 progress", "where
are we on X", "engineering update".

**Structure**:

- Header with title + date range + repo/team label
- Summary band of 4 stat cards (shipped, in review, blocked, planned — or
  whatever metrics fit)
- "Highlights" section: list of 3-5 bullets with bold lead-ins
- Shipped table: `table.data` with columns for PR, author, change, risk dot
- Optional velocity chart as inline SVG
- "Carryover" or "next week" section as oat-colored callout

**Open before drafting**: [`gallery/11-status-report.html`](gallery/11-status-report.html)

---

## P4 — Concept explainer with interactive demo

**Triggered by**: "explain consistent hashing", "how does CRDT work", "show me
how SSE works", "what's the intuition behind backpressure".

**Structure**:

- Two-column layout: main content (left) + sidebar TOC (right, sticky)
- eyebrow + h1 + lead paragraph
- Section: the problem (why this matters)
- Section: the demo — interactive panel with inline SVG visualization +
  control row (sliders, buttons). The visualization must be inline SVG with
  smooth transitions.
- Section: the mental model (key terms with `.term` dotted-underline; short
  paragraphs)
- Section: where it shows up in practice (real systems that use it)

**Open before drafting**: [`gallery/15-research-concept-explainer.html`](gallery/15-research-concept-explainer.html),
[`gallery/14-research-feature-explainer.html`](gallery/14-research-feature-explainer.html)

---

## P5 — Code review / PR walkthrough

**Triggered by**: "review this PR", "summarize the changes", "what does this
branch do", "is this diff safe to merge".

**Structure**:

- Header card with repo path, PR title, author avatar, branch arrow, +/- stats
- Section: summary (one paragraph)
- Section: findings as cards, each card with severity dot (olive / clay / rust)
  + finding title + affected file path (mono) + code snippet
- Section: tests / coverage delta
- Optional approval recommendation callout

**Open before drafting**: [`gallery/03-code-review-pr.html`](gallery/03-code-review-pr.html),
[`gallery/17-pr-writeup.html`](gallery/17-pr-writeup.html)

---

## P6 — Architectural / code understanding

**Triggered by**: "explain this codebase", "how does the auth flow work in this
repo", "map out the data layer", "what are the moving parts of X".

**Structure**:

- Header + lead
- Inline SVG diagram showing modules and their relationships (boxes + arrows)
- Section per module: module name as h2, file path in mono, what it does in
  prose, list of public surface (exports, endpoints)
- Optional sequence diagram (also inline SVG) for a key flow

**Open before drafting**: [`gallery/04-code-understanding.html`](gallery/04-code-understanding.html),
[`gallery/13-flowchart-diagram.html`](gallery/13-flowchart-diagram.html)

---

## P7 — Design system / token reference

**Triggered by**: "show me our color tokens", "list the design system", "what
fonts do we use", "build a token reference".

**Structure**:

- Header + lead
- Color swatches as a grid: each swatch is a card with the color filling the
  top half + hex/name below
- Type specimens: serif / sans / mono, each shown at multiple sizes
- Spacing scale visualized as bars of increasing width
- Component examples (buttons, cards, pills) shown as live HTML

**Open before drafting**: [`gallery/05-design-system.html`](gallery/05-design-system.html),
[`gallery/06-component-variants.html`](gallery/06-component-variants.html)

---

## P8 — Exploration / option laydown

**Triggered by**: "what are 3 ways to do X", "give me a few approaches",
"brainstorm options for Y", "show me visual directions for the landing page".

**Structure**:

- Header + lead explaining the constraint
- Either:
  - For **visual** exploration: 2-3 large preview cards, each showing a mocked
    UI inside (SVG or HTML mock)
  - For **code/approach** exploration: 2-3 stacked sections, each with name +
    pros/cons table + code snippet
- Final "recommended" callout

**Open before drafting**: [`gallery/01-exploration-code-approaches.html`](gallery/01-exploration-code-approaches.html),
[`gallery/02-exploration-visual-designs.html`](gallery/02-exploration-visual-designs.html)

---

## P9 — Incident or postmortem

**Triggered by**: "write up the incident", "what happened on Tuesday", "draft
a postmortem".

**Structure**:

- Header with severity pill (rust for SEV1/2, clay for SEV3)
- Summary band: detected time, mitigated time, resolved time, customer impact
- Timeline: vertical timeline with timestamps, what happened, who acted
- Root cause section
- Action items as a table with owner and due date

**Open before drafting**: [`gallery/12-incident-report.html`](gallery/12-incident-report.html)

---

## P10 — Prototype interaction / micro-app

**Triggered by**: "show me a working prototype", "make me a triage board /
settings panel / prompt tuner", "I want to play with it".

**Structure**:

- Minimal header (the app itself is the focus)
- Full-width app surface with realistic UI: side nav, columns, list rows,
  modals
- Inline JS for interaction (drag, toggle, edit) — keep under 80 lines
- Sample data hardcoded in JS

**Open before drafting**: [`gallery/18-editor-triage-board.html`](gallery/18-editor-triage-board.html),
[`gallery/19-editor-feature-flags.html`](gallery/19-editor-feature-flags.html),
[`gallery/20-editor-prompt-tuner.html`](gallery/20-editor-prompt-tuner.html),
[`gallery/08-prototype-interaction.html`](gallery/08-prototype-interaction.html)

---

## P11 — Slide deck

**Triggered by**: "make slides", "turn this into a deck", "I want to present
this".

**Structure**:

- Full-viewport slides, one per `<section>`
- Arrow-key navigation (inline JS)
- Per-slide layout: title (serif), subtitle, body — left-aligned, max-width 900px centered
- A subtle slide number in the corner
- Larger type: title 56-72px, body 22-26px

**Open before drafting**: [`gallery/09-slide-deck.html`](gallery/09-slide-deck.html)

---

## P12 — Diagram / flowchart

**Triggered by**: "draw the flow", "diagram this", "what's the architecture",
"show me how requests flow through".

**Structure**:

- A single inline SVG occupying most of the page
- Boxes with mono labels, arrows with optional condition labels
- Legend at the bottom explaining color codes
- Brief prose above the diagram setting context, brief notes below explaining
  specific edges

**Open before drafting**: [`gallery/13-flowchart-diagram.html`](gallery/13-flowchart-diagram.html),
[`gallery/10-svg-illustrations.html`](gallery/10-svg-illustrations.html)

---

## P13 — Browseable index

**Triggered by**: "show me a gallery of", "list of X with thumbnails", "an
index page for the project", "all the components we have".

**Structure**:

- Masthead with a hero eyebrow + h1 (often italicized accent word in clay)
  and a short intro paragraph
- Categorized sections, each prefixed with a clay-colored mono index number
  (01, 02, …) and a count pill
- Card grid (`repeat(auto-fill, minmax(316px, 1fr))`) below each section
- Each card: a hand-drawn SVG thumbnail (height ~132px) on top, then a serif
  title + short description + a mono file path footer with an arrow icon
- Hover state: card lifts (`translateY(-3px)`), thumbnail background warms to
  oat, footer accent color changes to clay

**Open before drafting**: [`gallery/index.html`](gallery/index.html)

---

## Cross-cutting tips

- **The auto-pill** (`<span class="pill">auto-generated</span>` or
  `latest snapshot`) in the header signals "this page was generated for a
  specific moment." The reference gallery uses it on status and review pages.

- **The `prompt-box`** (gray-150 card showing the original user prompt or
  trigger) is a strong pattern for plan / write-up pages — it grounds the
  document in what was asked. See `gallery/16-implementation-plan.html` for
  the canonical version.

- **One inline SVG per page is often the difference** between a "page" and a
  "report". Even a small bar chart or a 4-box flow diagram dramatically lifts
  perceived effort. The gallery is full of small SVGs at ~600x180 to ~900x400.

- **When uncertain which pattern fits**: pick the pattern whose "content shape"
  line most closely matches the user's input, then `Read` the listed reference
  file. The gallery index in [`gallery.md`](gallery.md) lists every file with
  one-line concrete teasers so you can choose without opening multiple.
