#!/bin/bash

# Initialize a new Next.js project with TypeScript, Tailwind, and App Router
# Usage: ./scaffold.sh

npx create-next-app@latest ./ \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --use-npm --no-install \
  --react-compiler

# Create API directory for backend actions
mkdir -p src/app/api
echo "// Example API Route" > src/app/api/route.ts

echo "Project initialized with docs and api folders."
