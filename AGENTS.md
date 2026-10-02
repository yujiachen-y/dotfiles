# Repository Guidelines

## Project Structure & Module Organization
This repo is a macOS-focused dotfiles setup. Root-level dotfiles live beside the main `install.sh` orchestrator (for example, `.vimrc` and `.gitconfig`). Platform and tool-specific content is grouped under subfolders: `macos/` (Homebrew, Zed configuration, and system settings), `zsh/` (shell config), `agents/` (Codex prompts/skills plus `agents/AGENTS.shared.md`, with all agent sync handled in `agents/install.sh`), and `workspace/` (the `~/Workspace` layout rules, the public GitHub repo list, and their installer). The `screenshot/` directory stores documentation images, and `scripts/` is currently empty.

## Build, Test, and Development Commands
- `./install.sh` sets up vim, macOS defaults and Zed (on Darwin), Codex agents, zsh, Git configuration, and the workspace. Run from the repo root; scripts assume the repo lives at `~/dotfiles`.
- `./macos/install.sh` installs Homebrew, applies `macos/Brewfile`, links Zed configuration, and runs `macos/system_settings.sh`.
- `./agents/install.sh` symlinks prompts and skills into `~/.codex` and `~/.claude`, and installs the shared plugins from `agents/plugins.yaml` into both CLIs.
- `./zsh/install.sh` installs oh-my-zsh and links `.zshrc`.
- `sh workspace/install.sh` links `~/Workspace/AGENTS.md`, clones or fast-forwards the repos in `workspace/github-repos.txt` under `~/Workspace/github.com`, and points the Codex App's projectless folder at `~/Workspace/local/chatgpt`.
- `sh workspace/repos.sh pull` (alias `ws pull`) fetches every checkout under `~/Workspace` and fast-forwards the clean ones; `sh workspace/repos.sh add <repo>` clones into the remote-derived path. `workspace/install.sh` uses the same update logic.

## Coding Style & Naming Conventions
Shell scripts are POSIX `sh` with 2-space indentation. Keep scripts idempotent and prefer symlinks over copies. Use clear, descriptive filenames (hidden dotfiles such as `.vimrc`, `.gitconfig`, `.zshrc`).

## Testing Guidelines
There is no automated test suite. Validate changes by running the specific script you touched, or run the full setup on a disposable machine. If available, static checks are useful:
`shellcheck install.sh macos/*.sh macos/zed/*.sh zsh/*.sh agents/install.sh workspace/*.sh`.

## Commit & Branching Workflow
This is a personal, single-maintainer dotfiles repo. **Work directly on `main`** — do not create feature branches or pull requests for routine changes; commit straight to `main` and push. This repo-local rule intentionally overrides the branch-based "Delivery Workflow" in the global `agents/AGENTS.shared.md`, which already defers to repo-local guidance.

Commit messages follow Conventional Commits, scoped by area (examples in history: `feat(mise): ...`, `chore(macos): ...`, `fix(zsh): ...`, and date-stamped `chore: YY-MM-DD`). Split unrelated changes into separate semantic commits; in the body, note impacted areas, any manual steps, and OS-specific effects. Add screenshots only when updating `screenshot/` assets.

## Portability (iCloud-synced, public repo)

This repo lives in iCloud Drive and syncs across several machines, and it is
pushed to a public GitHub remote. The same working copy is therefore edited by
different users on different hosts, so a path that resolves on one machine can
silently break on the next — and any local path that gets committed is published.

Rules:

- Never commit a hardcoded absolute path (for example `/Users/<name>/...`,
  `/opt/homebrew/Cellar/<pkg>/<version>/...`, or a version-pinned toolchain dir
  such as `.../mise/installs/node/26.1.0/...`). This includes paths auto-injected
  by installers into `.zshrc`, `settings.json`, or any other tracked config.
- Never reach a machine-specific absolute path via a relative path either
  (`../../../Users/...`, `../Library/...`). The prohibition is on the destination,
  not the spelling.
- Prefer, in order: `$HOME`/`~`, `PATH`-based discovery (bare command name), a
  value resolved at install time by a script, or a documented env var.
- If a machine-specific value is genuinely unavoidable, put it in a gitignored
  machine-local file (the pattern already used by `~/.non_public_commands.sh` and
  the machine-local `~/.gitconfig` that includes the tracked one), and make the
  tracked side degrade cleanly when that file is absent.
- Any such change must work on every machine, not just the one you are on. Before
  committing a tool path, confirm the target actually exists here and that the
  same reference resolves on a fresh checkout; a config entry pointing at a
  binary this machine does not have is dead config — drop it rather than commit it.
- The same applies to anything a script creates under an iCloud-synced directory
  such as `~/Documents`: a symlink there reaches every machine verbatim, so give
  it a relative target and let other machines tolerate it before they have run
  the script.

## Security & Configuration Notes
Install scripts remove existing `~/.vimrc`, `~/.zshrc`, and `~/.non_public_commands.sh` before linking. Git setup replaces an existing `~/.gitconfig` symlink with a writable machine-local file that includes the tracked `~/dotfiles/.gitconfig`; existing regular-file settings are preserved. `workspace/install.sh` replaces an existing `~/Workspace/AGENTS.md` without a backup, and moves the Codex App's projectless folder (default `~/Documents/Codex`) to `~/Workspace/local/chatgpt`, leaving a relative link at the old path. Highlight destructive changes in PRs. `macos/install.sh` uses a Homebrew install script via curl; reviewers should verify the URL and permissions.

## Agent-Specific Instructions
When changing Codex or Claude agent behavior, update `agents/AGENTS.shared.md` and related prompt/skill files. `agents/install.sh` symlinks these into `~/.codex` and `~/.claude`.
