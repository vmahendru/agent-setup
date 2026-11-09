---
name: pr-stack
description: Split a large change into a stack of small, reviewable PRs built in order, with no placeholder code. Use when a change will touch many files or more than a few hundred lines.
---

# PR stack

Build the change in the order a reviewer should read it. Do not write the whole change and slice it afterward. That is what produces placeholder edits that a later PR undoes.

## The stack

Each PR compiles, passes tests, and does something real on its own.

1. **Prep (optional).** Refactors only, with no behavior change. Renames, moves, and extracting an existing seam. Say "no behavior change" at the top of the description.
2. **Base case.** The simplest end-to-end path that works, with its tests. No edge cases and no new abstractions beyond what this path needs.
3. **Edge cases.** One commit per approved edge case, each with its test. Split into more PRs if this grows past ~400 lines of logic.
4. **Extraction.** Helpers or abstractions that the code now clearly needs, because duplication or complexity actually exists. If nothing needs extracting, skip this PR.

Mechanical changes (generated code, renames across many files) can be large. Keep them in their own PR, separate from logic.

If a PR needs a stub or placeholder to compile, the order is wrong. Reorder so the dependency lands first, or merge the two steps.

## Every PR description

- **What and why:** two or three sentences, conclusion first.
- **Where this is going:** on the first PR, a short sketch of the end state and the list of upcoming PRs. On later PRs, one line on where this one sits.
- **Reading guide:** the order to read files in, which files are mechanical, and the one thing to scrutinize.
- **Evidence:** the commands you ran (build, tests, lint) and their results.
- **Deferred:** edge cases intentionally not handled, one line each.
