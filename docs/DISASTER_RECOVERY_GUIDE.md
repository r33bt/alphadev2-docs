# AlphaDev2 Disaster Recovery Guide

**Created:** 2025-01-11  
**Scenario:** C: Drive Crash - Recovering AlphaDev2 Environment  
**Status:** Complete Recovery Procedures

## 🚨 **Disaster Scenario**

Your C: drive has crashed and you've installed fresh Windows on a new C: drive. You have access to your old C: drive mounted as another drive (e.g., D: or E:). This guide will help you restore your complete AlphaDev2 development environment.

## 📋 **Recovery Priority Order**

### **Phase 1: Critical Data (Do This First)**
1. **AlphaDev2 Directory** - Your entire development environment
2. **Credentials** - Secure authentication tokens
3. **SSH Keys** - If you had any custom ones
4. **Project Files** - Any work in progress

### **Phase 2: System Configurations** 
5. **Git Global Config** - User settings
6. **Environment Variables** - If any were set
7. **CLI Configurations** - Tool-specific settings

### **Phase 3: Applications**
8. **Development Tools** - VS Code, IDEs, etc.
9. **CLI Tools** - If not globally installed

## 🔧 **Step-by-Step Recovery Process**

### **Step 1: Copy AlphaDev2 Directory**

```powershell
# Assuming old drive is mounted as D:
# Copy entire AlphaDev2 directory
robocopy "D:\Users\user\alphadev2" "C:\Users\user\alphadev2" /E /COPYALL /R:3 /W:10

# Verify copy completed
Get-ChildItem "C:\Users\user\alphadev2" -Recurse | Measure-Object | Select-Object Count
```

**What This Recovers:**
- ✅ All project files and directory structure
- ✅ Secure credential files (`secrets/credentials/`)
- ✅ Configuration templates
- ✅ Documentation and guides
- ✅ PowerShell scripts for automation

### **Step 2: Verify Credentials Integrity**

```powershell
# Check that all credential files are intact
$credentialsPath = "C:\Users\user\alphadev2\secrets\credentials"

Write-Host "Checking credential files:" -ForegroundColor Yellow
Get-ChildItem $credentialsPath -File | ForEach-Object {
    $size = $_.Length
    if ($size -gt 0) {
        Write-Host "✅ $($_.Name) - $size bytes" -ForegroundColor Green
    } else {
        Write-Host "❌ $($_.Name) - Empty file!" -ForegroundColor Red
    }
}
```

### **Step 3: Copy Critical Windows Configurations**

```powershell
# Copy SSH keys if they exist
if (Test-Path "D:\Users\user\.ssh") {
    robocopy "D:\Users\user\.ssh" "C:\Users\user\.ssh" /E /COPYALL
    Write-Host "✅ SSH keys copied" -ForegroundColor Green
}

# Copy Git global configuration
if (Test-Path "D:\Users\user\.gitconfig") {
    Copy-Item "D:\Users\user\.gitconfig" "C:\Users\user\.gitconfig"
    Write-Host "✅ Git config copied" -ForegroundColor Green
}
```

### **Step 4: Install Required Applications**

#### **Essential Applications (Required)**
```powershell
# Install Node.js (includes npm)
# Download from: https://nodejs.org/
# Or use chocolatey:
choco install nodejs

# Install Git (if not already present)
choco install git

# Install GitHub CLI
choco install gh

# Verify installations
node --version
npm --version
git --version
gh --version
```

#### **Development IDEs (Optional)**
```powershell
# Install VS Code
choco install vscode

# Install Cursor (if you were using it)
# Download from: https://cursor.sh/
```

### **Step 5: Reinstall CLI Tools**

```powershell
# Navigate to AlphaDev2
cd "C:\Users\user\alphadev2"

# Install Vercel CLI
npm install -g vercel

# Verify installation
vercel --version

# Supabase CLI (manual installation)
# Download from: https://github.com/supabase/cli/releases
# Or use: scoop install supabase (requires Scoop)
```

### **Step 6: Re-authenticate All CLIs**

```powershell
# Run the authentication script we created
powershell -ExecutionPolicy Bypass -File "scripts\setup-cli-auth.ps1"

# This will automatically:
# - Authenticate GitHub CLI using stored token
# - Authenticate Vercel CLI using stored token
# - Configure Git with your name/email
```

### **Step 7: Verify Complete Recovery**

