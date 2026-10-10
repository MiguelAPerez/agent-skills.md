---
name: multi-pr-review-cycle
description: >-
  Run a parallel, multi-PR review-response cycle: request review on each PR,
  triage feedback with read-only subagents, judge validity, fix with per-PR
  subagents that resolve their own threads, then squash-merge with rebase --onto
  when PRs stack. Use when asked to "run the review cycle", process bot or
  reviewer feedback across one or more PRs, fan feature work out to parallel
  agents and bring it back through review, or merge a stack of dependent PRs.
---

# Multi-PR review cycle

A repeatable playbook for taking one or more open PRs through automated review
and back to merge-ready, using parallel subagents to keep the parent context lean.
For platform-specific API calls see `working-with-gitea` (Gitea) or the equivalent
for your remote. For a single PR with user confirmation at each step, use
`pr-review-respond` instead.

## Before you start

1. Derive `owner` / `repo` from `git remote get-url origin`.
2. **Ask the user who to request as reviewer** — bot username, team member, or
   none (skip the request step). This varies by person and repo; do not assume a
   default like a project-specific bot name.
3. **Ask the user which model to use for subagents** (triage and fix) before
   spawning any. Do not assume a default; preferences differ by user and task.
4. Read `CLAUDE.md` / README for the repo's build gate, commit conventions, and
   declared scope constraints — subagents need these for triage.
5. Confirm platform tooling is available (e.g. Gitea MCP per `working-with-gitea`).

## Subagent pattern

Fan work out to **one subagent per PR** for triage and fix phases, using the
model the user chose in step 3 above. Prefer read-only subagents for triage (no
edits, commits, pushes, or comments — report only). Run fix subagents in the
background when handling several PRs at once. Background agents are tied to this
session — keep it open until they finish.

Each subagent should reset to the remote branch before working:
`git fetch origin && git reset --hard origin/<branch>`.

## Phase 0 — build and open PRs (if not already open)

When fanning new work out to agents first: each agent branches off the default
base branch (usually `main`), builds a self-contained change, runs the repo's
build gate, pushes its branch, and does **not** open the PR. The parent verifies
scope (`git diff --stat origin/main origin/<branch>`) and opens each PR. Flag
any shared-file overlaps between PRs in the bodies so merge order is obvious.

Use `ship` for the single-PR variant of branch → gate → push → open.

## Phase 1 — request review and poll

If the user named a reviewer in step 2, request them on every PR using the
platform's API (e.g. Gitea:
`pull_request_write(method: "add_reviewers", …, reviewers: [<reviewer>])`).
If they said none, skip the request and poll for reviews that already exist.

Poll until each PR has a **real** review — state `REQUEST_CHANGES`, `APPROVED`,
or `COMMENT`, not a pending `REQUEST_REVIEW`. Poll in one background loop so you
are re-invoked on completion rather than burning turns on sleep. Fetch reviews
via the platform MCP/API (e.g. `pull_request_read(method: "get_reviews", …)`).

Record each review's `id` and `comments_count`.

## Phase 2 — triage (read-only subagent per PR)

Spawn one read-only subagent per PR with the model from step 3. Each agent:

1. Resets to `origin/<branch>`.
2. Fetches the review body and inline comments (see `working-with-gitea` for the
   three feedback locations).
3. Reads the referenced code.
4. Emits one line per comment:

```
[n] <file>:<line> — <summary> — VERDICT: VALID|INVALID|UNSURE — <reason grounded in the code> — Fix: <if valid>
```

Give each agent the project's design constraints and scope so it can decline
correctly (same criteria as `pr-review-respond` step 2).

## Phase 3 — judge validity yourself

Triage subagents advise; **you** decide. Do not rubber-stamp the bot. Verify
anything touching correctness or security before accepting or declining.

Apply the same judgment rules as `pr-review-respond`:

- **Decline** when the comment conflicts with declared project scope, existing
  convention, or intentional design; when it asks for out-of-scope work; or when
  it is stylistic preference with no correctness impact.
- **Accept** when the comment identifies a real bug, security issue, missing
  authz, broken tests, dependency skew, or robustness gap that holds regardless
  of scope.

Map each accepted/declined verdict to its inline **comment id** — you need these
for resolving threads in phase 4.

If the user wants to confirm before fixes (recommended when feedback is
ambiguous), pause here as `pr-review-respond` step 3 describes.

## Phase 4 — fix (subagent per PR)

Spawn one fix subagent per PR (same model as triage unless the user says
otherwise) with the **exact** accepted fixes plus the declined items (with
reasons, for the summary comment). Each agent:

1. `git reset --hard origin/<branch>`; implement only the listed fixes.
2. Run the repo's build gate (from `CLAUDE.md` — do not invent commands).
3. Commit using the repo's message convention; stage by path (never `git add -A`;
   do not commit build output or secrets); push to the PR branch.
4. Post a summary comment on the PR (see `pr-review-respond` step 5 for format:
   Fixed / Won't fix / Confirmed intentional).
5. **Resolve only fixed threads** — leave declined ones open. Use the platform's
   resolve API per `working-with-gitea`.
6. Do **not** merge, change draft state, or dismiss the review.

Parent verifies each push (`git log --oneline -2 origin/<branch>`).

## Phase 5 — merge (squash) and rebase the rest

When PRs share files, merge order matters. For each PR in dependency order:

1. Un-draft if needed (e.g. remove a `WIP:` title prefix).
2. Squash-merge with a clean title (e.g. `feat: … (#N)`) and delete the branch.
3. Because squash-merge rewrites history, rebase each **remaining** branch with
   `--onto`, dropping the now-squashed base — not a plain `git rebase main`,
   which replays squashed commits and causes conflicts:

   ```bash
   git fetch origin
   git rebase --onto origin/main <old-base-sha> <branch>
   ```

4. Resolve shared-file conflicts by keeping **both** sides' intent. Re-run the
   build gate, `git push --force-with-lease`, and retarget the PR base if needed.

## Phase 6 — close out

Update any tracking issue (check off merged items, note deferred follow-ups) and
confirm post-merge CI is green.
