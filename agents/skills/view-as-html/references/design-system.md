# Design System — Anthropic-style HTML Output

The design tokens and component CSS below are the canonical Anthropic look used across the bundled
reference gallery ([`gallery/`](gallery/)). Copy directly into the `<style>` block of any HTML you
generate. The whole system fits in roughly 200 lines of CSS, which is the point — the visual
distinctiveness comes from consistent use of a small palette and a strict type stack, not from
volume.

## Contents

- **Why these specific values** — short rationale for the palette and type choices
- **Drop-in CSS** — the `:root` tokens and reset/typography/component CSS to paste into `<style>`
- **Component recipes** — paste-ready HTML for header, summary band, sections, table, callout
- **Sizing guidance** — body size, lead size, page max-width, padding
- **When to break the system** — what may deviate; what stays constant across deviations

## Why these specific values

- **Ivory background (`#FAF9F5`) instead of pure white** — pure white reads as default web. Ivory
  signals "considered" without being beige.
- **Slate near-black (`#141413`) instead of `#000`** — pure black on ivory is too harsh; near-black
  is the warm equivalent.
- **Clay (`#D97757`) as the single accent** — used for one-color callouts, accent rules, important
  numbers. The whole palette is built so that adding any *second* accent immediately looks wrong.
- **Serif headings, sans body, mono labels** — three roles, three families, never mix.
- **Border 1.5px** instead of 1px — slightly heavier than browser default, looks intentional
  without being heavy.

## Drop-in CSS — paste into every page

```css
:root {
  /* palette */
  --ivory:    #FAF9F5;
  --paper:    #FFFFFF;
  --slate:    #141413;
  --clay:     #D97757;
  --clay-d:   #B85C3E;
  --oat:      #E3DACC;
  --olive:    #788C5D;
  --rust:     #B04A3F;
  --sky:      #6A8CAF;
  --g100:     #F0EEE6;
  --g200:     #E6E3DA;
  --g300:     #D1CFC5;
  --g500:     #87867F;
  --g700:     #3D3D3A;

  /* type */
  --serif: ui-serif, Georgia, "Times New Roman", Times, serif;
  --sans:  system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  --mono:  ui-monospace, "SF Mono", Menlo, Monaco, Consolas, monospace;

  /* structural */
  --border:        1.5px solid var(--g300);
  --radius-panel:  12px;
  --radius-row:    8px;
  --radius-pill:   999px;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

html { scroll-behavior: smooth; }

body {
  background: var(--ivory);
  color: var(--g700);
  font-family: var(--sans);
  font-size: 15px;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  padding: 56px 24px 120px;
}

.page { max-width: 920px; margin: 0 auto; }

/* Headings — serif, weight 500, slight negative letter-spacing */
h1 {
  font-family: var(--serif);
  font-weight: 500;
  font-size: 38px;
  line-height: 1.15;
  letter-spacing: -0.012em;
  color: var(--slate);
}

h2 {
  font-family: var(--serif);
  font-weight: 500;
  font-size: 24px;
  letter-spacing: -0.01em;
  color: var(--slate);
}

h3 {
  font-family: var(--serif);
  font-weight: 500;
  font-size: 19px;
  color: var(--slate);
}

p { max-width: 680px; margin-bottom: 12px; }
a { color: var(--clay); text-decoration-color: var(--oat); text-underline-offset: 3px; }
a:hover { text-decoration-color: var(--clay); }
code, pre { font-family: var(--mono); font-size: 13px; }

/* The most-used micro-component: eyebrow / mono-uppercase label */
.eyebrow {
  font-family: var(--mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--g500);
  margin-bottom: 10px;
}

/* Pill / chip */
.pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-family: var(--mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  background: var(--g100);
  border: var(--border);
  border-radius: var(--radius-pill);
  padding: 4px 10px;
  color: var(--g500);
}

/* Generic card — the workhorse for nearly every layout */
.card {
  background: var(--paper);
  border: var(--border);
  border-radius: var(--radius-panel);
  padding: 22px 24px;
}

/* Summary band — N stat cards in a row */
.summary-band {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 48px;
}
@media (max-width: 720px) {
  .summary-band { grid-template-columns: repeat(2, 1fr); }
}
.stat-card {
  background: var(--paper);
  border: var(--border);
  border-radius: var(--radius-panel);
  padding: 20px 22px 18px;
}
.stat-card .label {
  font-family: var(--mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--g500);
  margin-bottom: 8px;
}
.stat-card .value {
  font-family: var(--serif);
  font-size: 38px;
  font-weight: 500;
  line-height: 1;
  color: var(--slate);
}
.stat-card .delta {
  font-family: var(--mono);
  font-size: 11px;
  margin-top: 6px;
  color: var(--g500);
}
.stat-card .delta.up { color: var(--olive); }
.stat-card .delta.down { color: var(--rust); }
/* For emphasis, add a clay border-left */
.stat-card.accent { border-left: 4px solid var(--clay); padding-left: 19px; }

/* Card grid — for browseable collections */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

/* Section chrome */
section { margin-bottom: 56px; }
.sec-head {
  display: flex;
  align-items: baseline;
  gap: 14px;
  margin-bottom: 8px;
}
.sec-head .num {
  font-family: var(--mono);
  font-size: 12px;
  background: var(--oat);
  color: var(--slate);
  padding: 3px 9px;
  border-radius: 8px;
}
.sec-intro {
  font-size: 14.5px;
  color: var(--g500);
  max-width: 720px;
  margin-bottom: 24px;
}

/* Table — thin lines, hover state, mono first column when appropriate */
table.data {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  background: var(--paper);
  border: var(--border);
  border-radius: var(--radius-panel);
  overflow: hidden;
}
table.data thead th {
  text-align: left;
  font-family: var(--sans);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--g500);
  background: var(--g100);
  padding: 12px 16px;
  border-bottom: 1px solid var(--g300);
}
table.data tbody td {
  padding: 13px 16px;
  border-bottom: 1px solid var(--g100);
  font-size: 14px;
  vertical-align: middle;
}
table.data tbody tr:last-child td { border-bottom: none; }
table.data tbody tr:hover { background: var(--ivory); }

/* Callout / aside — colored panel for "note", "warning", "result" */
.callout {
  background: var(--oat);
  border-radius: var(--radius-panel);
  padding: 18px 22px;
  font-size: 14.5px;
}
.callout .callout-label {
  font-family: var(--mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--g700);
  margin-bottom: 6px;
}

/* Dotted-underline term — for inline concept callouts */
.term {
  border-bottom: 1.5px dotted var(--clay);
  cursor: help;
  color: var(--slate);
}

/* Code block — dark slate panel */
.code-block {
  background: var(--slate);
  border-radius: var(--radius-panel);
  padding: 18px 20px;
  overflow-x: auto;
}
.code-block pre {
  font-family: var(--mono);
  font-size: 12.5px;
  line-height: 1.65;
  color: #E8E6DE;
}
.code-block .kw  { color: var(--clay); }
.code-block .str { color: var(--olive); }
.code-block .cm  { color: var(--g500); }
.code-block .fn  { color: #C9B98A; }

/* Vertical timeline / milestone list */
.timeline { display: flex; flex-direction: column; gap: 0; }
.milestone {
  display: grid;
  grid-template-columns: 120px 28px 1fr;
  gap: 0 18px;
}
.milestone .when {
  text-align: right;
  font-family: var(--mono);
  font-size: 12px;
  color: var(--g500);
  padding-top: 4px;
}
.milestone .dot-col { display: flex; flex-direction: column; align-items: center; }
.milestone .dot {
  width: 14px; height: 14px;
  border-radius: 50%;
  background: var(--paper);
  border: 3px solid var(--clay);
  margin-top: 4px;
}
.milestone .dot.done { background: var(--olive); border-color: var(--olive); }
.milestone .line { width: 2px; flex: 1; background: var(--g300); margin: 4px 0; }
.milestone:last-child .line { display: none; }
.milestone .body { padding-bottom: 32px; }

/* Footer */
footer {
  margin-top: 64px;
  padding-top: 20px;
  border-top: 1px solid var(--g300);
  font-family: var(--mono);
  font-size: 12px;
  color: var(--g500);
}
```

