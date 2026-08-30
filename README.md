# agent-skills.md

This is a collection of skills for an agent to use in its daily tasks. Its general structure is as follows:

- `SKILL.md`: The skill description and instructions.
- `scripts/`: Any scripts the skill might need to run. Scripts live next to
  `SKILL.md`, not in the chat workspace — skills must tell the agent how to
  resolve the absolute path (see `working-with-gitea` for the pattern).
- `examples/`: Any examples of how to use the skill.
- `resources/`: Any resources the skill might need to run.

## Cross-repo skills

Some skills are shared across repos:

| Skill | Repo | Purpose |
|-------|------|---------|
| `persistent-agent-memory` | this repo | File-based memory for [sub-agents](https://github.com/MiguelAPerez/sub-agents.md) |
| `verify-on-simulator` | this repo | Manual UI verification on Apple simulators — delegate to [simulator-verifier](https://github.com/MiguelAPerez/sub-agents.md) subagent |

## Related repos

| Repo | Purpose |
|------|---------|
| [sub-agents.md](https://github.com/MiguelAPerez/sub-agents.md) | Harness-agnostic sub-agent definitions (references skills from this repo) |
