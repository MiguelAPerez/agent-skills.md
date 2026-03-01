#!/bin/bash

# Initialize a new Next.js project with TypeScript, Tailwind, and App Router
# Usage: ./scaffold.sh <project-name>

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: ./scaffold.sh <project-name>"
  exit 1
fi

npx create-next-app@latest "$PROJECT_NAME" \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --use-npm --no-install

# Create docs folder
mkdir -p "$PROJECT_NAME/docs"
echo "# Project Documentation" > "$PROJECT_NAME/docs/README.md"

echo "Project $PROJECT_NAME initialized with docs folder."
