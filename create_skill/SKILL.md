---
name: create_skill
description: Instructions for creating new agent skills. Use this skill whenever you are asked to create, generate, or set up a new skill.
---

# Creating a New Skill

When the user asks you to create a new skill, follow these steps strictly:

## 1. Structure

Create a new directory for the skill under `/Users/miguelperez/Toolbox/Skills/` with a descriptive, snake_case name (e.g., `deploy_app`, `run_tests`).

## 2. The `SKILL.md` File

Create a `SKILL.md` file inside the new directory. This file is mandatory.

- Define the `name` and `description` in the YAML frontmatter at the top of the file.
- The `description` should clearly explain when the skill should be used, so the agent can naturally pick it up.
- The rest of the file should contain detailed markdown instructions for the agent to follow when executing the skill. Keep instructions clear, precise, and actionable. Be sure to specify exactly what tools the agent should use if applicable.

## 3. Additional Resources (Optional)

If the skill requires extra assets, create subdirectories within the skill's folder:

- `scripts/`: For any bash or python scripts the agent might need to run.
- `examples/`: For reference implementations or usage patterns.
- `resources/`: For templates, config snippets, or other static files.

## 4. Review

After creating the `SKILL.md` and any required subdirectories or files, tell the user that the skill has been created and is ready to use.
