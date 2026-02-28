---
name: onboarding
description: Use this skill when first entering a new project or when asked to "get a basic understanding" of the codebase. It helps to map out the structure and locate documentation.
---

# Project Onboarding & Discovery

When you are tasked with understanding a new project, follow these steps to orient yourself:

## 1. Look for Entry Points

- Check the root directory for a `README.md` file. Read it to understand the project's purpose, setup, and core functionality.
- Look for a `docs/` or `documentation/` folder. Explore its contents to find architecture diagrams, API specs, or guides.

## 2. Map the Structure

- Use `list_dir` on the project root to see high-level folders (e.g., `src/`, `lib/`, `tests/`, `config/`).
- Identify the tech stack by looking for package files (e.g., `package.json`, `requirements.txt`, `composer.json`, `go.mod`).

## 3. Propose Documentation

- If no `README.md` exists, **recommend creating one**.
- If there is no dedicated `docs/` folder and the project is complex, **suggest setting one up** to store future knowledge.

## 4. Suggest Documentation Updates

- After implementing a new feature or updating existing functionality, **suggest updating the relevant documentation** (e.g., `README.md` or files in `docs/`) to reflect the changes.

## 5. Ask Clarifying Questions

- Based on what you find, ask the user about any missing pieces or specific areas of the code they want you to focus on first.
