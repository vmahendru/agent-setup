#!/usr/bin/env bash
# PostToolUse hook: lint the file the agent just edited and feed findings back.
# Exit 2 sends stderr to the agent. Missing linters are skipped, not errors.
set -uo pipefail

file=$(jq -r '.tool_input.file_path // empty')
[[ -n "$file" && -f "$file" ]] || exit 0

dir=$(dirname "$file")
base=$(basename "$file")

# Walk up from the file to find a marker such as go.mod or compile_commands.json.
find_up() {
  local d="$1"
  while [[ "$d" != "/" ]]; do
    [[ -e "$d/$2" ]] && { echo "$d"; return 0; }
    d=$(dirname "$d")
  done
  return 1
}

out=""
case "$file" in
  *.go)
    command -v golangci-lint >/dev/null || exit 0
    find_up "$dir" go.mod >/dev/null || exit 0
    # Lint the package, then keep only findings in the edited file.
    out=$(cd "$dir" && golangci-lint run . 2>&1 | grep -F "$base:" || true)
    ;;
  *.c|*.cc|*.cpp|*.cxx|*.h|*.hh|*.hpp|*.hxx)
    command -v clang-tidy >/dev/null || exit 0
    # clang-tidy needs a compile database, at the project root or in build/.
    if d=$(find_up "$dir" compile_commands.json); then db="$d"
    elif d=$(find_up "$dir" build/compile_commands.json); then db="$d/build"
    else exit 0
    fi
    # Paths in the output follow the compile database, so match on the name.
    out=$(clang-tidy -p "$db" --quiet "$file" 2>/dev/null |
      grep -F "$base:" | grep -E ': (warning|error):' || true)
    ;;
  *)
    exit 0
    ;;
esac

[[ -z "$out" ]] && exit 0
{
  echo "Lint findings in $file. Fix the ones that are real; say why if you skip one."
  echo "$out" | head -n 40
} >&2
exit 2
