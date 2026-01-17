# Collaboration Guide (Repo‑agnostic)

## Engineering Preferences
- Preserve architecture boundaries; avoid moving app logic into libs unless explicitly asked.
- Prefer minimal diffs and reuse existing workflows/activities/scripts over new ones.
- Avoid introducing new env vars/config unless necessary; prefer inline constants or existing config patterns.
- Keep interfaces simple: remove redundant params, avoid scattering mock values.
- When removing CLI/config params, also remove schema fields, runner args, and docs; make schemas strict when possible.
- Readability matters: avoid dense inline function calls; favor named helpers when logic is non‑trivial.
- Logging should be intentional and minimal; add debug logs only when requested.
- Respect “do‑not‑touch” areas or shared libs; ask before changing them.

## TypeScript / Type Safety
- Type safety first: avoid `as` casts when possible; prefer zod/explicit types.
- Prefer schema-level narrowing for `unknown` instead of helper wrappers or casts.
- Code style: avoid `for...of`, reduce `let`, prefer functional patterns and readable control flow.

## Data & Generated Modules
- For generated data modules, require a generator + verifier script; avoid manual edits.
- For large datasets, split into per-ID modules with a stable index order and sourcePath metadata.

## Testing Expectations
- Run relevant tests whenever possible; prioritize unit/CI‑critical checks.
- Before running tests, install module dev dependencies (e.g., `pip install -e "path[dev]"`) to avoid missing tools.
- If pre-commit/CI/lint/coverage gates exist (e.g., file-length limits), check or run them before committing to avoid late failures.
- If a logical gap needs tests, add them proactively.
- If tests can’t run (env/permissions), explain why and suggest alternatives.
- For long-running workers/e2e loops, capture runId/output paths and confirm whether to stop the worker afterward.
- Do not change or relax pre-commit/CI/lint/coverage gates to bypass failures unless the user explicitly authorizes config changes.

## Workflow Preferences
- Ask early about non‑modifiable files/dirs and required reuse targets.
- Check repo-specific AGENTS.md/OpenSpec instructions early; call out conflicts.
- When introducing new tool integrations, confirm directory/placement constraints first (e.g., no new top‑level folders) before creating files.
- Default to rebasing when integrating back to `main`; for small changes, it's OK to commit directly on `main` without creating a new branch.
- Default merge-back command: `git rebase main` (or `git pull --rebase` on `main`) before fast-forwarding, unless committing directly on `main` for small changes.
- When the user explicitly requests a brainstorm/design discussion, follow the "Brainstorming Ideas Into Designs" flow (one question at a time, 2–3 options with a recommendation, 200–300 word sections with validation, then doc/commit if requested).
- Clarify branch strategy (rebase/cherry‑pick/merge) before doing multi‑commit work.
- For long‑running workers/processes, ask whether to keep them running or stop afterward.
- Surface assumptions and risks explicitly; keep changes reversible.

## Output Format Preferences
- Provide concise summaries with concrete file paths.
- List the exact commands run and their outcomes.
- If a request could be interpreted in multiple ways (e.g., "merge" vs "apply"), restate the intended action in one sentence and ask for confirmation before proceeding.
- When suggesting next steps, keep them minimal and actionable.
- When touching Markdown, watch for markdownlint pitfalls (H1 on line 1, ordered list numbering).
