#!/usr/bin/env bash
# shellcheck disable=SC2016  # $c in jq filters is a jq variable, not a shell one
# Install or remove these defaults in your user-level Claude Code config.
#   ./setup.sh              install (safe to re-run)
#   ./setup.sh --uninstall  remove everything this script added
#
# Agents, skills, and the hook are symlinked, so `git pull` updates them.
set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
claude_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
settings="$claude_dir/settings.json"
memory="$claude_dir/CLAUDE.md"
import_line="@$repo/global/CLAUDE.md"
hook_cmd="$repo/hooks/lint-changed.sh"

command -v jq >/dev/null || { echo "setup needs jq" >&2; exit 1; }

# Symlink src to dest. An existing real file at dest is kept as dest.bak.
link() {
  local src="$1" dest="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mv "$dest" "$dest.bak"
    echo "  backed up existing $dest to $dest.bak"
  fi
  ln -sfn "$src" "$dest"
  echo "  linked $dest"
}

# Remove dest only if it is a symlink into this repo.
unlink_ours() {
  local dest="$1"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$repo"/* ]]; then
    rm "$dest"
    echo "  removed $dest"
  fi
}

# Rewrite settings.json through a jq filter, keeping a backup.
edit_settings() {
  [[ -f "$settings" ]] || echo '{}' >"$settings"
  cp "$settings" "$settings.bak"
  jq "$@" "$settings.bak" >"$settings"
}

install() {
  mkdir -p "$claude_dir/agents" "$claude_dir/skills"

  echo "Agents:"
  for f in "$repo"/agents/*.md; do link "$f" "$claude_dir/agents/$(basename "$f")"; done

  echo "Skills:"
  for d in "$repo"/skills/*/; do link "${d%/}" "$claude_dir/skills/$(basename "$d")"; done

  echo "Global instructions:"
  touch "$memory"
  if grep -qxF "$import_line" "$memory"; then
    echo "  already imported in $memory"
  else
    printf '\n%s\n' "$import_line" >>"$memory"
    echo "  added import to $memory"
  fi

  echo "Lint hook:"
  chmod +x "$hook_cmd"
  if [[ -f "$settings" ]] && jq -e --arg c "$hook_cmd" \
      '[.hooks.PostToolUse[]?.hooks[]?.command] | index($c)' "$settings" >/dev/null; then
    echo "  already in $settings"
  else
    edit_settings --arg c "$hook_cmd" '.hooks.PostToolUse += [{
      matcher: "Edit|Write|MultiEdit",
      hooks: [{type: "command", command: $c, timeout: 60}]
    }]'
    echo "  added PostToolUse hook to $settings"
  fi

  for tool in golangci-lint clang-tidy gh; do
    command -v "$tool" >/dev/null || echo "Note: $tool not found. Parts that use it are skipped until it is installed."
  done
  echo "Done. Restart Claude Code to pick up the changes."
}

uninstall() {
  echo "Removing:"
  for f in "$repo"/agents/*.md; do unlink_ours "$claude_dir/agents/$(basename "$f")"; done
  for d in "$repo"/skills/*/; do unlink_ours "$claude_dir/skills/$(basename "$d")"; done

  if [[ -f "$memory" ]] && grep -qxF "$import_line" "$memory"; then
    grep -vxF "$import_line" "$memory" >"$memory.tmp" || true
    mv "$memory.tmp" "$memory"
    echo "  removed import from $memory"
  fi

  if [[ -f "$settings" ]]; then
    edit_settings --arg c "$hook_cmd" '
      if .hooks.PostToolUse then
        .hooks.PostToolUse |= map(select([.hooks[]?.command] | index($c) | not))
      else . end'
    echo "  removed hook from $settings"
  fi
  echo "Done."
}

case "${1:-}" in
  "") install ;;
  --uninstall) uninstall ;;
  *) echo "usage: $0 [--uninstall]" >&2; exit 1 ;;
esac
