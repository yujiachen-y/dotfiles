---
name: dev
description: Personal end-to-end development pipeline. Drives a feature or fix from intent to reviewed code through a fixed, gated sequence — align → design → build-vs-buy → enumerate tests → implement → review — and delegates implementation to a subagent so the orchestrator's context stays clean. Explicit-invocation only; use when the user runs /dev or asks to run the dev pipeline. Not for ad-hoc one-off edits.
disable-model-invocation: true
---

# /dev — orchestrated development pipeline

Drive a feature or fix from intent to reviewed code through a fixed sequence of
specialist skills. You are the **orchestrator**: you own the sequence and the
gates, you invoke each sub-skill in turn, and you hand the heavy implementation
work to a subagent so your own context stays focused on coordination rather than
filling up with file reads and red-green loops.

Run the steps in order. Don't skip or reorder — the sequence is the value: it's
what stops an agent from building the wrong thing well. Stop at each **gate** for
the user's sign-off before spending effort on the next step.

## Step 0 — Preflight: choose the harness checklist

/dev is an interactive pipeline, not single-prompt automation. A gate can stop
the pipeline while the conversation stays open for repairs, user confirmation, or
an explicit change to the run's requirements.

Before doing any work, identify the current agent harness and read the matching
checklist directly from `SKILL.md`:

| Harness | Checklist |
|---|---|
| MiniMax Code | [MiniMax Code checklist](references/minimax-code-checklist.md) |
| Claude Code | [Claude Code checklist](references/claude-code-checklist.md) |
| Codex | [Codex checklist](references/codex-checklist.md) |

If the current harness is not listed, STOP and ask the user to add or approve a
new harness checklist. Do not guess, and do not infer one harness's readiness
from another harness's config.

The selected checklist owns the exact verification steps, provider names, and
repair commands for that harness. Do not run a generic dependency script; no
single script is portable across every agent harness. If any required capability
or config check fails, STOP the pipeline, report the failed check and repair
needed, and wait for the user to fix it or explicitly waive that requirement for
this run.

The selected checklist is not only preflight; it also owns the concrete skill
graph. For each step, invoke the checklist's listed skill or provider. Do not
replace it with an inline imitation.

Every harness checklist must cover these required capabilities: subagent
delegation, intent alignment, design, build vs. buy, test scenarios, TDD, review,
Ponytail, and library docs. Harness-specific checks may add rows, but they do
not replace the required capability set.

## The pipeline

Copy this checklist into your response and tick items off as you go:

```
- [ ] Step 0: harness preflight passed
- [ ] 1. Align intent — user confirms the spec
- [ ] 2. Design seams
- [ ] 3. Build vs. buy
- [ ] 4. Enumerate test scenarios — user approves the scenario contract file
- [ ] 5. Implement via subagent
- [ ] 6. Review
```

### 1. Align — intent alignment
Invoke the intent-alignment capability named by the selected harness checklist
and let it interrogate the request until what's being built is unambiguous.
Misalignment is the most expensive failure mode; this is the cheapest place to
catch it.
Output an **approved spec**.
**Gate:** the user confirms the resulting spec before you move on.

### 2. Design the seams
Invoke the design capability named by the selected harness checklist to decide
where the module boundaries go and what stays behind a small interface. Produce a
short **design note** naming the seams. If the change makes a durable
architecture decision, write or update an ADR using the project's existing ADR
location and naming convention, then record the ADR path. Do not create an ADR
just to have a place for test scenarios.

### 3. Build vs. buy
For each non-trivial capability the design needs, invoke the build-vs-buy
capability named by the selected harness checklist to decide: reach for a mature
library, or write a small amount of code inline? This is where "use a real
framework instead of hand-rolling a crude version" gets enforced; it's the
deliberate counterweight to ponytail's lean toward less code.
Record **dependency decisions**. Once a library is chosen, invoke the library-docs
capability named by the selected harness checklist to confirm current, idiomatic
usage and record **docs notes**. If no library is chosen, record "no library docs
needed" as the docs note.

### 4. Enumerate test cases
Invoke the test-scenario capability named by the selected harness checklist to
produce a scenario contract: happy paths, edge cases, error handling — *before
any code is written*.
Give it the inputs the selected harness checklist specifies for that capability — at
minimum the approved spec and acceptance criteria (step 1) and the design context
(design note, dependency decisions, docs notes, constraints, and risk areas).

Write the approved scenarios to a scenario contract file. Prefer placing it next
to the ADR from step 2:

`<adr-path-without-.md>.test-scenarios.md`

Example:

