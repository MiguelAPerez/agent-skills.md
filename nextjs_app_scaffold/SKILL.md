---
name: nextjs_app_scaffold
description: Use this skill to bootstrap a new Next.js application with TypeScript, Tailwind CSS, React, and an API backend.
---

# Next.js App Scaffold Skill

This skill provides a standardized way to create premium, production-ready Next.js applications.

## Usage Instructions

When asked to create a new Next.js app, follow these steps:

### 1. Initialize the Project

Use the provided helper script to initialize a new Next.js project with the correct flags and a `docs` folder:

```bash
./scripts/scaffold.sh
npm install
npm run dev
```

The script will run `npx create-next-app@latest` with:

- TypeScript
- Tailwind CSS
- ESLint
- App Router
- `src/` directory
- Import alias `@/*`
- **Automatic `docs` folder creation**
- **Optional native pre-commit git hook** (Install via `npm run githook:install`)

### 2. Design Guidelines

- **Rich Aesthetics**: Use vibrant colors, dark modes, glassmorphism, and dynamic animations.
- **Premium Typography**: Use Google Fonts like Inter or Outfit.
- **Micro-animations**: Add subtle hover effects and transitions for a premium feel.

### 3. Final Step: Call Onboarding Skill

Once the project is initialized, **immediately call the `onboarding` skill** to document the initial state and verify that the `docs` folder is correctly set up.
