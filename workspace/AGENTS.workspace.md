# Workspace Layout Guide

This workspace contains independent checkouts. Repo-local instructions take
priority within each checkout. This file only governs workspace placement and
updates; its source lives in public dotfiles, so keep examples and rules generic.

## Placement

Paths are relative to the workspace root.

- `local/<project>` is the default for projects without a maintained Git remote
  or a personal cloud storage location.
- `<host>/<org-or-group>/[subgroup...]/<repo>` holds remote-backed checkouts.
  Derive the path from `origin`, retaining all group segments and removing only
  the trailing `.git` suffix. For example, `github.com/cli/cli`.
- `drive/<project>` may link to a project in personal cloud storage. Choose its
  actual location per project; these links are managed separately from dotfiles.

When a local or cloud project is published and its Git remote becomes its
maintained home, move its checkout into the remote-derived path. Preserve local
changes and files outside Git, and repair links, worktree registrations, and
application settings that reference the old location.

Archive cloud projects in their chosen cloud location and remove their active
`drive` entries; restore the entries when work resumes. Remote-backed projects
need no additional cloud archive. Preserve unpublished work before removing a
local checkout.

## Worktrees

Keep ordinary worktrees in the owning repository's `.worktrees/<name>` and
exclude that directory from Git tracking. Leave application-managed worktrees
under their application's management. Use `git worktree move` for relocation;
defer worktrees with active processes or unfinished Git operations and preserve
local changes.

## Updating and Cloning

For repositories with `origin`, update default and `dev` integration branches
with `git pull --ff-only` from clean checkouts. Update remote refs with `git fetch`
when local changes, detached HEAD, or divergence prevent a pull. Preserve the
current checkout; use feature branches or worktrees for code changes, not
temporary remote branches merely to update a base branch.

Clone new repositories directly into their remote-derived paths, creating
parent directories as needed. Keep repositories without a known `origin` in
`local/<project>` rather than inventing an organization or group.

`sh ~/dotfiles/workspace/repos.sh add <repo>` does the clone and derives the
path for you; `<repo>` is `owner/repo` (GitHub), `host/group/repo`, or a git
URL. `sh ~/dotfiles/workspace/repos.sh pull` applies the update rule above to
every checkout in the workspace.