```powershell
# Test that everything is working
powershell -ExecutionPolicy Bypass -File "scripts\test-workflow.ps1"

# This will test the complete Git → GitHub → Vercel pipeline
```

## 📂 **What You DON'T Need to Recover**

### **Already Handled by AlphaDev2 Copy:**
- ✅ All your projects and code
- ✅ Credential files and tokens  
- ✅ Environment templates
- ✅ Custom scripts and automation
- ✅ Documentation and guides
- ✅ Directory structure and organization

### **Stored in Cloud (Auto-Recovered):**
- ✅ GitHub repositories (in the cloud)
- ✅ Vercel deployments (in the cloud)
- ✅ Supabase databases (in the cloud)

### **Will Be Recreated:**
- ✅ Node modules (`npm install` in each project)
- ✅ Build outputs (generated as needed)
- ✅ Cache files (recreated automatically)

## 🔍 **Recovery Verification Checklist**

### **File Structure Check**
```powershell
# Verify directory structure is intact
Get-ChildItem "C:\Users\user\alphadev2" -Directory | ForEach-Object {
    Write-Host "📁 $($_.Name)" -ForegroundColor Cyan
}

# Should show:
# 📁 cache
# 📁 config  
# 📁 installers
# 📁 projects
# 📁 resources
# 📁 sandbox
# 📁 scripts
# 📁 secrets
# 📁 tools
```

### **Credentials Check**
```powershell
# Verify all credentials are accessible
$secretsPath = "C:\Users\user\alphadev2\secrets\credentials"

$expectedCredentials = @(
    "github.token",
    "github.username", 
    "vercel.token",
    "supabase.url",
    "supabase.anon.key",
    "supabase.service.key",
    "supabase.access.token"
)

foreach ($cred in $expectedCredentials) {
    $credPath = Join-Path $secretsPath $cred
    if (Test-Path $credPath) {
        Write-Host "✅ $cred" -ForegroundColor Green
    } else {
        Write-Host "❌ $cred - Missing!" -ForegroundColor Red
    }
}
```

### **CLI Authentication Check**
```powershell
# Verify all CLIs are authenticated
Write-Host "Checking CLI authentication:" -ForegroundColor Yellow

# Git
$gitName = git config --global user.name
$gitEmail = git config --global user.email
Write-Host "Git: $gitName <$gitEmail>" -ForegroundColor $(if ($gitName -and $gitEmail) { "Green" } else { "Red" })

# GitHub CLI
try {
    $ghStatus = gh auth status 2>&1
    if ($ghStatus -like "*Logged in*") {
        Write-Host "✅ GitHub CLI: Authenticated" -ForegroundColor Green
    } else {
        Write-Host "❌ GitHub CLI: Not authenticated" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ GitHub CLI: Error checking status" -ForegroundColor Red
}

# Vercel CLI
$vercelToken = Get-Content "C:\Users\user\alphadev2\secrets\credentials\vercel.token" -Raw
try {
    $vercelUser = vercel whoami --token $vercelToken.Trim() 2>&1
    if ($vercelUser -and $vercelUser -notlike "*Error*") {
        Write-Host "✅ Vercel CLI: Authenticated as $vercelUser" -ForegroundColor Green
    } else {
        Write-Host "❌ Vercel CLI: Not authenticated" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Vercel CLI: Error checking status" -ForegroundColor Red
}
```

## 🚀 **Quick Recovery Script**

Create this script for future disasters:

```powershell
# File: scripts/disaster-recovery.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$OldDriveLetter
)

Write-Host "🚨 AlphaDev2 Disaster Recovery Starting..." -ForegroundColor Red
Write-Host "Old drive: ${OldDriveLetter}:" -ForegroundColor Yellow
Write-Host "New drive: C:" -ForegroundColor Green

# Step 1: Copy AlphaDev2
Write-Host "`n1. Copying AlphaDev2 directory..." -ForegroundColor Cyan
robocopy "${OldDriveLetter}:\Users\user\alphadev2" "C:\Users\user\alphadev2" /E /COPYALL /R:3 /W:10

# Step 2: Copy critical configs
Write-Host "`n2. Copying critical configurations..." -ForegroundColor Cyan
if (Test-Path "${OldDriveLetter}:\Users\user\.ssh") {
    robocopy "${OldDriveLetter}:\Users\user\.ssh" "C:\Users\user\.ssh" /E /COPYALL
}
if (Test-Path "${OldDriveLetter}:\Users\user\.gitconfig") {
    Copy-Item "${OldDriveLetter}:\Users\user\.gitconfig" "C:\Users\user\.gitconfig"
}

