#!/bin/sh
# Link each repo-maintained skill into the agents' user skill directories.
# Those directories stay real and machine-local because tools write into them
# (Claude Code's claude.ai skill sync, `skills add -g`), and this repo is shared
# live through iCloud. Prints nothing when the links are already current.
set -eu

SOURCE="$HOME/dotfiles/agents/skills"

for target in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  if [ -L "$target" ]; then
    # Old layout linked the whole directory into the repo; remove the link only.
    rm "$target"
    echo "skills: replaced the link at $target with a local directory"
  fi
  mkdir -p "$target"
  for skill in "$SOURCE"/*/; do
    skill=${skill%/}
    [ -f "$skill/SKILL.md" ] || continue
    link="$target/${skill##*/}"
    [ "$(readlink "$link" 2>/dev/null)" = "$skill" ] && continue
    if [ -L "$link" ] || [ ! -e "$link" ]; then
      ln -sfn "$skill" "$link"
      echo "skills: linked ${skill##*/} into $target"
    else
      echo "skills: $link exists and is not a link; left alone"
    fi
  done
  # Links to repo skills that were renamed or removed.
  for link in "$target"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$SOURCE"/*)
        if [ ! -e "$link" ]; then
          rm "$link"
          echo "skills: removed stale link $link"
        fi
        ;;
    esac
  done
done
