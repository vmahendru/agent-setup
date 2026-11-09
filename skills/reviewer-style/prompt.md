Build a style guide for the code reviewer with GitHub username REVIEWER, from their review history in this repo.

1. Use gh to pull their inline PR review comments (repos/{owner}/{repo}/pulls/comments, paginated, filtered to that user, with path, body, and diff_hunk). Also pull their top-level review bodies from the last ~50 merged PRs. Then pull 5-10 PRs they authored and read their own code comments and PR descriptions.
2. From their review comments, extract what they push back on. Group by theme: naming, structure and abstraction, error handling, tests, comments and docs, scope. Rank themes by how often they come up. Ignore one-offs.
3. From the code they wrote themselves, extract how they write: comment density, comment length and tone, and PR description structure.
4. Write ~/.claude/reviewers/REVIEWER.md with:
   - Their top rules, one line each, ranked by frequency, each with one short before/after drawn from a real comment.
   - How they write comments and PR descriptions, with one representative example of each.
   - Things they consistently don't care about, so I don't over-optimize.
   Keep it under 60 lines.
5. Don't put this file in the repo. Show me the ranked themes with comment counts so I can sanity-check the result.
