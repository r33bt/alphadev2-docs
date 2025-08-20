# AI Assistant Instructions (genspark-rules.md)

## Project Context
This is a Next.js project using Vercel deployment and Supabase backend, developed on Windows PC.

## Development Environment
- **Stack**: Next.js + Vercel + Supabase
- **OS**: Windows PC
- **Terminal**: PowerShell
- **Version Control**: Git → GitHub → Vercel auto-deploy
- **AI Workflow**: GenSpark AI generates PowerShell commands for copy-paste execution

## Code Generation Guidelines
- Always generate PowerShell commands for Windows environment
- Provide complete, copy-pasteable command blocks
- Include error handling and validation where appropriate
- Use relative paths from project root
- Consider existing file structure and dependencies

## Project Priorities
1. Maintain development momentum
2. Ensure Vercel deployment compatibility  
3. Follow Next.js best practices
4. Integrate properly with Supabase
5. Generate Windows-compatible scripts

## Communication Style
- Provide working code first, explanations second
- Use PowerShell syntax for all terminal commands
- Include file path context in responses
- Assume familiarity with the tech stack

## Context Recovery
When conversation starts, always check for:
1. .ai-context/project-state.md for current project status
2. .ai-context/recent-decisions.md for latest development choices
3. package.json for dependencies and scripts
4. Current git branch and recent commits
