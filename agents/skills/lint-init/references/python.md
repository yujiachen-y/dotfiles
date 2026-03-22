# Python

## Tool Matrix

| Rule Category | Tool | Config |
|---|---|---|
| Linter | ruff (replaces flake8, isort, pycodestyle, etc.) | `pyproject.toml` [tool.ruff] |
| Formatter | ruff format (replaces black) | `pyproject.toml` [tool.ruff.format] |
| Type safety | mypy (strict mode) or pyright | `pyproject.toml` [tool.mypy] |
| Test + coverage | pytest + pytest-cov | `pyproject.toml` [tool.pytest] |
| Duplication | jscpd + ruff's pylint rules | `.jscpd.json` |
| Pre-commit | pre-commit framework | `.pre-commit-config.yaml` |
| Folder-size | Custom Python script | `scripts/lint_folder_size.py` |

## Applicable Rules (all 9 apply)

All 9 rule categories apply. Python needs explicit type enforcement via mypy/pyright.

## Prerequisites

- Python ≥ 3.11
- A package manager: uv (recommended), poetry, or pip
- pre-commit: `pip install pre-commit` or `brew install pre-commit`

## Installation

Using uv:

```bash
uv add --dev ruff mypy pytest pytest-cov jscpd pre-commit
```

Using pip:

```bash
pip install ruff mypy pytest pytest-cov pre-commit
npm install -g jscpd   # or npx jscpd
```

## Config: pyproject.toml

All Python tool configs go in a single `pyproject.toml`:

```toml
[tool.ruff]
target-version = "py311"
line-length = 100

[tool.ruff.lint]
select = [
  "E",     # pycodestyle errors
  "W",     # pycodestyle warnings
  "F",     # pyflakes
  "I",     # isort (import ordering)
  "N",     # pep8-naming
  "UP",    # pyupgrade
  "B",     # flake8-bugbear
  "A",     # flake8-builtins
  "C4",    # flake8-comprehensions
  "SIM",   # flake8-simplify
  "TCH",   # flake8-type-checking
  "ARG",   # flake8-unused-arguments
  "RET",   # flake8-return
  "PTH",   # flake8-use-pathlib
  "ERA",   # eradicate (commented-out code)
  "PL",    # pylint rules
  "C90",   # mccabe complexity
  "T20",   # flake8-print (no print statements)
  "RUF",   # ruff-specific rules
]
ignore = [
  "E501",  # line length (handled by formatter)
]

[tool.ruff.lint.mccabe]
max-complexity = 10                # Rule 1: cyclomatic complexity

[tool.ruff.lint.pylint]
max-args = 3                       # Rule 4: max parameters
max-statements = 60                # Related to Rule 2
max-branches = 10                  # Related to Rule 1

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
line-ending = "lf"

[tool.mypy]
python_version = "3.11"
strict = true                      # Rule 5: type safety
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_explicit = true
check_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--strict-markers -v"

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "scripts/*", "**/__pycache__/*"]

[tool.coverage.report]
fail_under = 80                    # Rule 7: test coverage
show_missing = true
exclude_lines = [
  "pragma: no cover",
  "if TYPE_CHECKING:",
  "if __name__ == .__main__.",
]
```

## File and Function Length Checks

Ruff doesn't have built-in file/function length rules. Use custom scripts:

### scripts/check_file_length.py

```python
"""Rule 3: Check max lines per file."""
import sys
from pathlib import Path

MAX_LINES = int(sys.argv[1]) if len(sys.argv) > 1 else 800
SCAN_PATH = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("src")

violations = []
for py_file in SCAN_PATH.rglob("*.py"):
    if "__pycache__" in str(py_file):
        continue
    line_count = len([l for l in py_file.read_text().splitlines() if l.strip() and not l.strip().startswith("#")])
    if line_count > MAX_LINES:
        violations.append((str(py_file), line_count))

if violations:
    print(f"✗ {len(violations)} file(s) exceed {MAX_LINES} lines:")
    for path, count in violations:
        print(f"  {path} — {count} lines")
    sys.exit(1)
print(f"✓ All files have ≤ {MAX_LINES} lines (excluding blanks and comments)")
```