`docs/adr/0007-google-oauth-login.md`
`docs/adr/0007-google-oauth-login.test-scenarios.md`

If step 2 did not produce or update an ADR, use:

`<target-project-root>/docs/dev/<run-slug>/test-scenarios.md`

`<target-project-root>` is the repo or package root that owns the files under
change, not the agent workspace root. If that root or the ADR path is ambiguous,
ask before writing. `<run-slug>` is a short kebab-case name for this feature or
fix, such as `csv-quoting` or `google-oauth-login`.

This file is the shared source of truth for implementation and review. Record
the exact path and use this minimum shape:

| ID | Scenario | Given / When / Then | Type | Priority | Status | Evidence |
|---|---|---|---|---|---|---|
| TS-1 | Short name | Given ... / When ... / Then ... | unit/integration/e2e | P0/P1/P2 | todo/covered/skipped | test path, command, or skip reason |

Enumerating is not the same as writing all the tests first. The list is the plan;
the tests themselves get written one at a time during implementation. Writing
every test up front ("horizontal slicing") produces tests of imagined behavior
that pass when things break — so keep this step a scenario contract, not an
executable test file.
**Gate:** the user approves and prioritizes the scenario contract file. This is
the last gate before code.

### 5. Implement — delegate to a subagent
Hand implementation to a **subagent** using the delegation mechanism named by the
selected harness checklist. Do this for a concrete reason: the red-green loop
reads files, runs tests, and iterates over many turns — a large amount of tokens.
Keeping that out of your context means you remain a clean orchestrator who can
still see the whole plan, instead of a thread clogged with implementation detail.

Spawn the subagent with everything it needs to work cold — it has none of this
conversation's context:
- the approved spec (step 1)
- the design note and seams (step 2)
- the build-vs-buy decisions and chosen libraries (step 3)
- the docs notes (step 3)
- the exact scenario contract path from step 4
- TDD discipline: "Invoke the TDD capability named by the selected harness
  checklist. Write one failing test for one scenario, write the minimal code to
  pass it, repeat down the list. Never write all the tests first."
- a request to update the scenario contract file with `covered`/`skipped` status
  and evidence as scenarios are implemented or deliberately deferred
- a request to **return a concise summary**: what was built, which scenarios are
  covered, how to run the tests, and anything deliberately deferred.

Do **not** write feature code yourself. Launch the subagent, then review what
comes back.

**If you cannot spawn a subagent in this environment, STOP — do not implement
inline and do not continue.** The clean-orchestrator guarantee is the whole
reason this step exists; quietly doing the work in the main thread would break
exactly what /dev is for. Report that delegation isn't available and ask the user
to fix the environment or explicitly waive the subagent requirement for this run.
Wait for their decision.

### 6. Review — delegate review, then decide
Spawn a **review subagent** using the delegation mechanism named by the selected
harness checklist. Give it the approved spec, design note, build-vs-buy
decisions, the exact scenario contract path from step 4, implementation summary,
changed files, and validation commands. The review subagent must invoke the
review capability named by the selected harness checklist.

The review subagent may run controlled validation, including tests that write to
local, disposable, or project-approved state such as test databases, temp dirs,
fixtures, caches, or generated artifacts. It must not edit source files or
perform irreversible or destructive side effects.

Ask the review subagent to return findings with evidence, validation run,
confidence, whether each finding is worth fixing now, and the suggested fix
scope. The orchestrator reviews those findings before acting on them.

If no finding is valid and worth fixing now, report the final conclusion. If a
finding is valid and worth fixing now, spawn a separate **fix subagent**. Scope it
to only the approved findings, but brief it to work cold the same way the
implementation subagent was (step 5): the approved spec, the design note, the
relevant changed files and how to run the tests, the exact findings to fix, and the
TDD discipline (invoke the TDD capability named by the selected harness checklist —
a failing test first, then the minimal change). Do not fix in the main thread, and
do not let the review subagent edit code.

## Operating principles
- **Fixed order, hard gates.** Don't let momentum skip a gate; the user's sign-off
  at each transition is what keeps the work aimed correctly.
- **Fail closed.** /dev is for the builder. If a required capability is missing,
  ambiguous, broken, or cannot be verified, stop and report the exact failed
  check plus the repair needed. Do not emulate missing capabilities inline.
- **One concern per gate.** Confirm the current artifact (spec, design, decisions,
  scenario list) before opening the next step.
- **Stay lean.** Orchestrate and summarize; delegate the heavy lifting. Your value
  here is holding the thread end-to-end, which you can only do if your context
  doesn't fill with implementation noise.
