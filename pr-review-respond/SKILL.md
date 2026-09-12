---
name: pr-review-respond
description: >-
  Triage the review feedback on a pull request — fetch every review comment,
  judge which points are valid vs. not (against the repo's own conventions and
  platform/scope constraints), pause for the user to confirm, then implement the
  agreed fixes, reply on each review thread, and resolve fixed threads. Use this whenever the
  user wants to evaluate / triage / address / respond to PR review comments, "see
  what the bot said", decide which review feedback to act on, or reply to a
  reviewer — even if they don't say the word "review".
---

# Respond to a PR Review

This captures the repeatable loop for turning reviewer feedback (often from a
review bot, sometimes a human) into a decision, a set of fixes, and
a reply — without blindly "fixing" everything a reviewer flags. Many review
comments are wrong for *this particular* repo, and acting on them would make the
code worse. The skill's point is to **separate signal from noise, get the user's
sign-off, then close the loop on the PR.**

The guiding principle: **the user decides what's valid.** You do the legwork —
gather the comments, form a reasoned recommendation on each — but you stop and
wait before changing code, and you never reply on the PR until the fixes are in.

Before starting, identify the project's remote platform from the git remote URL
and confirm you have the right tooling available. Check the platform-specific docs
for the exact API calls — e.g. see `working-with-gitea` if the remote is Gitea.

## Workflow

### 1. Fetch the feedback

PR review feedback typically lives in three places — pull all of them, because
the real substance often lives in per-line comments even when a review's summary
body is empty:

1. Top-level discussion comments on the PR
2. The reviews themselves and their summary bodies
3. Per-line (inline) comments for each review

Consolidate these into one readable list, keyed by **comment id** (you'll
reference these ids when triaging and resolving). Use a table like this:

| ID | Source | File | Line | Status | Body |
|----|--------|------|------|--------|------|
| 42 | inline | `src/foo.ts` | 12 | open | "Consider using X instead of Y" |
| 43 | review summary | — | — | open | "Missing error handling throughout" |
| 44 | discussion | — | — | open | "Is this change intentional?" |

If the user didn't give a PR number, infer it from the current branch or ask.

### 2. Evaluate each comment

Go through the comments one at a time and classify each as **valid** (worth
fixing) or **not valid** (decline), with a one-line reason grounded in evidence —
not vibes. Read the code each comment points at before judging.

The reasoning that matters most is **fit with this repo**, because a review bot
doesn't know the project's constraints. Before accepting any "you should do X":

- **Check the project's scope and platform.** Read the repo's `CLAUDE.md` /
  README for declared constraints. Comments about platforms, runtimes, or
  environments the project doesn't target are usually **invalid** — fixing them
  adds dead code. *(Worked example: an iOS-only app has no macOS build, so review
  comments about macOS/visionOS/AppKit/`NSPasteboard`, or "wrap `import UIKit` in
  `#if canImport(UIKit)`", are invalid — there's no build where they matter.)*
- **Check existing convention.** If the surrounding codebase already does the
  opposite of what the comment asks, *on purpose*, the new code matching that
  pattern is correct, not a defect. Cite the precedent. *(Example: if existing
  files import `UIKit` unconditionally and clipboard helpers are `#if os(iOS)`-only,
  a new file following that pattern is right — not a defect.)*
- **Take genuine bugs / robustness wins.** Correctness issues that hold
  regardless of scope are **valid** even when minor (e.g. not stripping `\r` from
  a CRLF string before rendering). Cheap, real fixes are worth it.
- **Answer "confirm this is intentional" questions** — they need a reply, not a
  code change. If the change was the explicit goal of the PR, say so plainly.

Present the verdict grouped by bucket — e.g. **Not valid / won't fix**,
**Valid / worth fixing**, **Confirmed intentional** — each item with its reason,
a `file:line` link, and the **`comment #<id>`** from the fetched comments.
End with a clear recommendation of what to actually do.

### 3. Stop and wait for confirmation

**Do not edit code yet.** The user reviews your evaluation and says which items
to act on. They may overrule you in either direction — respect that.

### 4. Implement the agreed fixes

Make the changes, then **build/test to confirm** using whatever gate the repo
uses (check `CLAUDE.md` for the build command). Commit and push to the existing
PR branch. Match the repo's commit-message convention, including any required
trailer.

### 5. Reply on each thread (default)

**Default: reply in-thread — not one PR-wide summary.** After pushing fixes,
post a reply on **every review thread you triaged** — one response per comment
id from step 1. Match the bucket from your triage:

| Bucket | Reply should say |
|--------|------------------|
| **Fixed** | What changed, why, commit `<sha>`, and that build/tests passed |
| **Won't fix** | Why it doesn't apply here — cite the repo constraint or precedent |
| **Confirmed intentional** | Yes, intentional — brief why |

Use the platform's **in-thread reply** API (not a top-level PR comment). Check
the platform-specific docs for the exact call — e.g. on Gitea,
`pull_request_review_write(method: "reply_comment", comment_id, body, ...)`.

For **top-level discussion comments** (not tied to a review thread), reply on
that comment thread if the platform supports it; otherwise `@`-mention the
reviewer in a direct reply.

Keep each reply factual and brief. **Do not** also post a consolidated
"Review follow-up" summary on the PR — per-thread replies are the closed loop
reviewers expect.

#### Fallback: single summary comment (user opt-in only)

Only if the user **explicitly** asks for one comment (e.g. "just post a
summary", "single comment is fine") — skip per-thread replies and post one
consolidated top-level comment instead:

```markdown
## Review follow-up

### Fixed
- **<short title>** — <what changed and why>. (commit `<sha>`)

### Won't fix (not applicable to this project)
- **<comment>** — <reason it doesn't apply here, citing the precedent/constraint>.

### Confirmed intentional
- **<comment>** — yes, intentional: <why>.
```

If the user hasn't opted into this fallback, use per-thread replies even when
there are many comments.

### 6. Resolve only the fixed threads

After in-thread replies are posted (or the user-opt-in summary, if used), mark **only** the review threads that
landed in the **Fixed** bucket (and that the user confirmed) as resolved. Do
**not** resolve every open thread on the PR — especially not items classified as
**Won't fix** or **Confirmed intentional**. Those should stay open so the
decision stays visible on the diff.

List the exact comment IDs from the **Fixed** bucket in your triage before
resolving, and confirm them with the user. Use the platform's API to resolve
each thread — check the platform-specific docs for the exact call and any quirks.

## Why this shape

Reviewers (especially bots) optimize for catching *possible* issues, not for
knowing your project. Treating every comment as a mandate produces churn and
dead code; ignoring them loses the real bugs they do catch. The valuable work is
the judgment in step 2 — which is exactly why step 3 hands that judgment to the
user before anything ships.
