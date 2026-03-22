# Go

## Tool Matrix

| Rule Category | Tool | Config |
|---|---|---|
| Linter | golangci-lint (bundles gocyclo, funlen, gocognit, dupl, etc.) | `.golangci.yml` |
| Formatter | gofmt / goimports (built-in) | N/A (standard) |
| Type safety | **Skip** — Go is statically typed by design | — |
| Test + coverage | `go test -coverprofile` + coverage threshold check | Makefile |
| Duplication | dupl (via golangci-lint) + jscpd | `.jscpd.json` |
| Pre-commit | pre-commit framework or lefthook | `.pre-commit-config.yaml` or `lefthook.yml` |
| Folder-size | Shell script or Go test | `scripts/lint-folder-size.sh` |

## Applicable Rules

| # | Category | Applicable? | Notes |
|---|----------|-------------|-------|
| 1 | Cyclomatic complexity | Yes | `gocyclo` linter |
| 2 | Function length | Yes | `funlen` linter |
| 3 | File length | Yes | Custom or `wsl` / script |
| 4 | Max parameters | Yes | `gocritic` has `hugeParam`; use `revive` for param count |
| 5 | Type safety | **Skip** | Go is statically typed |
| 6 | Code duplication | Yes | `dupl` linter + jscpd |
| 7 | Test coverage | Yes | `go test -cover` with threshold |
| 8 | Max files per dir | Yes | Shell script |
| 9 | Best practices | Yes | `govet`, `errcheck`, `ineffassign`, `goconst`, etc. |

## Prerequisites

- Go ≥ 1.21
- golangci-lint: `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`
  or `brew install golangci-lint`
- jscpd: `npm install -g jscpd` (or use `npx jscpd`)
- pre-commit: `pip install pre-commit` or `brew install pre-commit`

## Config: .golangci.yml

```yaml
run:
  timeout: 5m
  modules-download-mode: readonly

linters:
  enable:
    # Complexity
    - gocyclo          # cyclomatic complexity
    - gocognit         # cognitive complexity
    - funlen           # function length
    - cyclop           # cyclomatic + package complexity

    # Code quality
    - govet            # go vet checks
    - errcheck         # unchecked errors
    - staticcheck      # advanced static analysis
    - ineffassign      # unused assignments
    - unused           # unused code
    - goconst          # repeated strings → constants
    - dupl             # code duplication
    - gocritic         # opinionated checks
    - revive           # flexible linter (replaces golint)
    - prealloc         # slice preallocation hints
    - noctx            # http requests without context
    - bodyclose        # unclosed HTTP response bodies
    - exportloopref    # loop variable capture

    # Style
    - goimports        # import ordering
    - misspell         # spelling
    - whitespace       # unnecessary whitespace

linters-settings:
  gocyclo:
    min-complexity: 10          # Rule 1: cyclomatic complexity

  gocognit:
    min-complexity: 15          # Rule 9: cognitive complexity

  funlen:
    lines: 120                  # Rule 2: function length
    statements: 60

  cyclop:
    max-complexity: 10

  dupl:
    threshold: 100              # Rule 6: tokens before flagging duplication

  goconst:
    min-len: 3
    min-occurrences: 3

  gocritic:
    enabled-tags:
      - diagnostic
      - style
      - performance

  revive:
    rules:
      - name: function-result-limit
        arguments: [3]
      - name: argument-limit
        arguments: [3]          # Rule 4: max parameters
      - name: cognitive-complexity
        arguments: [15]
      - name: line-length-limit
        arguments: [120]
      - name: file-header
        disabled: true

issues:
  max-issues-per-linter: 0
  max-same-issues: 0
  exclude-rules:
    - path: _test\.go
      linters:
        - funlen
        - dupl
        - goconst
```

## Config: .jscpd.json

```json
{
  "threshold": 5,
  "reporters": ["console"],
  "ignore": ["vendor", "**/*_test.go", ".git"],
  "absolute": false,
  "gitignore": true,
  "minTokens": 50,
  "minLines": 5,
  "format": ["go"]
}
```

