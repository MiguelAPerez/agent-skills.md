---
name: persistent-agent-memory
description: >-
  File-based persistent memory for sub-agents and skills — where to store it,
  memory types (user, feedback, project, reference), save/recall rules, and
  MEMORY.md indexing. Read this skill when an agent definition says it uses
  persistent memory, or when saving or recalling learnings across sessions.
---

# Persistent Agent Memory

Cross-session memory for agents. Harness-agnostic: the files live in your
**sub-agents** checkout, not inside a vendor-specific config dir.

## Where memory lives

Each agent with persistent memory has a `memory/` directory next to its
`agent.md`:

```
<sub-agents-repo>/agents/<agent-name>/memory/
```

Resolve the memory directory in this order:

1. **In the sub-agents workspace** — if `agents/<agent-name>/memory/` exists relative
   to the current workspace root (main checkout or git worktree), write there.
2. **Harness symlink** — if step 1 does not apply (e.g. agent launched from another
   repo's worktree, or a cloud-agent checkout), use the harness path when it
   exists: `~/.claude/agent-memory/<agent-name>/` (Claude Code — kept in sync with
   canonical storage by `link.sh` in the main sub-agents checkout).
3. **`private-context`** — resolve `<sub-agents-repo>/agents/<agent-name>/memory/`
   from the paths table when neither of the above is available.

Do not bake harness-specific paths into agent definitions — resolve at runtime
using this order. Hardcoding `~/.claude/...` in prompts is only wrong when it
*replaces* repo-relative resolution; it is the correct fallback outside the
sub-agents workspace.

| Harness | Notes |
|---------|-------|
| Any (in sub-agents workspace) | `agents/<agent-name>/memory/` relative to workspace root |
| Claude Code (elsewhere) | `~/.claude/agent-memory/<agent-name>/` → canonical via `link.sh` |
| Cursor | Repo path when workspace is sub-agents; no Claude symlink |

The directory exists after `./scripts/link.sh` — write to it with the Write
tool. Do not run mkdir or check for existence first.

## When to read this skill

- An agent definition references `persistent-agent-memory` or has `memory:` in
  its frontmatter (Claude Code).
- You are about to save or recall cross-session learnings.
- The user asks you to remember, forget, or check prior agent work.

## Purpose

Build up institutional knowledge across conversations: who the user is, how
they like to collaborate, validated approaches, and non-obvious context that
is not derivable from the codebase.

If the user explicitly asks you to remember something, save it immediately as
whichever type fits best. If they ask you to forget something, find and remove
the relevant entry.

## Types of memory

<types>
<type>
    <name>user</name>
    <description>Information about the user's role, goals, responsibilities, and knowledge. Tailor future behavior to their preferences and perspective.</description>
    <when_to_save>When you learn any details about the user's role, preferences, responsibilities, or knowledge</when_to_save>
    <how_to_use>When your work should be informed by the user's profile — e.g. explain code at the right depth for their experience level.</how_to_use>
</type>
<type>
    <name>feedback</name>
    <description>Guidance about how to approach work — what to avoid and what to keep doing. Record from failure AND success.</description>
    <when_to_save>When the user corrects your approach OR confirms a non-obvious approach worked. Include *why* so you can judge edge cases later.</when_to_save>
    <how_to_use>Let these guide behavior so the user does not repeat the same guidance.</how_to_use>
    <body_structure>Rule/fact, then **Why:** and **How to apply:** lines.</body_structure>
</type>
<type>
    <name>project</name>
    <description>Ongoing work context not derivable from code or git — goals, incidents, deadlines, decisions.</description>
    <when_to_save>When you learn who is doing what, why, or by when. Convert relative dates to absolute when saving.</when_to_save>
    <how_to_use>Shape suggestions with the motivation behind current work.</how_to_use>
    <body_structure>Fact/decision, then **Why:** and **How to apply:** lines.</body_structure>
</type>
<type>
    <name>reference</name>
    <description>Pointers to external systems — where bugs are tracked, which dashboard pages oncall, etc.</description>
    <when_to_save>When you learn about a resource in an external system and its purpose.</when_to_save>
    <how_to_use>When the user references an external system or information likely stored in one.</how_to_use>
</type>
</types>

## What NOT to save

- Code patterns, conventions, architecture, or file paths — read the repo.
- Git history — `git log` / `git blame` are authoritative.
- Fix recipes — the fix is in the code; the commit message has context.
- Anything already in CLAUDE.md, AGENTS.md, or project docs.
- Ephemeral task state for the current conversation only.

If the user asks to save a PR list or activity summary, ask what was
*surprising* or *non-obvious* — that is the part worth keeping.

## How to save memories

**Step 1** — write the memory to its own file (e.g. `feedback_no_prod_deploy.md`):

```markdown
---
name: {{memory name}}
description: {{one-line description — specific enough to judge relevance later}}
type: {{user, feedback, project, reference}}
---

{{content — for feedback/project: rule/fact, **Why:**, **How to apply:**}}
```

**Step 2** — add a one-line pointer in `MEMORY.md` (index only, no frontmatter):

```markdown
- [Title](file.md) — one-line hook
```

Keep entries under ~150 characters. `MEMORY.md` is loaded into context — lines
after 200 truncate, so keep the index concise.

- Organize by topic, not chronologically
- Update or remove stale memories
- Check for an existing memory to update before creating a duplicate

## When to access memories

- When memories seem relevant, or the user references prior work.
- When the user explicitly asks to check, recall, or remember.
- If the user says to *ignore* memory: do not apply, cite, or mention it.

Memory can become stale. Before acting on a memory alone, verify against
current files or resources. Trust what you observe now — update or remove stale
entries.

## Before recommending from memory

A memory naming a function, file, or flag is a claim from *when it was written*.
Before the user acts on your recommendation:

- Named file path → check it exists
- Named function or flag → grep for it

"The memory says X exists" ≠ "X exists now."

For *recent* or *current* state, prefer `git log` or reading code over a
frozen snapshot memory.

## Memory vs plans vs tasks

| Mechanism | Use for |
|-----------|---------|
| **Memory** | Learnings useful in *future* conversations |
| **Plan** | Aligning on approach for a non-trivial task *this* session |
| **Tasks** | Tracking steps and progress *this* session |

User-scoped memory (`memory: user` in Claude) applies across all projects —
keep entries general enough to reuse.

## MEMORY.md

If `MEMORY.md` is empty, it stays empty until you save the first memory. Each
new entry appears as a one-line index pointer.
