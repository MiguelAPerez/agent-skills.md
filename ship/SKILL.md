---
name: ship
description: >-
  Ship a change as a pull request the safe way — branch off main, stage only the
  relevant files, sanity-check the diff, run the repo's build/tests, and open the
  PR via the project's remote platform. Use this whenever the user wants to "ship
  it", "open a PR", "make a PR", "push this up for review", or otherwise turn
  working-tree changes into a reviewable PR — even if they don't say the word
  "ship".
---

# Ship PR

The point of this skill is to get a change onto a branch and into a PR **without
the classic footguns**: committing to `main`, sweeping up stray files (`.env`,
build artifacts, unrelated edits), or pushing something that doesn't build. Go
through the steps in order and don't skip the diff review — that's the step that
catches the expensive mistakes.

Before opening the PR, identify the project's remote platform from the git remote
URL and use the appropriate tooling. Check the project's platform docs for the
exact API calls — e.g. see `working-with-gitea` if the remote is Gitea.

## 1. Create a feature branch — never commit to `main`

Check the current branch first. If you're on `main`, branch before anything else:

```bash
git branch --show-current
git checkout -b <type>/<short-description>   # e.g. refactor/commit-flat-sections
```

Name it for the change, matching the conventional-commit type (`feat/`, `fix/`,
`refactor/`, `chore/`…).

## 2. Stage only the relevant files; verify the diff

Stage explicitly by path — never `git add -A` / `git add .`, which is how `.env`,
local config, and unrelated edits leak in:

```bash
git add <path1> <path2>
git status            # confirm nothing unexpected is staged
git diff --cached     # read the actual diff before committing
```

Scan for: secrets or `.env` files, build artifacts / caches, debug leftovers, and
edits unrelated to this change. If something doesn't belong, unstage it
(`git restore --staged <path>`). Then commit with a conventional message and any
trailer the repo requires (check `CLAUDE.md` — e.g. a `Co-Authored-By:` line).

## 3. Run the build / tests

Use whatever gate the repo defines — check its `CLAUDE.md` / README for the
canonical command — and proceed only when it passes. Don't invent a test command;
if the repo has no test/build gate, say so and continue.

*Example (a SwiftUI iOS app):*

```bash
xcodebuild -project MyApp.xcodeproj -scheme MyApp -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17' build 2>&1 | tail -4
```

## 4. Push and open the PR

Push the branch:

```bash
git push -u origin "$(git branch --show-current)"
```

Then open the PR using the platform's tooling. The PR body should have a
`## Summary` and a `## Test plan` section. Derive `owner` and `repo` from
the git remote (`git remote get-url origin`). Report the PR number and URL
back to the user.