## File Length Check

golangci-lint does not have a built-in file-length linter. Add a check in the Makefile
or use a shell script:

```bash
#!/usr/bin/env bash
# Check max lines per Go file (Rule 3)
MAX_LINES=${1:-800}
violations=0
while IFS= read -r file; do
  lines=$(wc -l < "$file" | tr -d ' ')
  if [ "$lines" -gt "$MAX_LINES" ]; then
    echo "  $file — $lines lines (max: $MAX_LINES)"
    violations=$((violations + 1))
  fi
done < <(find . -name '*.go' -not -path './vendor/*' -not -path './.git/*')

if [ "$violations" -gt 0 ]; then
  echo "✗ $violations file(s) exceed $MAX_LINES lines"
  exit 1
fi
echo "✓ All Go files have ≤ $MAX_LINES lines"
```

## Folder-size script: scripts/lint-folder-size.sh

```bash
#!/usr/bin/env bash
MAX_FILES=${1:-10}
SCAN_PATH=${2:-.}
EXTENSIONS="go"
violations=0

while IFS= read -r dir; do
  count=$(find "$dir" -maxdepth 1 -type f -name "*.go" ! -name "*_test.go" | wc -l | tr -d ' ')
  if [ "$count" -gt "$MAX_FILES" ]; then
    echo "  $dir/ — $count code files (max: $MAX_FILES)"
    violations=$((violations + 1))
  fi
done < <(find "$SCAN_PATH" -type d -not -path '*/vendor/*' -not -path '*/.git/*')

if [ "$violations" -gt 0 ]; then
  echo "✗ $violations director(ies) exceed $MAX_FILES code files"
  exit 1
fi
echo "✓ All directories have ≤ $MAX_FILES code files"
```

Make executable: `chmod +x scripts/lint-folder-size.sh`

## Coverage Threshold Check

Go doesn't have built-in coverage thresholds. Use a script or Makefile target:

```bash
#!/usr/bin/env bash
THRESHOLD=${1:-80}
go test ./... -coverprofile=coverage.out -covermode=atomic
COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | tr -d '%')
echo "Coverage: ${COVERAGE}%"
if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
  echo "✗ Coverage ${COVERAGE}% is below threshold ${THRESHOLD}%"
  exit 1
fi
echo "✓ Coverage meets ${THRESHOLD}% threshold"
```

## Makefile

```makefile
.PHONY: lint fmt test coverage check-duplication check-folder-size check-file-length check-all

lint:
	golangci-lint run ./...

fmt:
	goimports -w .
	gofmt -w .

fmt-check:
	@test -z "$$(goimports -l .)" || (echo "goimports needed on:" && goimports -l . && exit 1)
	@test -z "$$(gofmt -l .)" || (echo "gofmt needed on:" && gofmt -l . && exit 1)

test:
	go test ./...

coverage:
	bash scripts/check-coverage.sh 80

check-duplication:
	jscpd .

check-folder-size:
	bash scripts/lint-folder-size.sh 10

check-file-length:
	bash scripts/check-file-length.sh 800

check-all: lint fmt-check check-duplication check-folder-size check-file-length
	@echo "✓ All checks passed"
```

## Pre-commit: .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/golangci/golangci-lint
    rev: v1.62.0   # update to latest
    hooks:
      - id: golangci-lint
        args: [--fix]

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

Install: `pre-commit install`

## Project Init

```bash
go mod init <module-path>
```

## Verification

```bash
make lint               # golangci-lint passes
make fmt-check          # gofmt/goimports report no diffs
make check-duplication  # jscpd finds no excessive duplication
make check-folder-size  # All directories within limit
make check-file-length  # All files within limit
```

## Notes

- `_test.go` files are excluded from funlen and dupl checks (test code can be more verbose)
- Go modules vendor directory should be excluded from all checks
- goimports handles both formatting and import ordering — it's a superset of gofmt
- For monorepos with Go workspaces, use `go.work` and run `golangci-lint` per module
