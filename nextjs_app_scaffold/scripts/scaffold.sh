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

# Create docs folder
mkdir -p docs
echo "# Project Documentation" > docs/README.md

# Create API directory for backend actions (Example Ping Route)
mkdir -p src/app/api/ping
cat <<EOF > src/app/api/ping/route.ts
import { NextResponse } from 'next/server';

interface PingRequestBody {
  name: string;
}

export async function GET() {
  return NextResponse.json({ message: 'pong' });
}

export async function POST(request: Request) {
  try {
    const body: PingRequestBody = await request.json();
    return NextResponse.json({ 
      message: 'pong',
      received: body.name 
    });
  } catch (error) {
    return NextResponse.json({ error: 'Invalid request body' }, { status: 400 });
  }
}
EOF

echo "Project initialized with docs and api folders."

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
  git init
fi

# Create scripts directory
mkdir -p scripts

# Create git hook installer script
INSTALL_HOOKS_SCRIPT="scripts/install-hooks.sh"
cat <<EOF > "$INSTALL_HOOKS_SCRIPT"
#!/bin/bash

PRE_COMMIT_HOOK=".git/hooks/pre-commit"
echo "Installing native pre-commit hook..."

cat <<HOOK_EOF > "\$PRE_COMMIT_HOOK"
#!/bin/bash
echo "Running pre-commit checks..."
npm run lint
LINT_EXIT=\\$?
npx tsc --noEmit
TYPE_EXIT=\\$?

if [ \\\$LINT_EXIT -ne 0 ] || [ \\\$TYPE_EXIT -ne 0 ]; then
  echo "❌ Pre-commit checks failed."
  exit 1
fi
echo "✅ Pre-commit checks passed."
HOOK_EOF

chmod +x "\$PRE_COMMIT_HOOK"
echo "✅ Native git hook installed successfully."
EOF

chmod +x "$INSTALL_HOOKS_SCRIPT"

# Add script to package.json
# Using node to safely modify JSON
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts = pkg.scripts || {};
pkg.scripts['githook:install'] = 'bash scripts/install-hooks.sh';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"

echo "Optional git hook installer created. Run 'npm run githook:install' to enable."