## Component recipes (paste-ready HTML snippets)

### Header with eyebrow + title + lead

```html
<header>
  <div class="eyebrow">Research note · 2026-05-25</div>
  <h1>Consistent hashing — an interactive explainer</h1>
  <p class="lead">A short tour of how Cassandra and DynamoDB place keys onto a ring of nodes.</p>
</header>
```

### Summary band (4 stat cards)

```html
<section class="summary-band">
  <div class="stat-card">
    <div class="label">Shipped</div>
    <div class="value">12</div>
    <div class="delta up">+3 vs last week</div>
  </div>
  <div class="stat-card accent">
    <div class="label">In review</div>
    <div class="value">5</div>
    <div class="delta">unchanged</div>
  </div>
  <!-- ... -->
</section>
```

### Section with numbered head

```html
<section>
  <div class="sec-head">
    <span class="num">01</span>
    <h2>The problem</h2>
  </div>
  <p class="sec-intro">A two-line context paragraph belongs here.</p>
  <!-- body content -->
</section>
```

### Comparison table

```html
<table class="data">
  <thead>
    <tr><th>Dimension</th><th>Pinia</th><th>Zustand</th></tr>
  </thead>
  <tbody>
    <tr><td>Store definition</td><td>defineStore</td><td>create</td></tr>
    <tr><td>Reactivity</td><td>Proxy-based</td><td>Subscription</td></tr>
  </tbody>
</table>
```

### Callout / aside

```html
<aside class="callout">
  <div class="callout-label">Result</div>
  At 256 vnodes per real node, key redistribution stays under 4% after a single failure.
</aside>
```

## Sizing guidance

- Body text: 15px / line-height 1.6
- Lead paragraph (under h1): 16.5px / line-height 1.55
- Small print (footer, captions): 12-13px
- Mono labels: 11-12px with letter-spacing 0.06-0.08em
- Page max-width: 860-1120px depending on whether there's a sidebar (920px is a safe default)
- Content padding: 56px top / 24-32px sides / 120px bottom

## When to break the system

The gallery does occasionally deviate — [`gallery/09-slide-deck.html`](gallery/09-slide-deck.html)
uses larger type and full-bleed layouts;
[`gallery/18-editor-triage-board.html`](gallery/18-editor-triage-board.html) uses a column-flow
Kanban grid. Deviation is fine **when the content shape demands it** — slides want fullscreen,
kanban wants columns. But the palette, the type families, and the mono-label signature stay the
same across every deviation. That consistency is what makes 21 different page types still feel
like one product.
