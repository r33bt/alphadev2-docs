# AlphaDev2 Development Workspace
*Last Updated: 2025-08-13 | Platform: Windows 11*

Multi-project development workspace with automation tools, data extraction scripts, and web applications.

## 🎯 CURRENT PRIORITY: IGCSE Quiz App (Production Ready)
**Next Focus**: Migration system automation for client projects

## Key Projects
- **igcse-quiz-app/**: Next.js + Supabase quiz app (Production: https://igcse-quiz-app.vercel.app)
- **migration/**: Headless WordPress migration system (Production-ready automation)
- **PlaywrightTesting/**: E2E testing framework setup
- **getyoutubechannel/**: YouTube data extraction for CRM analysis  
- **eluxury/**: Property data parsing scripts
- **ffmpeg/**: Video processing automation

## 🚨 CRITICAL: Systematic Operations Protocol

**ALWAYS VALIDATE FIRST** - Stop wasting time and money on trial-and-error:

### 1. Pre-Operation Validation (Windows Commands)
```powershell
# Verify essential files exist before proceeding
Test-Path "C:\Users\user\.ssh\gridpane_rsa"          # SSH key
Test-Path "devops\secrets\credentials\vercel.token"    # Vercel token  
Test-Path "devops\secrets\credentials\github.token"    # GitHub token
Test-Path "SSH\QUICK_REFERENCE.md"                     # Server details
```

### 2. Credentials & Authentication (Single Source of Truth)
- **🗂️ All API keys/tokens**: `devops/secrets/credentials/` directory
- **🔑 SSH Key**: `C:\Users\user\.ssh\gridpane_rsa` (✅ Verified: Exists)
- **🌐 Server IP**: `162.243.15.7` (GridPane - see SSH/QUICK_REFERENCE.md)
- **⚡ Vercel token**: `devops/secrets/credentials/vercel.token` (✅ Verified: Exists)
- **📦 GitHub token**: `devops/secrets/credentials/github.token` 
- **🗄️ Supabase credentials**: `devops/secrets/credentials/supabase.*`

### 3. Operation Decision Tree
**For API/Server Operations:**
- 🔍 **Need server access?** → Use SSH connection (see #4)
- 🚀 **Deploying to Vercel?** → Use PowerShell Vercel command (see #4)  
- 🔧 **WordPress work?** → Reference SSH/wp-cli-commands.ps1
- 🧪 **Testing APIs?** → Use SSH/rest-api-test-fixed.ps1
- 📁 **Migration project?** → See migration/CLAUDE.md

### 4. Platform-Specific Commands (Windows)
```powershell
# SSH Connection (Git Bash or WSL)
ssh -i "C:/Users/user/.ssh/gridpane_rsa" root@162.243.15.7

# Vercel Deployment (PowerShell)
$token = Get-Content "devops\secrets\credentials\vercel.token" -Raw
vercel --prod --yes --token $token.Trim()

# File Validation (PowerShell)
if (Test-Path "devops\secrets\credentials\vercel.token") { 
    "✅ Ready for deployment" 
} else { 
    "❌ Missing credentials - check devops/secrets/credentials/" 
}
```

## 📋 Essential Commands (By Frequency of Use)

### Daily Operations
```powershell
# IGCSE App (Most Used)
cd igcse-quiz-app; npm run dev                    # Local development
git add .; git commit -m "message"; git push      # Auto-deploys to production

# Testing
npx playwright test                               # E2E tests
npx playwright show-report                        # View results
```

### Weekly Operations  
```powershell
# Python Projects
pip install -r requirements.txt; python app.py   # Run data extraction

# System Verification
.\test-mcp-setup.bat                            # MCP server check
```

### Project-Specific (As Needed)
```powershell
# Migration Projects - See migration/CLAUDE.md
# Vercel Manual Deploy - Use validated PowerShell commands above
```

## Current Environment
- **Supabase**: https://nkcjwrksvmjzqsatwkac.supabase.co
- **GitHub**: https://github.com/r33bt/igcse-quiz-app
- **Database**: Quiz system with session tracking and user progress

## Code Standards
- TypeScript required for new components
- Explicit return types for all functions
- Follow existing project patterns and conventions

## 📊 Current Project Status & Next Actions

### Active Projects
- **🎯 IGCSE Quiz App**: ✅ Production ready with full quiz history system
- **🔧 Migration System**: ✅ Automation complete, ready for client projects
- **📊 Database**: ✅ All schema migrations complete
- **🧪 Testing**: ✅ Comprehensive error handling implemented

### Immediate Next Steps (Priority Order)
1. **Migration projects**: Use proven automation for client conversions
2. **IGCSE expansion**: Add more subjects/questions as requested
3. **Data extraction**: YouTube/property parsing as needed

### 🚨 When Things Go Wrong
- **File not found errors**: Run validation commands from section #1
- **Command failures**: Check platform-specific commands (PowerShell vs bash)
- **API failures**: Verify credentials exist and are current
- **SSH timeouts**: Confirm using correct IP (162.243.15.7) not old addresses

---
*Detailed session history archived in legacy/_alphadev/CLAUDE.md*