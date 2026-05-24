---
last-synced: 2026-05-25
source-url: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
---

# Best Practices Checklist — Snapshot

This file is the offline / structured companion to the live best-practices doc. Each rule has:
- The doc's exact wording (or a tight paraphrase when the rule is spread across the doc)
- A severity tag: `must-fix` = explicit warning / hard requirement; `should-consider` = preferred
  but doc names it acceptable to deviate
- A `how to check` line so a reviewer can mechanically verify

When the live doc has been fetched successfully, use this file for the *how to check* mechanics
and treat the live doc as the source of truth. If the live doc and this file disagree, the live
doc wins — and that disagreement is a signal to run a sync pass (see SKILL.md "Self-update").

## Contents

- **C1. Frontmatter — name** — naming rules and schema validation
- **C2. Frontmatter — description** — third person, key terms, what + when
- **C3. Body length & progressive disclosure** — 500-line budget, file references, depth, TOC
- **C4. Content quality** — concision, consistent terminology, time-sensitive info, examples
- **C5. Workflows & feedback loops** — clear steps, checklists, validator loops
- **C6. Common anti-patterns** — Windows paths, too many options, vague descriptions
- **C7. Scripts** (only if the skill has a `scripts/` directory)
- **C8. MCP tool references** (only if the skill mentions MCP tools)
- **C9. Testing & evals** (recommendations, hard to verify statically)

---

## C1. Frontmatter — `name`

### C1.1 Character set

Rule: `name` must contain only lowercase letters, numbers, and hyphens. Max 64 chars.
Severity: **must-fix** (schema-level — the platform rejects invalid names).
How to check: regex `^[a-z0-9-]{1,64}$` against the `name:` value in SKILL.md frontmatter.

### C1.2 Reserved words

Rule: `name` cannot contain "anthropic" or "claude" (case-insensitive).
Severity: **must-fix** (schema validation).
How to check: case-insensitive substring search on the name value.

### C1.3 No XML in name

Rule: `name` cannot contain XML tags.
Severity: **must-fix**.
How to check: look for `<` or `>` characters in the name.

### C1.4 Gerund form preferred

Rule from doc: *"Consider using gerund form (verb + -ing) for Skill names ... Acceptable
alternatives: Noun phrases, Action-oriented"*.
Severity: **should-consider** — the doc explicitly accepts non-gerund forms.
How to check: does the name end in `-ing` (gerund), or is it a noun phrase / action verb?
Recommendation only — don't flag noun phrases as Must Fix.

### C1.5 No vague names

Rule: avoid names like `helper`, `utils`, `tools`, `documents`, `data`, `files`.
Severity: **should-consider** (heuristic).
How to check: substring match against that list. If the name is *exactly* one of those, flag it.

---

## C2. Frontmatter — `description`

### C2.1 Non-empty, max 1024 chars, no XML

Rule: `description` is non-empty, max 1024 characters, cannot contain XML tags.
Severity: **must-fix** (schema validation).
How to check: count chars in the description; scan for `<` or `>`.

### C2.2 Third person, not first or second

Rule from doc, with explicit warning: *"Always write in third person. The description is injected
into the system prompt, and inconsistent point-of-view can cause discovery problems."* Doc gives:
- ✅ "Processes Excel files and generates reports"
- ❌ "I can help you process Excel files"
- ❌ "You can use this to process Excel files"

