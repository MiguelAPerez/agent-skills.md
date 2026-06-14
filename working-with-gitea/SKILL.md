---
name: working-with-gitea
description: >-
  Reference for interacting with a self-hosted Gitea remote — how to derive
  owner/repo, which MCP tools to use for PR and review operations, and known API
  quirks. Consult this whenever a skill needs to talk to a Gitea remote (creating
  PRs, fetching reviews, posting comments, resolving threads).
---

# Working with Gitea

## Environment

All reads and writes go through the **Gitea MCP** (`mcp__gitea__*` tools). `gh`
does not apply — Gitea is not GitHub. Never fall back to `tea`, `gh`, or
hand-rolled `curl` for operations the MCP covers.

If the `mcp__gitea__*` tools aren't present in the session, stop and tell the
user to install/configure the Gitea MCP server before continuing.

## Derive owner and repo

```bash
git remote get-url origin
# e.g. https://git.example.com/alice/my-repo.git  →  owner=alice  repo=my-repo
```

Or use the slug the user gives you directly if you're not inside the target repo.

## Creating a PR

```
mcp__gitea__pull_request_write(
  method: "create",
  owner: <owner>,
  repo: <repo>,
  head: <current branch>,
  base: "main",
  title: "<conventional title>",
  body: "<markdown body>"
)
```

## Fetching review feedback

Gitea splits review feedback across three places. Pull all three — the real
substance often lives in per-line comments even when a review's summary body is
empty:

1. Top-level discussion comments:
   ```
   mcp__gitea__issue_read(method: "get_comments", owner, repo, issue_number: <pr-number>)
   ```

2. Reviews and their summary bodies:
   ```
   mcp__gitea__pull_request_read(method: "get_reviews", owner, repo, pull_number: <pr-number>)
   ```

3. Per-line comments for **each** review:
   ```
   mcp__gitea__pull_request_read(method: "get_review_comments", owner, repo, pull_number: <pr-number>, review_id: <id>)
   ```

## Posting a comment

```
mcp__gitea__issue_write(
  method: "add_comment",
  owner: <owner>,
  repo: <repo>,
  issue_number: <pr-number>,
  body: "..."
)
```

## Resolving review threads

The Gitea MCP doesn't expose a thread-resolve method (`pull_request_review_write`
only does create/submit/delete/dismiss). Use `scripts/gitea-curl.sh`, which reads
credentials from the Claude Desktop or Cursor MCP config and delegates to
`openstash curl`:

```bash
scripts/gitea-curl.sh --operation repoResolvePullReviewComment \
  --param owner=<owner> --param repo=<repo> --param id=<comment_id>
```

**Quirk:** the correct API path is `/repos/{owner}/{repo}/pulls/comments/{id}/resolve`
— no PR index in the path. The path with the index returns **405**; the correct
one returns **204** with an empty body. `openstash curl` resolves this via the
spec so the right path is used automatically.
