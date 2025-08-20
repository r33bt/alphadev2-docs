# Clear and recreate claude.md with correct content
@'
# Claude AI - AlphaDev2 Project Context

## 🎯 **IMMEDIATE CONTEXT SETTING**

Copy and paste this at the start of any Claude conversation for optimal assistance:

---

**DEVELOPMENT ENVIRONMENT**: AlphaDev2 - Professional WordPress to Next.js migration workflow

**CURRENT SETUP**:
- **Location**: `C:\Users\user\alphadev2\` (Windows development environment)
- **Tech Stack**: WordPress → Next.js 14 + TypeScript + Tailwind + Supabase + Vercel
- **Git Workflow**: Feature branches → GitHub → Vercel auto-deployment
- **CLI Tools**: Fully automated (Git, GitHub CLI, Vercel CLI, Node.js)

**CREDENTIALS AVAILABLE** (secure file locations):
- SSH access to 4 servers with 76+ WordPress sites
- GitHub, Vercel, Supabase, Resend, Cloudflare API tokens
- Complete credential management system documented

**DOCUMENTATION LIBRARY**: 
Comprehensive guides available for setup, migration, branching, disaster recovery, and multi-computer workflows.

**CURRENT PROJECT FOCUS**: 
Automating WordPress → Next.js headless migrations for 40+ domains to reduce costs from $2,300 to ~$200 (91% savings).

**REQUEST**: Please help with [SPECIFIC_TASK] while respecting our established workflow, credential security, and existing documentation patterns.

---

## 📋 **STANDARD PROJECT PROMPTS**

### **New Project Initialization**
I need to create a new Next.js project for [DOMAIN_NAME].

Context: This is part of our WordPress → Next.js migration workflow. The project should:

Follow our established AlphaDev2 patterns
Include Supabase integration for database/auth
Set up Resend.com for contact forms
Configure Cloudflare Turnstile for spam protection
Use our standard deployment pipeline (GitHub → Vercel)
Include proper TypeScript and Tailwind setup
Please guide me through the setup process using our existing templates and workflow.


### **WordPress Migration Assistance**
I need to migrate [WORDPRESS_SITE] to Next.js headless architecture.

Context:

WordPress site is on our GridPane servers (SSH access available)
Site database available at: staging.[DOMAIN]
Target: Next.js 14 with WordPress as headless CMS
Must maintain SEO, content structure, and contact forms
Should follow our migration template from stocktiming-headless project
Please help with the migration process following our documented workflow.


## 🔧 **TROUBLESHOOTING PROMPTS**

### **Environment Issues**
My development environment has [SPECIFIC_PROBLEM].

Context: AlphaDev2 setup with full CLI automation

Windows 10/11 development machine
All tools previously working (Git, GitHub CLI, Vercel CLI, Node.js)
Complete documentation available for disaster recovery
Credential files intact at documented locations
Please help diagnose and resolve this issue.


## 📝 **EFFICIENCY REMINDERS**

**When Working with Claude**:
1. **Always provide this context** at conversation start
2. **Reference existing documentation** rather than recreating
3. **Specify exact file paths** when discussing configurations
4. **Request PowerShell commands** for Windows operations
5. **Ask for batch solutions** when handling multiple domains

**Always Request**:
- ✅ Solutions that integrate with existing workflow
- ✅ PowerShell commands for Windows environment
- ✅ Batch processing approaches for multiple sites
- ✅ Reference to existing documentation/templates
- ✅ Security-conscious implementations

---

**💡 TIP**: Keep this file updated as your workflow evolves and new patterns emerge.
'@ | Out-File -FilePath "claude.md" -Encoding UTF8