When maintaining dotfiles, keep third-party agent plugins in `agents/plugins.yaml`
and install them through `agents/install.sh`. Keep `agents/skills` for
repo-maintained skills; do not clone or link third-party skill trees into it.
Third-party skills that ship no plugin go in `agents/skills.yaml`.

Personal skills live in `~/dotfiles/agents/skills/<name>/`. After creating,
renaming, or removing one, run `sh ~/dotfiles/agents/link-skills.sh` so every
agent on this machine sees it. Do not create personal skills directly in
`~/.claude/skills` or `~/.agents/skills`; those directories are machine-local.
