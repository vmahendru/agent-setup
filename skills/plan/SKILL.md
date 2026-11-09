---
name: plan
description: Write an implementation plan a reviewer can check without already knowing the codebase. Use before any non-trivial code change.
---

# Plan

Write a plan that proves its claims with citations. The reader may be new to this codebase. They should be able to verify every claim by clicking a file and line.

Do not write code yet.

## 1. Current behavior

Trace the path the change touches, end to end, as it works today. One line per step, each with `path/to/file:line`. Stop at the boundaries of the change.

## 2. The change

Describe the change as edits to that trace: "at `file:line`, add X" or "new step after `file:line`". Start with the simplest version that solves the base case, and give a rough line count.

## 3. Precedent

For every new type, function, interface, or pattern, cite an existing example in the repo that it mirrors. If there is none, give the reason in one sentence.

## 4. Searched and rejected

List the existing helpers, libraries, and patterns you considered, and why each does not fit. An empty list means you did not look. Go look.

## 5. Edge cases

List each edge case with one line on what happens if it is not handled. Mark each as in scope or deferred. The reviewer decides the final list.

## 6. Tests

List the test names for the base case and each in-scope edge case. If the area has no tests, name the characterization test you will add first.

## 7. Risk

List existing callers or behavior the change could break, with citations.

Keep the whole plan short enough to read in five minutes. Then run the `plan-critic` agent on it and include its findings, or "no findings", at the end.
