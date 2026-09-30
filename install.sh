#!/usr/bin/env bash
set -euo pipefail

# Windows (Git Bash/MSYS): make `ln -s` create real symlinks instead of copies. No effect elsewhere.
export MSYS="${MSYS:+$MSYS }winsymlinks:nativestrict"

REPO="$(cd "$(dirname "$0")" && pwd)"
TARGETS=("$HOME/.agents/skills" "$HOME/.claude/skills")

for target in "${TARGETS[@]}"; do
  mkdir -p "$target"

  # Remove stale links that point into this repo (deleted or renamed skills)
  for link in "$target"/*; do
    [ -L "$link" ] || continue
    dest="$(readlink "$link")"
    if [[ "$dest" == "$REPO/skills/"* ]] && [ ! -e "$dest" ]; then
      rm "$link"
      echo "removed stale: $link"
    fi
  done

  # Link every skill in the repo
  for skill in "$REPO"/skills/*/; do
    name="$(basename "$skill")"
    dest="$target/$name"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "skipped $dest (a real folder exists there; move it into the repo first)"
      continue
    fi
    ln -sfn "${skill%/}" "$dest"
  done
done

echo "Linked $(ls -d "$REPO"/skills/*/ | wc -l | tr -d ' ') skills."