### scripts/check_function_length.py

```python
"""Rule 2: Check max lines per function."""
import ast
import sys
from pathlib import Path

MAX_LINES = int(sys.argv[1]) if len(sys.argv) > 1 else 120
SCAN_PATH = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("src")

violations = []
for py_file in SCAN_PATH.rglob("*.py"):
    if "__pycache__" in str(py_file):
        continue
    try:
        tree = ast.parse(py_file.read_text())
    except SyntaxError:
        continue
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            length = node.end_lineno - node.lineno + 1
            if length > MAX_LINES:
                violations.append((str(py_file), node.name, length))

if violations:
    print(f"✗ {len(violations)} function(s) exceed {MAX_LINES} lines:")
    for path, name, count in violations:
        print(f"  {path}:{name} — {count} lines")
    sys.exit(1)
print(f"✓ All functions have ≤ {MAX_LINES} lines")
```

## Folder-size script: scripts/lint_folder_size.py

```python
"""Rule 8: Check max code files per directory."""
import sys
from pathlib import Path

MAX_FILES = int(sys.argv[1]) if len(sys.argv) > 1 else 10
SCAN_PATH = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("src")
CODE_EXTENSIONS = {".py"}
SKIP_DIRS = {"__pycache__", ".git", "node_modules", ".venv", "venv", ".tox"}

violations = []
for directory in SCAN_PATH.rglob("*"):
    if not directory.is_dir():
        continue
    if any(skip in directory.parts for skip in SKIP_DIRS):
        continue
    count = sum(1 for f in directory.iterdir() if f.is_file() and f.suffix in CODE_EXTENSIONS and not f.name.startswith("test_"))
    if count > MAX_FILES:
        violations.append((str(directory), count))

if violations:
    print(f"✗ {len(violations)} director(ies) exceed {MAX_FILES} code files:")
    for path, count in violations:
        print(f"  {path}/ — {count} code files")
    sys.exit(1)
print(f"✓ All directories have ≤ {MAX_FILES} code files")
```

## Config: .jscpd.json

```json
{
  "threshold": 5,
  "reporters": ["console"],
  "ignore": ["__pycache__", ".venv", "venv", ".git", ".tox", "*.egg-info"],
  "absolute": false,
  "gitignore": true,
  "minTokens": 50,
  "minLines": 5,
  "format": ["python"]
}
```

## Pre-commit: .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.0   # update to latest
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.13.0   # update to latest
    hooks:
      - id: mypy
        additional_dependencies: []  # add stubs as needed

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
```

Install: `pre-commit install`

## Makefile (or use pyproject.toml scripts)

```makefile
.PHONY: lint fmt fmt-check typecheck test coverage check-duplication check-folder-size check-all

lint:
	ruff check .

lint-fix:
	ruff check . --fix

fmt:
	ruff format .

fmt-check:
	ruff format . --check

typecheck:
	mypy src/

test:
	pytest

coverage:
	pytest --cov=src --cov-report=term-missing --cov-fail-under=80

check-duplication:
	jscpd src/

check-folder-size:
	python scripts/lint_folder_size.py 10 src

check-file-length:
	python scripts/check_file_length.py 800 src

check-function-length:
	python scripts/check_function_length.py 120 src

check-all: lint fmt-check typecheck check-duplication check-folder-size check-file-length check-function-length
	@echo "✓ All checks passed"
```

## Verification

```bash
make lint               # ruff passes
make fmt-check          # ruff format reports no diffs
make typecheck          # mypy passes
make check-duplication  # jscpd finds no excessive duplication
make check-folder-size  # All directories within limit
```

## Notes

- ruff is a single tool that replaces flake8, isort, pycodestyle, pydocstyle, and more
- ruff format replaces black with near-identical output but 10-100x faster
- Use `py.typed` marker file in packages to indicate PEP 561 compliance
- For monorepos, use a shared `pyproject.toml` at root or per-package configs
- `uv` is the fastest Python package manager — recommend for new projects
