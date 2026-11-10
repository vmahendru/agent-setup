# Problems this repo addresses

Frontier models usually get correctness, performance, and testability right. Readability and extensibility are where they slip. That matters when a human reviewer reads every line. It also matters when nobody does, because agents read the codebase too, and they copy what they find nearby.

## In the code agents write

- **Reinventing libraries.** Hand-written encoders for gRPC errors, JSON, and other structured formats, where a standard package already exists.
- **Guidance read as law.** An instruction meant as a default gets applied rigidly, even where it makes the code worse.
- **Weak names.** Function names that are vague, misleading, or just odd.
- **Unnecessary indirection.** Interfaces, wrappers, and layers with one real use.
- **Prose written for itself.** Verbose comments, docs, and descriptions that read like notes to self rather than writing for a teammate.
- **Non-idiomatic C++.** Code that works but that an experienced C++ developer would rewrite on sight.
- **Obscure edge cases.** Handling for unlikely cases that sometimes helps but often makes the code worse.
- **Complicated first drafts.** It often takes several rounds of "is there a simpler way?" before the code converges.

## In reviewing it

- **Huge PRs.** A single change often spans 25+ files and 1,000+ lines.
- **Splitting after the fact doesn't work.** Cutting a finished change into smaller PRs creates placeholder edits that later PRs undo. It's hard to tell placeholders from real changes, and each PR's context lives in the ones after it.
- **Plans are hard to review in an unfamiliar codebase.** Checking a plan's claims takes knowledge of the code that a newer team member doesn't have yet.
- **Conventions are unclear in weak codebases.** It isn't obvious when to follow existing patterns and when to do something better.
- **Thin CI.** Without good automated checks, review is the only gate.
- **Review is slow.** Reading code carefully is a skill, and agent output gives it a lot of volume to chew through.

## Different perspectives on code review

There's no settled view on how much human review agent-written code needs.

**Review is becoming optional.** If CI covers correctness and performance, and refactoring is cheap, line-by-line review costs more than it catches. Style matters less when code can be rewritten on demand.

**Review every line.** Whoever approves a change should understand it. Reviewers carry knowledge of the codebase and its history that CI can't encode. Readable code compounds, because humans and agents both build on whatever is already there.

**Review intent, automate the rest.** Machines check what can be measured: tests, lint, complexity, duplication. Humans spend their attention on design, scope, names, and risk.

**Reviewer preferences.** Matching a specific reviewer's taste can feel like overhead that isn't grounded in first principles. Often, though, that taste is accumulated team convention, and matching it is part of shared ownership. Where a preference really is personal, writing it down makes it cheap to follow and easy to discuss openly.

This repo doesn't pick a side. It assumes a human will read the code, and aims to make that reading fast. The same defaults still help when nobody reads every line.

## Where each problem is addressed

| Problem | Addressed by |
|---|---|
| Reinvented libraries | `plan` skill (searched-and-rejected section), `plan-critic`, `global/CLAUDE.md` |
| Guidance read as law | `global/CLAUDE.md` (stated as defaults with permission to break them) |
| Weak names, indirection, wordy prose | `global/CLAUDE.md`, `/simplify`, `simplifier` |
| Non-idiomatic C++ and Go | `hooks/lint-changed.sh`, `templates/.clang-tidy` |
| Obscure edge cases | `plan` skill (edge cases approved up front), `global/CLAUDE.md` (unlikely cases listed, not coded) |
| Complicated first drafts | `pr-stack` (base case first, extraction last), `/simplify` |
| Huge PRs and placeholder splits | `pr-stack` skill |
| Plans in an unfamiliar codebase | `plan` skill (trace-first, cited precedent), `plan-critic` |
| Unclear conventions | `global/CLAUDE.md` (follow at boundaries, deviate inside new code) |
| Thin CI | `global/CLAUDE.md` (characterization tests, evidence in summaries), `pr-stack` |
| Slow review | `pr-stack` (reading guide in each PR description) |
| Reviewer preferences | `reviewer-style` skill |
