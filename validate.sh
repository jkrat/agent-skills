#!/usr/bin/env bash
# Validate every skills/*/ folder against the cross-tool Agent Skills rules.
# Errors fail the run (exit 1); warnings are reported but don't fail.
set -uo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
errors=0
warnings=0
checked=0
names_seen=""

err()  { echo "$1: ERROR: $2"; errors=$((errors + 1)); }
warn() { echo "$1: WARN: $2"; warnings=$((warnings + 1)); }

CC_ONLY_FIELDS="disable-model-invocation user-invocable context agent paths model effort hooks argument-hint arguments when_to_use"
PORTABLE_FIELDS="name description license compatibility metadata allowed-tools"

# Print the value of a top-level frontmatter key, joining folded/indented continuation lines.
field_value() {
  awk -v key="$1" '
    found && /^[[:space:]]+[^[:space:]]/ { sub(/^[[:space:]]+/, ""); val = val (val == "" ? "" : " ") $0; next }
    found { exit }
    $0 ~ "^" key ":" {
      found = 1
      val = substr($0, length(key) + 2)
      sub(/^[[:space:]]+/, "", val); sub(/[[:space:]]+$/, "", val)
      if (val ~ /^[>|][-+]?$/) val = ""
    }
    END { if (found) { gsub(/^["\047]|["\047]$/, "", val); print val } }
  ' <<<"$frontmatter"
}

shopt -s nullglob
for dir in "$REPO"/skills/*/; do
  skill="$(basename "$dir")"
  file="$dir/SKILL.md"
  checked=$((checked + 1))

  if [ ! -f "$file" ]; then
    err "$skill" "missing SKILL.md"
    continue
  fi

  content="$(tr -d '\r' < "$file")"

  if [ "$(head -n 1 <<<"$content")" != "---" ]; then
    err "$skill" "frontmatter must start with '---' on line 1"
    continue
  fi

  close_line="$(tail -n +2 <<<"$content" | grep -n -m 1 '^---[[:space:]]*$' | cut -d: -f1)"
  if [ -z "$close_line" ]; then
    err "$skill" "frontmatter has no closing '---'"
    continue
  fi
  frontmatter="$(sed -n "2,${close_line}p" <<<"$content")"
  body="$(tail -n +"$((close_line + 2))" <<<"$content")"

  name="$(field_value name)"
  description="$(field_value description)"

  if [ -z "$name" ]; then
    err "$skill" "missing 'name' in frontmatter"
  elif [ "$name" != "$skill" ]; then
    err "$skill" "name '$name' does not match folder name '$skill'"
  fi
  if [ -n "$name" ]; then
    if grep -qxF "$name" <<<"$names_seen"; then
      err "$skill" "duplicate name '$name' (used by another skill)"
    fi
    names_seen="$names_seen"$'\n'"$name"
  fi

  if [ -z "$description" ]; then
    err "$skill" "missing 'description' in frontmatter"
  elif [ "${#description}" -gt 1024 ]; then
    warn "$skill" "description is ${#description} characters (limit 1024)"
  fi

  for key in $(grep -oE '^[A-Za-z_-]+:' <<<"$frontmatter" | tr -d ':'); do
    if [[ " $CC_ONLY_FIELDS " == *" $key "* ]]; then
      warn "$skill" "frontmatter field '$key' works in Claude Code only"
    elif [[ " $PORTABLE_FIELDS " != *" $key "* ]]; then
      warn "$skill" "frontmatter field '$key' is not a cross-tool Agent Skills field"
    fi
  done

  grep -qE '^[[:space:]]*!`' <<<"$body" &&
    warn "$skill" "body uses Claude Code-only '!\`command\`' lines; use plain instructions (\"run \`git diff\`\")"
  grep -qE '^[[:space:]]*```!' <<<"$body" &&
    warn "$skill" "body uses Claude Code-only '\`\`\`!' blocks; use plain instructions"
  for var in 'CLAUDE_SKILL_DIR' 'CLAUDE_PROJECT_DIR'; do
    grep -qF "\${$var}" <<<"$body" &&
      warn "$skill" "body uses Claude Code-only \${$var}; use plain relative paths (scripts/check.sh)"
  done
  grep -qF '$ARGUMENTS' <<<"$body" &&
    warn "$skill" "body uses Claude Code-only \$ARGUMENTS"

  lines="$(wc -l <<<"$content" | tr -d ' ')"
  [ "$lines" -gt 500 ] &&
    warn "$skill" "SKILL.md is $lines lines (keep under 500; move long material to references/)"
done

echo "Checked $checked skills: $errors error(s), $warnings warning(s)."
[ "$errors" -eq 0 ]