# Step 3: Install CLIs
Write-Host "`n3. Installing CLI tools..." -ForegroundColor Cyan
npm install -g vercel

# Step 4: Re-authenticate
Write-Host "`n4. Re-authenticating CLIs..." -ForegroundColor Cyan
cd "C:\Users\user\alphadev2"
powershell -ExecutionPolicy Bypass -File "scripts\setup-cli-auth.ps1"

# Step 5: Verify
Write-Host "`n5. Testing complete workflow..." -ForegroundColor Cyan
powershell -ExecutionPolicy Bypass -File "scripts\test-workflow.ps1"

Write-Host "`n🎉 Recovery complete!" -ForegroundColor Green
```

**Usage:**
```powershell
# If old drive is mounted as D:
powershell -ExecutionPolicy Bypass -File "scripts\disaster-recovery.ps1" -OldDriveLetter "D"
```

## 💾 **Backup Strategy for Future**

### **What to Backup Regularly:**
1. **Entire AlphaDev2 directory** - Contains everything important
2. **Git global config** (`C:\Users\user\.gitconfig`)
3. **SSH keys** (`C:\Users\user\.ssh\`) - if any

### **Automated Backup Script:**
```powershell
# File: scripts/backup-alphadev2.ps1
$BackupPath = "E:\Backups\AlphaDev2-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Create backup directory
New-Item -Path $BackupPath -ItemType Directory -Force

# Backup AlphaDev2
robocopy "C:\Users\user\alphadev2" "$BackupPath\alphadev2" /E /COPYALL

# Backup Git config
Copy-Item "C:\Users\user\.gitconfig" "$BackupPath\.gitconfig" -ErrorAction SilentlyContinue

# Backup SSH keys
if (Test-Path "C:\Users\user\.ssh") {
    robocopy "C:\Users\user\.ssh" "$BackupPath\.ssh" /E /COPYALL
}

Write-Host "✅ Backup completed: $BackupPath" -ForegroundColor Green
```

## 📋 **Recovery Time Estimate**

### **Fastest Recovery (30-45 minutes):**
- Copy AlphaDev2 directory: ~5-10 minutes
- Install Node.js, Git, GitHub CLI: ~10-15 minutes
- Install Vercel CLI: ~2-3 minutes
- Re-authenticate CLIs: ~5 minutes
- Test workflow: ~5-10 minutes

### **Full Recovery with Applications (1-2 hours):**
- Add time for VS Code, Cursor, other IDEs
- Add time for project-specific dependencies

## 🎯 **Key Recovery Principles**

### **What Makes This Easy:**
✅ **Self-contained environment** - Everything in one directory  
✅ **Secure credential storage** - No need to re-enter tokens  
✅ **Automated scripts** - Re-authentication is scripted  
✅ **Cloud-based services** - GitHub/Vercel projects still exist  
✅ **Documentation** - Complete guides are preserved  

### **What You'll Need:**
- ✅ Access to old drive (mounted as secondary drive)
- ✅ Fresh Windows installation with internet
- ✅ Administrator privileges for installations
- ✅ ~1-2 hours for complete recovery

## 🔒 **Security Considerations**

### **Credential Security:**
- ✅ Credentials are stored in encrypted files
- ✅ No plain text passwords in recoverable data
- ✅ Tokens can be revoked if compromised
- ✅ SSH keys are copied securely

### **After Recovery:**
- Consider rotating tokens if drive was compromised
- Verify all authentication works before proceeding
- Test a simple deployment to confirm everything works

---

## 🏁 **Summary**

Your AlphaDev2 environment is designed for **easy disaster recovery**. The entire development environment, including credentials, configurations, and automation scripts, lives in one directory that can be copied intact.

**Recovery is mostly just copying files and reinstalling a few applications** - all your configurations, credentials, and workflows are preserved.

**Key Files to Prioritize:**
1. `C:\Users\user\alphadev2\` (entire directory)
2. `C:\Users\user\.gitconfig` (Git settings)  
3. `C:\Users\user\.ssh\` (SSH keys, if any)

**Total Recovery Time: 30-45 minutes for basic setup, 1-2 hours for full environment.**

**Status**: 🛡️ **Disaster Recovery Plan Complete**

**Last Updated:** 2025-01-11