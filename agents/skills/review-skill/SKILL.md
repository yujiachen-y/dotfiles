---
name: review-skill
description: >
  Audits an existing skill against the official Anthropic Agent Skills best practices document
  (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), then produces
  a categorized report — Must Fix (explicit warnings violated), Should Consider (acceptable but
  improvable), and Already Passing — with file:line citations and concrete fixes. Triggers when the
  user says "/review-skill", "review this skill", "audit my skill", "check this skill against best
  practices", "is this skill following best practices", "对这个 skill 做个 review", "审查一下这个
  skill", "skill 是不是符合最佳实践". Also applies when the user references a skill directory
  (e.g. `agents/skills/foo` or `~/.claude/skills/bar`) and asks for sanity check, quality pass, or
  evaluation against documented best practices — even without naming the practices doc explicitly.
---

# Review Skill

Compare a target skill against the **current** Anthropic Agent Skills best practices, and produce a
short, categorized, actionable report. The best practices document is the source of truth; this
skill exists to apply it systematically rather than from memory.

## Workflow

1. **Locate the target skill**

   The user usually names it ("review the lint-init skill", "audit `~/.claude/skills/foo`",
   "check the one we just made"). Resolve to an absolute path to the skill directory containing
   `SKILL.md`. If they're vague, ask once which skill.

   If the directory has no `SKILL.md`, that itself is the first finding — report it and stop.

2. **Fetch the latest best practices document**

   Use `WebFetch` with URL:

   ```
   https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
   ```

   Why every time: the doc is canonical and Anthropic updates it as the Skills product evolves.
   Reviewing against a months-old snapshot can miss new requirements. The fetch is ~3 seconds and
   is worth the latency for an audit.

   If the fetch fails (offline, blocked, network error), fall back to
   [`references/best-practices-checklist.md`](references/best-practices-checklist.md), which is a
   snapshot of the doc plus the check procedure for each rule. Tell the user you're using the
   offline fallback and note the snapshot date.

3. **Read every file in the target skill**

   At minimum: `SKILL.md`. Also any `references/*.md`, `assets/*`, `scripts/*` — they all factor
   into the review (long files need TOC, scripts must justify constants, etc). Use `find` or
   `ls -R` first if the structure isn't obvious.

4. **Run the checklist**

   [`references/best-practices-checklist.md`](references/best-practices-checklist.md) has every rule
   from the doc, grouped by category, each with a `severity` (explicit-warning vs recommendation)
   and a `how to check` line. Walk through it top to bottom against the target skill.

   When you've fetched the live doc, treat it as primary and use the checklist for the *how to
   check* mechanics. If the live doc has rules the checklist doesn't cover, surface them — and see
   the "Self-update" section below.

5. **Categorize findings into three buckets**

   - **必修 / Must Fix** — the skill violates something the doc states as an explicit warning
     ("Always write in third person", "Never use Windows-style paths", "Keep references one level
     deep"). These are clear contractual breaks.

   - **可改 / Should Consider** — the skill is doing something the doc lists as acceptable but
     names a preferred alternative (e.g. action-oriented name when gerund is preferred), or the
     doc says "consider X" rather than "must X". These are judgment calls.

   - **已过关 / Already Passes** — items the skill handles correctly. Listing these is not filler —
     it tells the user what *not* to touch and confirms the audit was thorough.

6. **Output the report**

   Default to markdown. Reuse this template (it mirrors the format the user already saw and liked):

   ````markdown
   ## 必修（违反 best practices 的 explicit warnings）

   ### 1. <short title>

   文档原话：*"<exact quote from the doc>"*

   - 现在：`<file path>:<line>` 的写法是 `<quote>`
   - 应改：`<concrete suggested replacement>`

   ### 2. ...

   ## 可改（符合 acceptable practice 但有更好做法）

   ### N. <short title> — <one-line rationale>

   - 现在：...
   - 建议：...

   ## 已过关

   - <bullet list of items the skill handles correctly>

   ## 建议动作

   按 severity 排，建议先做必修 #1、#2 ... 这些 explicit warnings。可改项可以择机处理。
   ````

   If the user explicitly asks for an HTML view, defer to `/view-as-html` rather than rendering
   inline — review reports are structured enough that they fit P5 (code-review-style) in that
   skill's pattern table.

7. **Offer to apply the fixes**

   After the report, ask: "Want me to fix the Must Fix items directly?" Don't auto-apply — the user
   might want to look at the diff first, or some fixes (renaming a skill, restructuring
   directories) have ripple effects.

## How to do the comparison well

- **Cite, don't paraphrase.** Every Must Fix finding must include the doc's exact wording. The
  doc is the contract; paraphrasing weakens the finding and invites push-back. Quoting also makes
  it obvious when the doc has changed.

- **Show the offending text with `file:line`.** "Description uses imperative" is weaker than
  "`SKILL.md:4` reads `Render the response...` — should be `Renders the response...`".

- **Don't invent rules.** If something feels wrong but the doc doesn't say so, either skip it or
  put it in a separate "out-of-scope observations" section at the end. The whole point of this
  skill is grounding feedback in the document.

- **Self-review is allowed.** If the user asks you to review `review-skill` itself, do it the same
  way — don't skip on the grounds of conflict of interest. Add a one-line note that you're
  reviewing yourself.

## Self-update: keeping the checklist fresh

The best practices document evolves. The local checklist in `references/` is a snapshot — useful
for offline use and as a structured "how to check" companion, but it can drift from the live doc.

**Each time this skill runs**, after fetching the live doc, do a freshness check on
`references/best-practices-checklist.md`:

1. Read the file's frontmatter `last-synced:` field.
2. Compute days since that date (today is in `# currentDate` at the top of every Claude session).
3. **If days-since-last-synced > 30**, do a sync pass:
   - Diff the live doc against the checklist's coverage (categories, rules, examples).
   - If the live doc has new rules, missing examples, or revised wording the checklist doesn't
     reflect, update the checklist file and bump `last-synced:` to today.
   - Mention to the user: *"The checklist hadn't been synced in N days — I refreshed it and added
     <items>."*
4. If days-since-last-synced ≤ 30, skip this step quietly.

**Why a 30-day window**: too short and every invocation incurs maintenance cost; too long and the
checklist rots silently. 30 days is approximately one product-update cadence and short enough that
drift stays small.

If the live doc is unreachable (offline), skip the freshness check — don't mark the checklist as
synced based on inability to verify.

## Output style guidance

- Be terse. Each Must Fix item is one paragraph + one fix; don't expand.
- Don't over-explain why the doc says what it says — quote it and move on. Reviewers want
  findings, not a recap of the doc.
- The "已过关" list can be a flat bullet list; don't write paragraphs for the items that pass.
- End with a "建议动作" line so the user has a clear next step.

## When to suggest re-running the review

After fixing Must Fix items, suggest the user run `/review-skill` again to confirm the changes
didn't introduce new issues (e.g. compressing SKILL.md may take it below 500 lines but introduce
broken cross-references). Each invocation is cheap; iterating until clean is the cycle this skill
is designed for.
