# Copilot instructions

## Writing style

- Use simple technical English (STE) for all technical writing, including user responses, documentation, issues, pull requests, comments, and commit messages.
- Be concise and direct; avoid verbose, vague, repetitive, or obtuse wording.
- Use an inclusive, respectful, and neutral tone.
- Include only the context needed to understand or act on the information.
- Lead summaries and status updates with outcomes and user impact.
- Write test names in clear, plain language that describes the behaviour and expected outcome.

## GitHub references

- When drafting GitHub issue, pull request, or comment bodies with issue or pull request references, use a bullet list so GitHub renders title previews.
- Use full URLs for issue and pull request references rather than bare `#NNNNN`, particularly for cross-repository references. GitHub will shorten full URLs to `owner/repo#number`.

## GitHub communication

- Never post, submit, edit, or delete GitHub comments, reviews, issue replies, pull request replies, or other messages on my behalf unless I explicitly instruct you to perform that specific action. Drafting is allowed, but submission requires explicit instruction.

## Pull requests

- Name branches `<issue-number>-<two-or-three-word-kebab-case-feature>`, for example `12345-implement-acme-authentication`.
- Prefix PR titles with `<repository>#<issue-number>:`, for example `acme#12345: Implement Acme Authentication` for the `acmeorg/acme` repository.
- Follow the repository PR template. Remove inapplicable bullets or sections instead of rewriting it.
- Keep PR bodies short and focused on the motivation and broad changes. Leave implementation details to the diff.
- Use stacked PRs when changes depend on each other so GitHub shows the correct relationship and diff.
- Mark unfinished PRs as drafts and prefix their titles with `[WIP] `, for example `[WIP] acme#12345: Implement Acme Authentication`.
- Assign every newly created draft PR to me.
- When a PR is ready for review, remove the `[WIP] ` prefix and mark it ready.
- After pushing PR changes, start a lightweight background agent to monitor required CI checks. Report when all required checks pass, or report the failure details when a required check fails.
- When a PR review comment is fixed, reply `Addressed in <full-commit-sha>` using the complete 40-character SHA, then resolve the thread.
