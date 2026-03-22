---
name: lint-init
description: >
  Initialize any repository with comprehensive lint rules and code quality tooling.
  Covers cyclomatic complexity, function/file length limits, parameter counts, type safety,
  code duplication, test coverage, and folder file-count limits. Supports TypeScript, Go,
  Python, Rust, and Java. Use this skill whenever the user asks to set up lint rules,
  initialize code quality checks, configure a linter, or bootstrap a new repo with quality gates —
  even if they don't say "lint" explicitly (e.g., "set up this repo", "add quality checks",
  "configure eslint/golangci-lint/ruff"). Also trigger when the user says /lint-init.
---

# Lint Init

Set up a complete code-quality gate system for a repository. The skill walks through an
interactive interview, picks the right tools for the language, generates all config files,
installs dependencies, and verifies everything passes.

## Workflow

```
Interview → Read language reference → Generate configs → Install deps → Verify → (Commit)
```

## Step 1 — Interview

Ask only what you don't already know. If the conversation already provides answers, skip ahead.

### Required questions

1. **Language** — TypeScript, Go, Python, Rust, Java, or other?
2. **Project type** — Library, CLI/application, monorepo, microservice?
3. **Package manager** — Language-specific (e.g., pnpm/npm/bun for TS, uv/poetry for Python).
4. **Formatter** — Prettier, gofmt, ruff format, rustfmt, etc. (suggest the standard for the language).
5. **Thresholds** — Use recommended defaults or customise?

### Optional (ask if relevant)

- Runtime environment (Node.js vs Bun, CPython vs PyPy, etc.)
- Existing configs to preserve
- CI system (GitHub Actions, GitLab CI, etc.) — for later integration

## Step 2 — Rule Categories

Every repo gets these 9 categories. Some may not apply to certain languages — the language
reference files document which to skip and why.

| # | Category | Default Threshold | Notes |
|---|----------|-------------------|-------|
| 1 | Cyclomatic complexity | ≤ 10 | Measures branching paths in a function |
| 2 | Max function length | ≤ 120 lines | Skipping blanks and comments |
| 3 | Max file length | ≤ 800 lines | Skipping blanks and comments |
| 4 | Max parameters | ≤ 3 | Encourages use of option objects / structs |
| 5 | Type safety | Strict | Language-dependent: TS→strict+explicit, Python→mypy strict, Go/Rust→built-in (skip) |
| 6 | Code duplication | ≤ 5% (jscpd) + linter rules | jscpd for cross-file, linter for in-file duplicates |
| 7 | Test coverage | ≥ 80% all metrics | Statements, branches, functions, lines |
| 8 | Max files per directory | ≤ 10 code files | Custom script, code files only (not configs/tests) |
| 9 | Best practices | Per language | Naming conventions, import ordering, no-any, etc. |

If the user chose "use recommended defaults", apply the thresholds above. Otherwise, ask for
each value individually.

## Step 3 — Read Language Reference

Based on the language chosen in Step 1, read the corresponding reference file:

- TypeScript / JavaScript → `references/typescript.md`
- Go → `references/golang.md`
- Python → `references/python.md`
- Rust → `references/rust.md`
- Java / Kotlin → `references/java.md`

The reference file contains:
- Which tools to install and how
- Config file templates adapted to the rule categories
- Which rules to skip for that language
- Verification commands

Follow the reference file closely for tool-specific details.

## Step 4 — Generate the Folder-Size Check

Every language gets a **folder-size check script** that enforces "max code files per directory."
The script should:

1. Walk the source directory recursively
2. Count only code files (by extension, per language)
3. Skip `node_modules`, `dist`, `build`, `.git`, `vendor`, `__pycache__`, `target`
4. Report violations and exit non-zero if any directory exceeds the limit
5. Accept `--max <N>` and `--path <dir>` arguments

Write the script in the project's primary language when practical (e.g., `.ts` for TypeScript,
`.py` for Python). For languages where scripting is less natural (Go, Rust, Java), use a
shell script or the language's test framework to run the check.

Add it as a package script (e.g., `"check:folder-size"` in package.json, or a Makefile target).

## Step 5 — Pre-commit Hooks

Set up pre-commit hooks so quality checks run automatically on `git commit`.

| Language | Tool | Config |
|----------|------|--------|
| TypeScript | husky + lint-staged | `.husky/pre-commit` + `.lintstagedrc.json` |
| Go | pre-commit framework or lefthook | `.pre-commit-config.yaml` or `lefthook.yml` |
| Python | pre-commit framework | `.pre-commit-config.yaml` |
| Rust | pre-commit framework or cargo-husky | `.pre-commit-config.yaml` |
| Java | pre-commit framework or maven/gradle plugin | `.pre-commit-config.yaml` |

The pre-commit should at minimum run: linter (fix mode) + formatter on staged files.
Full test suites and coverage checks are better left to CI.

## Step 6 — Add Scripts / Targets

Create a unified entry point for all checks. The naming convention varies by ecosystem:

**package.json (TS/JS)**:
- `lint`, `lint:fix`, `format`, `format:check`, `typecheck`, `test`, `test:coverage`,
  `check:duplication`, `check:folder-size`, `check:all`

**Makefile (Go/Rust/Java)**:
- `lint`, `fmt`, `test`, `coverage`, `check-duplication`, `check-folder-size`, `check-all`

**pyproject.toml scripts or Makefile (Python)**:
- Same as above, adapted for the tooling

Always include a `check:all` / `check-all` target that runs every check in sequence.

## Step 7 — Verify

After generating everything, run the full check suite to confirm zero errors:

1. Linter passes with no violations
2. Formatter reports no diffs
3. Type checker passes (if applicable)
4. Duplication check passes
5. Folder-size check passes

If something fails, fix it before moving on. Common issues:
- Config files themselves trigger lint rules → add appropriate ignores or adjust
- Missing dependencies → re-run install
- Threshold too strict for existing code → offer to relax or add inline suppressions

## Step 8 — Commit (Optional)

If the user asks, commit the result with a message like:

```
chore: initialize <language> lint rules and quality gates
```

## Tips

- **Monorepo**: Put shared lint config at the root. Each package extends it. Use workspace-aware
  tools (pnpm workspaces, Go workspaces, etc.)
- **Existing code**: If the repo already has code, offer to run linter in "warn" mode first
  so the team can fix violations gradually. Provide a migration path.
- **CI integration**: After local setup is verified, offer to generate a CI config
  (GitHub Actions, GitLab CI) that runs `check:all`.
