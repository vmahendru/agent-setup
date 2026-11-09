# agent-setup

Claude Code defaults for agent-written code that a human reviewer will actually read.

Frontier models usually get correctness right. Where they slip is taste: hand-rolled versions of library code, needless indirection, vague names, defensive handling for unreachable cases, comments written as notes to self, and 1,000-line PRs nobody can review. This repo pushes back on those at four points in the loop.

| Stage | What runs | What it catches |
|---|---|---|
| Plan | `plan` skill, then `plan-critic` agent | Reinvention, missing precedent, excess scope, before any code exists |
| Build | `pr-stack` skill, global `CLAUDE.md` | Placeholder-ridden PR stacks, edge-case bloat, early abstraction |
| Edit | `lint-changed.sh` hook | Non-idiomatic Go and C++, via golangci-lint and clang-tidy |
| Review | `simplifier` agent, `reviewer-style` skill | Leftover complexity, weak names, wordy prose, one reviewer's known preferences |

## Install

```sh
git clone https://github.com/vmahendru/agent-setup ~/src/agent-setup
~/src/agent-setup/setup.sh
```

Requires `jq`. The hook uses `golangci-lint` and `clang-tidy` if they are installed, and `reviewer-style` uses `gh`. Anything missing is skipped.

The script symlinks into `~/.claude` (or `$CLAUDE_CONFIG_DIR`), so `git pull` updates everything:

- `agents/*` → `~/.claude/agents/`
- `skills/*` → `~/.claude/skills/`
- one `@import` line for `global/CLAUDE.md` appended to `~/.claude/CLAUDE.md`, leaving your existing content alone
- one `PostToolUse` hook added to `~/.claude/settings.json`, with a backup at `settings.json.bak`

It is safe to re-run. `./setup.sh --uninstall` removes exactly what it added.

## Workflow

1. **Plan.** Ask for a plan with the `plan` skill. It traces current behavior with file and line citations, then describes the change as edits to that trace. Every new abstraction needs a precedent in the repo. The `plan-critic` agent checks the plan against the real code. You can review it without knowing the codebase well, because every claim links to code you can open.
2. **Approve scope.** Cut edge cases and abstractions here. It's the cheapest place to do it.
3. **Build as a stack.** Base case, then edge cases, then extraction. Each PR compiles and stands on its own, with a reading guide in the description.
4. **Lint on every edit.** The hook feeds findings back to the agent, which fixes them before you see the diff.
5. **Simplify.** Run the `simplifier` agent on the diff. It is read-only and allowed to find nothing.
6. **Match the reviewer.** If you have a guide in `~/.claude/reviewers/`, check the diff against it.

## Customize

- **Per project:** put repo-specific rules in that repo's `CLAUDE.md`. They load alongside these.
- **C++:** copy `templates/.clang-tidy` to the project root. clang-tidy needs a `compile_commands.json`, either at the root or in `build/`. Generate one with `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` or Bear.
- **Reviewer guides:** run `/reviewer-style` with a GitHub username. Without the setup installed, paste [`skills/reviewer-style/prompt.md`](skills/reviewer-style/prompt.md) into Claude Code from inside the repo instead. Guides describe real people in real codebases, so they live in `~/.claude/reviewers/`, outside this repo, and should stay there.
- **Pruning:** a rule that keeps getting broken for good reasons should be reworded or deleted. Long instruction files get ignored.

## Other harnesses

The skills follow the Agent Skills format, so harnesses that support it can load them directly. `global/CLAUDE.md` works as an `AGENTS.md`. The agents and hook use Claude Code's formats and would need porting.
