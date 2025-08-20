# Standard .gitignore for Headless WordPress Projects

```gitignore
# Dependencies
node_modules
/.pnp
.pnp.js

# Testing
/coverage

# Next.js
/.next/
/out/

# Production
/build
.vercel

# Local env files
.env*.local
.env.production

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDEs
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# WordPress credentials (keep secure)
.env.production
```