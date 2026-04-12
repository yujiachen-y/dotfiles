# Collaboration Guide (Repo-agnostic)

## Priority
- Repo-local `AGENTS.md` (or equivalent) has priority.
- This file is a fallback for cross-repo work.
- If precedence is unclear, stop and confirm with the user.

## Engineering Defaults
- Keep diffs minimal and reuse existing workflows/scripts.
- Preserve architecture boundaries; do not move app logic into shared libs unless asked.
- Avoid new env vars/config unless necessary; prefer existing patterns.
- Keep interfaces simple; remove redundant params and avoid scattered mock values.
- When removing CLI/config params, also update schema fields, runner args, and docs.
- Keep code readable; avoid dense inline logic and add debug logging only when requested.
- Respect do-not-touch areas and shared libs.
- Prefer explicit types and schema-level narrowing; avoid `as` casts when possible.
- Prefer functional, readable control flow; avoid `for...of` and reduce mutable `let`.
- Before deep-diving into vendored/dependency source code, search the upstream repo's issues/PRs first for existing fix attempts and maintainer context.
- When modifying shared code paths that dispatch across multiple providers/backends, first enumerate all dispatch targets and confirm which ones the change should affect; gate by type/identity field, not by payload field presence.

## Validation and Quality Gates
- Run relevant tests and `pre-commit run --all-files` before PR when the repo supports them.
- Add missing tests when there is a clear logical gap.
- If tests cannot run, explain the blocker and suggest alternatives.
- Treat configured gates as hard requirements in pre-commit and CI: cyclomatic complexity, unit-test coverage, max function length, max file length, duplicate function detection.
- Do not disable/skip/weaken gates to force merge unless the user explicitly authorizes config changes.
- When editing files subject to line-count or format gates, run the formatter first to see the final shape before counting lines; never assume hand-compressed formatting will survive auto-formatting.
- For long-running workers/e2e loops, capture runId/output paths and confirm whether to stop afterward.
- When a required environment variable is missing, check the repo's secret management tool (e.g., Infisical, Vault, `.env.example`) before asking the user.

## Delivery Workflow (Fallback)
1. Start from `main` and use a short-lived feature branch.
2. Keep PRs focused; include summary, validation evidence, and merge plan.
3. Rebase on latest `main` before merge (`git rebase main`).
4. Wait for CI, fix root causes, and rerun until green.
5. Use squash merge by default after required checks pass.
6. Post-merge: switch to `main`, `git pull --rebase`, and delete the merged local branch.

## Language, Artifacts, and Coordination
- Before introducing a new language, add pre-commit hooks, CI checks, and hard-gate coverage first.
- Only then add production source files in that language.
- Default repo-facing artifacts to English (comments, commit messages, PR metadata, docs, governance files), unless repo-local rules say otherwise.
- If the repo has no commit message requirement, use Conventional Commits.
- Ask early about non-modifiable paths and required reuse targets.
- Confirm placement constraints before adding new integrations/files.
- Clarify branch strategy before multi-commit work.
- For long-running scripts, ensure periodic progress output.
- If a run fails due to missing prerequisites, label it as "needs fix", state why, and wait for direction before retrying.
- Surface assumptions and risks explicitly; keep changes reversible.
- Before architecture/API docs, lock key decisions first (ownership, execution model, snapshot semantics, transfer rules, access boundaries, endpoint shape, return type).
- For explicit brainstorm/design requests, use the `/brainstorming` skill.

## Output Format
- Provide concise summaries with concrete file paths.
- List exact commands and outcomes.
- If a request is ambiguous (for example, "merge" vs "apply"), restate intended action and confirm first.
- Keep next steps minimal and actionable.
- For Markdown edits, watch markdownlint basics (H1 on line 1, ordered list numbering).

## CI & PRs
- Always run the full CI/lint pipeline locally before pushing.
- After file splits or refactors, specifically check for unused imports/variables and NestJS DI compatibility (consistent-type-imports can break DI).

## Code Standards
- Primary language is TypeScript. Use strict TypeScript types — avoid `string` when an enum or union type exists.
- Check type compatibility before pushing changes.

## Observability
- For Datadog/telemetry instrumentation, never use high-cardinality values (e.g., projectId, userId) as metric tags. Use them as log attributes instead.

## Code Review
- When doing code reviews or walkthroughs, always include file paths and line numbers.
- For reviews, flag actual bugs distinctly from style suggestions.
