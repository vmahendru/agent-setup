---
name: reviewer-style
description: Learn a reviewer's preferences and writing style from their PR history, or check a diff against a saved guide before requesting review. Use when asked to learn or match a specific reviewer.
---

# Reviewer style

## Building a guide

Follow `prompt.md` in this folder, with REVIEWER replaced by the reviewer's GitHub username. It needs the `gh` CLI, signed in, run from inside the repo.

The guide describes a real person's preferences in a specific codebase. It lives in `~/.claude/reviewers/`, never in a shared or public repo.

## Applying a guide

Before requesting review from someone with a guide in `~/.claude/reviewers/`, read the guide and check the diff against each rule. Fix clear violations. Match their comment and PR description style. Do not polish things the guide says they don't care about. List anything ambiguous in the PR description rather than guessing.

Where the guide conflicts with the global defaults, follow the guide for that reviewer's code. Mention the conflict in your summary.
