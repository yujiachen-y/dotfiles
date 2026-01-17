# Repository Guidelines

## Project Structure & Module Organization
This repo is a macOS-focused dotfiles setup. Root-level dotfiles live beside the main `install.sh` orchestrator (for example, `.vimrc` and `.gitconfig`). Platform and tool-specific content is grouped under subfolders: `macos/` (Homebrew and system settings), `zsh/` (shell config), and `agents/` (Codex prompts/skills plus `agents/AGENTS.md`, with all agent sync handled in `agents/install.sh`). The `screenshot/` directory stores documentation images, and `scripts/` is currently empty.

## Build, Test, and Development Commands
- `./install.sh` sets up vim, macOS defaults (on Darwin), Codex agents, zsh, and git symlinks. Run from the repo root; scripts assume the repo lives at `~/dotfiles`.
- `./macos/install.sh` installs Homebrew, applies `macos/Brewfile`, and runs `macos/system_settings.sh`.
- `./agents/install.sh` symlinks prompts and skills into `~/.codex` and sets up Gemini CLI/antigravity symlinks under `~/.gemini`.
- `./zsh/install.sh` installs oh-my-zsh and links `.zshrc`.

## Coding Style & Naming Conventions
Shell scripts are POSIX `sh` with 2-space indentation. Keep scripts idempotent and prefer symlinks over copies. Use clear, descriptive filenames (hidden dotfiles such as `.vimrc`, `.gitconfig`, `.zshrc`).

## Testing Guidelines
There is no automated test suite. Validate changes by running the specific script you touched, or run the full setup on a disposable machine. If available, static checks are useful:
`shellcheck install.sh macos/*.sh zsh/*.sh agents/install.sh`.

## Commit & Pull Request Guidelines
Commit messages follow Conventional Commits (examples in history: `feat: ...`, `docs: ...`, `chore: ...`, and date-stamped `chore: YY-MM-DD`). PRs should summarize impacted areas (for example, `macos/Brewfile` or `zsh/.zshrc`), list any manual steps, and call out OS-specific effects. Add screenshots only when updating `screenshot/` assets.

## Security & Configuration Notes
Install scripts remove existing `~/.vimrc`, `~/.gitconfig`, `~/.zshrc`, and `~/.non_public_commands.sh` before linking. Highlight destructive changes in PRs. `macos/install.sh` uses a Homebrew install script via curl; reviewers should verify the URL and permissions.

## Agent-Specific Instructions
When changing Codex or Gemini/antigravity agent behavior, update `agents/AGENTS.md` and related prompt/skill files. `agents/install.sh` symlinks these into `~/.codex` and `~/.gemini`.