Severity: **must-fix**.
How to check: scan the description for first-person ("I ", "I'll", "my", "we", "our", "us") and
second-person imperatives without subject ("Use this to", "Render", "Generate" as first word of
sentences). The trickiest case is **imperative verbs as sentence-starters** ("Render the
response..." reads as instruction). Convert to gerund or "Renders / Generates / Produces ...".

### C2.3 What + when both present

Rule from doc: *"Be specific and include key terms. Include both what the Skill does and specific
triggers/contexts for when to use it."*
Severity: **must-fix** (the doc says descriptions without trigger phrases cause discovery failures).
How to check: does the description contain (a) a verb describing the skill's action and (b) a
"Use when ..." / "Triggers when ..." / "Applies to ..." style clause with example user phrases?

### C2.4 Not vague

Rule: avoid `description: Helps with documents` / `Processes data` / `Does stuff with files`.
Severity: **must-fix** (the doc names these as anti-patterns).
How to check: is the description under ~15 words and lacking concrete terms (file types, actions,
contexts)?

### C2.5 "Pushy" enough to avoid undertriggering

Rule from skill-creator: skills tend to undertrigger; descriptions should include enough trigger
phrases and contexts to be "pushy" — e.g. "even if they don't explicitly ask for X".
Severity: **should-consider**.
How to check: does the description include synonyms / variant phrasings the user might use? Bonus
points for non-English triggers when the user works in multiple languages.

---

## C3. Body length & progressive disclosure

### C3.1 SKILL.md body under 500 lines

Rule from doc: *"Keep SKILL.md body under 500 lines for optimal performance. If your content
exceeds this, split it into separate files using the progressive disclosure patterns described
earlier."*
Severity: **must-fix** at 500+; **should-consider** if approaching (450+).
How to check: `wc -l <skill-path>/SKILL.md` minus frontmatter lines.

### C3.2 References one level deep from SKILL.md

Rule from doc, with explicit warning: *"Keep references one level deep from SKILL.md. All
reference files should link directly from SKILL.md to ensure Claude reads complete files when
needed."* Anti-example: `SKILL.md → A.md → B.md`.
Severity: **must-fix**.
How to check: grep markdown links `[...](xxx.md)` in every reference file; flag any link to
another file in `references/`. Caveat: a *textual mention* of another file ("see also gallery.md")
that isn't a markdown link is OK — the doc's concern is about Claude following nested links and
doing partial reads.

### C3.3 Long reference files have a TOC

Rule from doc: *"For reference files longer than 100 lines, include a table of contents at the
top. This ensures Claude can see the full scope of available information even when previewing
with partial reads."*
Severity: **must-fix** for any reference file > 100 lines without TOC.
How to check: `wc -l references/*.md`; for files > 100 lines, look for a `## Contents` (or `Table
of contents`) section in the first ~30 lines.

### C3.4 Forward slashes in all paths

Rule from doc, with explicit warning: *"Always use forward slashes in file paths, even on Windows."*
Severity: **must-fix**.
How to check: grep for backslash in any file path (`\`) in SKILL.md and references. Be careful
not to false-positive on escape sequences in code blocks.

### C3.5 Reference file naming is descriptive

Rule from doc: *"Name files descriptively: use names that indicate content: `form_validation_rules.md`,
not `doc2.md`."*
Severity: **should-consider**.
How to check: any reference filename like `doc1.md`, `notes.md`, `info.md`, `temp.md` — vague.

---

## C4. Content quality

### C4.1 Concise — every paragraph justifies its tokens

Rule from doc: *"Default assumption: Claude is already very smart ... Challenge each piece of
information: 'Does Claude really need this explanation?' 'Can I assume Claude knows this?' 'Does
this paragraph justify its token cost?'"*
Severity: **should-consider** (judgment).
How to check: scan SKILL.md for paragraphs that explain general programming concepts ("Python is a
language ...") or restate what Claude obviously knows. Flag for compression. Read the doc's
concise vs verbose PDF example.

### C4.2 No time-sensitive information

Rule from doc: *"Don't include information that will become outdated."* Anti-example: "Before
August 2025, use the old API."
Severity: **must-fix**.
How to check: grep for absolute dates ("2024", "2025", "August", "Q4"), version numbers, "deprecated
after / before", "if you're doing this in <year>". Time-sensitive content should live in a
collapsed `<details><summary>Legacy ...</summary>` section.

### C4.3 Consistent terminology

Rule from doc: *"Choose one term and use it throughout the Skill"*. Anti-example: mixing "API
endpoint" / "URL" / "API route" for the same concept.
Severity: **should-consider**.
How to check: pick 3-5 key nouns in the skill and grep for synonyms. Examples to scan: "endpoint"
vs "URL" vs "route"; "field" vs "box" vs "element"; "extract" vs "pull" vs "get".

### C4.4 Concrete examples, not abstract

Rule from doc's checklist: *"Examples are concrete, not abstract."*
Severity: **should-consider**.
How to check: examples in the skill should show actual values, file paths, and outputs — not
`<placeholder>` everywhere. If most examples are `foo / bar / baz` style, flag.

---

## C5. Workflows & feedback loops

### C5.1 Complex tasks have clear steps

Rule from doc: *"Break complex operations into clear, sequential steps."* The checklist pattern
(copyable progress checklist) is recommended for multi-step workflows.
Severity: **should-consider**.
How to check: does the skill have a multi-step workflow? If yes, are the steps numbered with
clear bodies? Is there a copyable checklist for the user to track progress?

### C5.2 Feedback loops for quality-critical tasks

Rule from doc: *"Common pattern: Run validator → fix errors → repeat. This pattern greatly
improves output quality."*
Severity: **should-consider**.
How to check: for skills that generate / modify content, is there a validation step the agent
should run before declaring done? If not, flag.

### C5.3 Setting appropriate degrees of freedom

Rule from doc: high-freedom (text instructions) vs medium (pseudocode) vs low (specific scripts).
Match specificity to fragility.
Severity: **should-consider** (judgment).
How to check: does the skill use rigid all-caps MUSTs / NEVERs where flexibility is fine? Or does
it leave fragile operations to free interpretation? Flag mismatches.

---

## C6. Common anti-patterns (cross-cutting)

### C6.1 Too many options without a default

Rule from doc: *"Don't present multiple approaches unless necessary. Bad: 'You can use pypdf, or
pdfplumber, or PyMuPDF, or pdf2image, or ...'. Good: provide a default with escape hatch."*
Severity: **should-consider**.
How to check: are there sections that list 4+ alternatives without recommending one?

### C6.2 Heavy-handed all-caps directives

Rule from skill-creator: *"If you find yourself writing ALWAYS or NEVER in all caps, or using
super rigid structures, that's a yellow flag — if possible, reframe and explain the reasoning."*
Severity: **should-consider**.
How to check: grep for ALL CAPS words in body: ALWAYS, NEVER, MUST, MUST NOT, DO NOT. Some are
load-bearing (e.g. quoting the doc's own "Always write in third person"); most can be reframed.

---

## C7. Scripts (only if the skill has a `scripts/` directory)

Skip this entire section if the target skill has no scripts.

### C7.1 Solve, don't punt

Rule from doc: *"When writing scripts for Skills, handle error conditions rather than punting to
Claude."* Doc gives a `try / except` example with explicit fallback.
Severity: **must-fix** for scripts that lack any error handling on operations that can fail.
How to check: read each script; does it catch / handle expected error cases (file missing, perms,
network)?

### C7.2 No voodoo constants

Rule from doc: *"Configuration parameters should also be justified and documented to avoid
'voodoo constants' (Ousterhout's law). If you don't know the right value, how will Claude
determine it?"* Anti-example: `TIMEOUT = 47` with no comment.
Severity: **must-fix** for unexplained numeric constants in scripts.
How to check: scan scripts for top-level numeric / string constants. Each one needs a comment
explaining the value.

### C7.3 Don't assume packages are installed

Rule from doc: *"Don't assume packages are available. Good: 'Install required package: pip install
pypdf'."*
Severity: **must-fix**.
How to check: scripts that import third-party packages must be accompanied by install instructions
in SKILL.md or a `requirements.txt` reference.

### C7.4 Make execution intent clear

Rule from doc: *"Make clear in your instructions whether Claude should: Execute the script ('Run
analyze_form.py to extract fields') or Read it as reference ('See analyze_form.py for the field
extraction algorithm')."*
Severity: **should-consider**.
How to check: when SKILL.md references a script, is the verb explicit (run vs read)?

---

## C8. MCP tool references (only if the skill mentions MCP tools)

### C8.1 Fully qualified tool names

Rule from doc: *"If your Skill uses MCP (Model Context Protocol) tools, always use fully qualified
tool names to avoid 'tool not found' errors. Format: ServerName:tool_name."*
Severity: **must-fix**.
How to check: grep for MCP tool mentions; each one should be `ServerName:tool_name` (e.g.
`GitHub:create_issue`, `BigQuery:bigquery_schema`).

---

## C9. Testing & evals (recommendations)

Most of these can't be statically verified — they're about process, not file contents. Mention
them at the end of the report if the user asks for testing-related findings.

### C9.1 At least 3 evals exist

Rule from doc's checklist: *"At least three evaluations created."*
Severity: **should-consider**.
How to check: is there an `evals/` directory with at least 3 entries?

### C9.2 Tested with Haiku / Sonnet / Opus

Rule from doc: *"Test your Skill with all the models you plan to use it with."*
Severity: **should-consider** (impossible to verify from files alone).
How to check: not statically verifiable. Mention as an optional next step.

---

## How to read the live doc when fetched

When `WebFetch` returns the doc, the structure is:

1. Core principles (concise; degrees of freedom; multi-model testing)
2. Skill structure (frontmatter; naming; descriptions; progressive disclosure; nested refs; TOCs)
3. Workflows and feedback loops
4. Content guidelines (time-sensitive; terminology)
5. Common patterns (template; examples; conditional workflow)
6. Evaluation and iteration
7. Anti-patterns
8. Advanced: skills with executable code (scripts; visual analysis; intermediate outputs)
9. Technical notes (YAML rules; token budgets)
10. Checklist for effective Skills (the doc's own final summary)

Map findings to this structure when citing — gives the user a path back to the doc section.
