# Engineering defaults

These are defaults, not laws. Follow their intent. If one makes the code worse here, break it and say why in your summary.

## Before writing code
- Check the repo and its dependencies for something that already does the job. Protocol, serialization, and parsing code should almost always come from a library: gRPC status and error packages, not hand-rolled encoders.
- Read 2-3 nearby files and match their naming, error handling, and structure.
- For a non-trivial change, plan first using the `plan` skill. Get the plan approved before writing code.

## Following the codebase
- At boundaries other code touches (APIs, errors, logging, config), follow the existing convention even if it is not what you would choose.
- Inside new code you own, you may deviate if you can justify it in one sentence. Put that sentence in the summary.
- Do not refactor unrelated code in a feature change. Propose it separately.

## Writing code
- Build in this order: the simplest base case that works end to end, then the approved edge cases, then any extraction into helpers. Use the `pr-stack` skill when the change is large.
- Prefer the smallest direct change. A reader should be able to follow the main path without jumping between files.
- Add an abstraction only when it has two real uses now, or when it hides real complexity. One implementation behind an interface usually needs a reason, such as a test seam or a process boundary.
- Name a function after what it does and what it returns. If the name needs "handle", "process", "manage", or "util", the function may be doing too much or the name may be too vague.
- Write the idiom of the language in use. C++: RAII, the standard library, value semantics, and const correctness. Go: small interfaces at the consumer, and errors returned with context.

## Edge cases
- Handle cases the system can reach: real inputs, known failure modes, concurrency, data loss, and security.
- Validate at trust boundaries, then trust the data internally.
- If a case is possible but unlikely, and handling it adds meaningful code, leave it out and list it in your summary with one line on what would happen. I'll decide.

## Tests
- Write the test names first. They are the spec for the base case and each edge case.
- When code has no tests, add a characterization test around the behavior you change before changing it.

## Writing for people
- The reader is a teammate who has not seen this session. Do not mention the task, your process, or earlier versions of the code.
- Comment only on why: a constraint, a tradeoff, or a surprising behavior. Do not restate the code.
- Lead with the conclusion. Use short declarative sentences. Cut anything the reader would not miss.

## Before calling it done
- Reread the diff and ask what can be deleted without losing required behavior. Delete it.
- For anything beyond a small change, run the `simplifier` agent on the diff and apply the findings you agree with.
- Summarize what changed, what you chose not to handle, and anything you are unsure about. Paste the commands you ran to verify it and their results.
