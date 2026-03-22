# Rust

## Tool Matrix

| Rule Category | Tool | Config |
|---|---|---|
| Linter | clippy | `clippy.toml` + Cargo.toml [lints] |
| Formatter | rustfmt | `rustfmt.toml` |
| Type safety | **Skip** — Rust has strict static typing + borrow checker | — |
| Test + coverage | cargo test + cargo-tarpaulin | `Cargo.toml` |
| Duplication | jscpd | `.jscpd.json` |
| Pre-commit | pre-commit framework | `.pre-commit-config.yaml` |
| Folder-size | Shell script | `scripts/lint-folder-size.sh` |

## Applicable Rules

| # | Category | Applicable? | Notes |
|---|----------|-------------|-------|
| 1 | Cyclomatic complexity | Yes | clippy `cognitive_complexity` lint |
| 2 | Function length | Yes | clippy `too_many_lines` lint |
| 3 | File length | Yes | Custom script |
| 4 | Max parameters | Yes | clippy `too_many_arguments` lint |
| 5 | Type safety | **Skip** | Rust's type system is already strict |
| 6 | Code duplication | Yes | jscpd |
| 7 | Test coverage | Yes | cargo-tarpaulin |
| 8 | Max files per dir | Yes | Shell script |
| 9 | Best practices | Yes | clippy lint groups |

## Prerequisites

- Rust toolchain (rustup)
- clippy: `rustup component add clippy`
- rustfmt: `rustup component add rustfmt`
- cargo-tarpaulin: `cargo install cargo-tarpaulin`
- jscpd: `npm install -g jscpd` (or `npx jscpd`)
- pre-commit: `pip install pre-commit` or `brew install pre-commit`

## Config: Cargo.toml [lints]

```toml
[lints.clippy]
# Rule 1: Complexity
cognitive_complexity = { level = "warn", priority = 1 }

# Rule 2: Function length
too_many_lines = { level = "warn", priority = 1 }

# Rule 4: Max parameters
too_many_arguments = { level = "warn", priority = 1 }

# Rule 9: Best practices — enable restrictive lint groups
pedantic = { level = "warn", priority = -1 }
nursery = { level = "allow", priority = -1 }

# Common pedantic overrides (too noisy)
module_name_repetitions = "allow"
must_use_candidate = "allow"
missing_errors_doc = "allow"
missing_panics_doc = "allow"

# Additional useful lints
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
todo = "warn"
dbg_macro = "warn"
print_stdout = "warn"
print_stderr = "warn"

[lints.rust]
unsafe_code = "deny"
missing_debug_implementations = "warn"
```

## Config: clippy.toml

```toml
# Rule 1: Cyclomatic complexity threshold
cognitive-complexity-threshold = 10

# Rule 2: Function length (lines)
too-many-lines-threshold = 120

# Rule 4: Max function parameters
too-many-arguments-threshold = 3

# Additional thresholds
type-complexity-threshold = 250
single-char-binding-names-threshold = 4
```

## Config: rustfmt.toml

```toml
edition = "2021"
max_width = 100
tab_spaces = 4
use_field_init_shorthand = true
use_try_shorthand = true
imports_granularity = "Crate"
group_imports = "StdExternalCrate"
reorder_imports = true
```

## File Length Check Script

```bash
#!/usr/bin/env bash
# Rule 3: Check max lines per Rust file
MAX_LINES=${1:-800}
violations=0
while IFS= read -r file; do
  # Count non-blank, non-comment lines
  lines=$(grep -cv '^\s*$\|^\s*//' "$file")
  if [ "$lines" -gt "$MAX_LINES" ]; then
    echo "  $file — $lines lines (max: $MAX_LINES)"
    violations=$((violations + 1))
  fi
done < <(find . -name '*.rs' -not -path './target/*' -not -path './.git/*')

if [ "$violations" -gt 0 ]; then
  echo "✗ $violations file(s) exceed $MAX_LINES lines"
  exit 1
fi
echo "✓ All Rust files have ≤ $MAX_LINES lines"
```

## Folder-size script: scripts/lint-folder-size.sh

```bash
#!/usr/bin/env bash
MAX_FILES=${1:-10}
SCAN_PATH=${2:-src}
violations=0

while IFS= read -r dir; do
  count=$(find "$dir" -maxdepth 1 -type f -name "*.rs" | wc -l | tr -d ' ')
  if [ "$count" -gt "$MAX_FILES" ]; then
    echo "  $dir/ — $count code files (max: $MAX_FILES)"
    violations=$((violations + 1))
  fi
done < <(find "$SCAN_PATH" -type d -not -path '*/target/*' -not -path '*/.git/*')

if [ "$violations" -gt 0 ]; then
  echo "✗ $violations director(ies) exceed $MAX_FILES code files"
  exit 1
fi
echo "✓ All directories have ≤ $MAX_FILES code files"
```

## Config: .jscpd.json

```json
{
  "threshold": 5,
  "reporters": ["console"],
  "ignore": ["target", ".git"],
  "absolute": false,
  "gitignore": true,
  "minTokens": 50,
  "minLines": 5,
  "format": ["rust"]
}
```

## Coverage

```bash
cargo tarpaulin --out Xml --out Lcov --fail-under 80
```

For workspace projects: `cargo tarpaulin --workspace --fail-under 80`

## Pre-commit: .pre-commit-config.yaml

```yaml
repos:
  - repo: local
    hooks:
      - id: cargo-fmt
        name: cargo fmt
        entry: cargo fmt --all --
        language: system
        types: [rust]
        pass_filenames: false

      - id: cargo-clippy
        name: cargo clippy
        entry: cargo clippy --all-targets --all-features -- -D warnings
        language: system
        types: [rust]
        pass_filenames: false

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

Install: `pre-commit install`

## Makefile

```makefile
.PHONY: lint fmt fmt-check test coverage check-duplication check-folder-size check-file-length check-all

lint:
	cargo clippy --all-targets --all-features -- -D warnings

fmt:
	cargo fmt --all

fmt-check:
	cargo fmt --all -- --check

test:
	cargo test --all-features

coverage:
	cargo tarpaulin --workspace --fail-under 80

check-duplication:
	jscpd src/

check-folder-size:
	bash scripts/lint-folder-size.sh 10 src

check-file-length:
	bash scripts/check-file-length.sh 800

check-all: lint fmt-check check-duplication check-folder-size check-file-length
	@echo "✓ All checks passed"
```

## Verification

```bash
make lint               # clippy passes
make fmt-check          # rustfmt reports no diffs
make check-duplication  # jscpd finds no excessive duplication
make check-folder-size  # All directories within limit
make check-file-length  # All files within limit
```

## Notes

- Clippy's `cognitive_complexity` is the primary complexity check — it's more nuanced than cyclomatic
- `#[allow(clippy::...)]` can suppress individual lints inline when justified
- For workspace (monorepo) projects, put `[workspace.lints]` in root `Cargo.toml`
  and use `[lints] workspace = true` in member crates
- cargo-tarpaulin works best on Linux; on macOS consider `cargo-llvm-cov` as an alternative
- `deny(unsafe_code)` prevents unsafe blocks — relax per-module if genuinely needed
