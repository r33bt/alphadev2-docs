# AlphaDev2 Quick Setup Guide

**Purpose:** Set up complete development environment on any new computer  
**Time Required:** 30-45 minutes  
**Date:** 2025-01-11

## 🎯 **Use Cases**

- **New Computer Setup** - Fresh installation on a new machine
- **Disaster Recovery** - C: drive crashed, recovering from old drive
- **Team Onboarding** - Setting up AlphaDev2 for a new team member
- **Clean Installation** - Starting fresh on existing computer

## 📋 **Prerequisites**

- ✅ Windows 10/11 with administrator privileges
- ✅ Internet connection
- ✅ Access to your AlphaDev2 backup/old drive (for recovery scenarios)
- ✅ Your credentials ready (for fresh installations)

## 🚀 **30-Minute Setup Process**

### **Step 1: Copy or Create AlphaDev2 Directory** (5-10 minutes)

#### **Option A: Recovery from Old Drive**
```powershell
# If old drive is mounted as D:, E:, etc.
robocopy "D:\Users\user\alphadev2" "C:\Users\user\alphadev2" /E /COPYALL /R:3 /W:10

# Verify copy completed
Write-Host "AlphaDev2 directory copied successfully!" -ForegroundColor Green
Get-ChildItem "C:\Users\user\alphadev2" -Directory | Select-Object Name
```

#### **Option B: Fresh Installation from Backup**
```powershell
# Extract from backup archive or copy from network location
# Ensure the complete directory structure is restored
```

#### **Option C: Brand New Setup**
```powershell
# Create basic directory structure
$alphaDev = "C:\Users\user\alphadev2"
$dirs = @(
    "projects\web", "projects\mobile", "projects\desktop", "projects\scripts",
    "tools\utilities", "tools\portable-apps", 
    "cache\general", "cache\chocolatey",
    "secrets\credentials", "secrets\templates",
    "config\backups", "resources\tutorials", "resources\documentation",
    "sandbox", "installers", "scripts"
)

foreach ($dir in $dirs) {
    New-Item -Path "$alphaDev\$dir" -ItemType Directory -Force
}

# Download setup scripts from GitHub or create manually
# (You'll need the credential setup scripts)
```

### **Step 2: Install Essential Applications** (10-15 minutes)

#### **Required Applications**
```powershell
# Method 1: Using Chocolatey (Recommended)
# Install Chocolatey first if not present:
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install essential tools
choco install nodejs git gh -y

# Method 2: Manual Downloads (if Chocolatey not available)
# Download and install:
# - Node.js: https://nodejs.org/ (includes npm)
# - Git: https://git-scm.com/downloads
# - GitHub CLI: https://cli.github.com/
```

#### **Verify Installations**
```powershell
# Check all tools are installed correctly
Write-Host "Checking installed tools..." -ForegroundColor Yellow

node --version     # Should show v22.x.x or similar
npm --version      # Should show 10.x.x or similar  
git --version      # Should show git version 2.x.x
gh --version       # Should show gh version 2.x.x

Write-Host "✅ All essential tools installed!" -ForegroundColor Green
```

### **Step 3: Install CLI Tools** (2-3 minutes)

```powershell
# Navigate to AlphaDev2 directory
cd "C:\Users\user\alphadev2"

# Install Vercel CLI globally
npm install -g vercel

# Verify installation
vercel --version   # Should show Vercel CLI version

# Optional: Install Supabase CLI
# Download from: https://github.com/supabase/cli/releases
# Or use: scoop install supabase (requires Scoop)

Write-Host "✅ CLI tools installed!" -ForegroundColor Green
```

### **Step 4: Set Up Credentials** (5-10 minutes)

#### **Option A: Use Existing Credentials (Recovery Scenario)**
```powershell
# Credentials should already be copied with the directory
# Verify they exist
$credPath = "C:\Users\user\alphadev2\secrets\credentials"
Get-ChildItem $credPath -File | ForEach-Object {
    Write-Host "✅ $($_.Name)" -ForegroundColor Green
}
```

#### **Option B: Fresh Credential Setup**
```powershell
# Run the credential setup script
powershell -ExecutionPolicy Bypass -File "scripts\setup-credentials.ps1"

# This will prompt for:
# - Your full name (for Git)
# - Your email (for Git)  
# - GitHub Personal Access Token
# - Vercel Auth Token
# - Database settings
```

#### **Option C: Manual Credential Setup**
```powershell
# Create credential files manually if needed
$credPath = "C:\Users\user\alphadev2\secrets\credentials"

# Example - replace with your actual tokens
"your_github_token_here" | Out-File "$credPath\github.token" -Encoding UTF8 -NoNewline
"your_vercel_token_here" | Out-File "$credPath\vercel.token" -Encoding UTF8 -NoNewline
"your_username" | Out-File "$credPath\github.username" -Encoding UTF8 -NoNewline
```

### **Step 5: Authenticate All CLIs** (5 minutes)

```powershell
# Run the authentication script
powershell -ExecutionPolicy Bypass -File "scripts\setup-cli-auth.ps1"

# This will automatically:
# ✅ Configure Git with your name and email
# ✅ Authenticate GitHub CLI using your token
# ✅ Test Vercel CLI authentication
# ✅ Verify all connections work
```

#### **Manual Authentication (if script doesn't exist)**
```powershell
# Git configuration
git config --global user.name "Your Full Name"
git config --global user.email "your.email@domain.com"

# GitHub CLI authentication
$githubToken = Get-Content "C:\Users\user\alphadev2\secrets\credentials\github.token"
echo $githubToken | gh auth login --with-token

# Test authentications
gh auth status
git config --list | findstr user
```

### **Step 6: Test Complete Workflow** (5-10 minutes)

```powershell
# Run the workflow test to verify everything works
powershell -ExecutionPolicy Bypass -File "scripts\test-workflow.ps1"

# This will:
# 1. Create a test Next.js project
# 2. Initialize Git repository  
# 3. Create GitHub repository
# 4. Push code to GitHub
# 5. Deploy to Vercel
# 6. Verify the complete pipeline works
```

## 📊 **Setup Verification Checklist**

### **File Structure Check**
```powershell
# Verify complete directory structure
$alphaDev = "C:\Users\user\alphadev2"
$requiredDirs = @("projects", "secrets", "scripts", "tools", "resources", "config")

foreach ($dir in $requiredDirs) {
    if (Test-Path "$alphaDev\$dir") {
        Write-Host "✅ $dir" -ForegroundColor Green
    } else {
        Write-Host "❌ $dir - Missing!" -ForegroundColor Red
    }
}
```

### **Applications Check**
```powershell
# Verify all required applications are installed
$tools = @(
    @{Name="Node.js"; Command="node --version"},
    @{Name="npm"; Command="npm --version"},
    @{Name="Git"; Command="git --version"},
    @{Name="GitHub CLI"; Command="gh --version"},
    @{Name="Vercel CLI"; Command="vercel --version"}
)

foreach ($tool in $tools) {
    try {
        $version = Invoke-Expression $tool.Command
        Write-Host "✅ $($tool.Name): $version" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ $($tool.Name): Not installed or not working" -ForegroundColor Red
    }
}
```

### **Authentication Check**
```powershell
# Verify all CLIs are authenticated
Write-Host "Checking authentication status..." -ForegroundColor Yellow

# Git config
$gitName = git config --global user.name
$gitEmail = git config --global user.email
if ($gitName -and $gitEmail) {
    Write-Host "✅ Git: $gitName <$gitEmail>" -ForegroundColor Green
} else {
    Write-Host "❌ Git: Not configured" -ForegroundColor Red
}

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
$vercelToken = Get-Content "C:\Users\user\alphadev2\secrets\credentials\vercel.token" -ErrorAction SilentlyContinue
if ($vercelToken) {
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
} else {
    Write-Host "❌ Vercel: Token not found" -ForegroundColor Red
}
```

## 🛠️ **Troubleshooting Common Issues**

### **Issue: CLI Not Found After Installation**
```powershell
# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Or restart PowerShell/Command Prompt
```

### **Issue: Permission Denied Errors**
```powershell
# Set execution policy for PowerShell scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### **Issue: GitHub Authentication Failed**
```powershell
# Clear existing auth and try again
gh auth logout
echo "your_github_token" | gh auth login --with-token
gh auth status
```

### **Issue: Vercel Deployment Not Working**
```powershell
# Run the fix script we created
powershell -ExecutionPolicy Bypass -File "scripts\fix-vercel-deployment.ps1"
```

### **Issue: Git Push Authentication Failed**
```powershell
# Check git credentials configuration
git config --list | findstr credential

# May need to update credential helper
git config --global credential.helper manager
```

## 📦 **Complete Setup Script**

Create this as `scripts/complete-setup.ps1`:

```powershell
# AlphaDev2 Complete Setup Script
param(
    [string]$SourceDrive = "",  # e.g., "D" for recovery scenarios
    [switch]$FreshInstall = $false
)

Write-Host "🚀 AlphaDev2 Complete Setup Starting..." -ForegroundColor Cyan

if ($SourceDrive) {
    Write-Host "Recovery mode: Copying from ${SourceDrive}:" -ForegroundColor Yellow
    robocopy "${SourceDrive}:\Users\user\alphadev2" "C:\Users\user\alphadev2" /E /COPYALL
} elseif (-not $FreshInstall) {
    Write-Host "Error: Specify -SourceDrive or use -FreshInstall" -ForegroundColor Red
    exit 1
}

# Install applications (skip if already installed)
Write-Host "Installing essential applications..." -ForegroundColor Yellow
try {
    choco install nodejs git gh -y
} catch {
    Write-Host "Chocolatey not available. Please install applications manually." -ForegroundColor Yellow
}

# Install CLI tools
cd "C:\Users\user\alphadev2"
npm install -g vercel

# Set up credentials (if fresh install)
if ($FreshInstall) {
    Write-Host "Setting up credentials..." -ForegroundColor Yellow
    powershell -ExecutionPolicy Bypass -File "scripts\setup-credentials.ps1"
}

# Authenticate CLIs
Write-Host "Authenticating CLIs..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts\setup-cli-auth.ps1"

# Test complete workflow
Write-Host "Testing complete workflow..." -ForegroundColor Yellow
powershell -ExecutionPolicy Bypass -File "scripts\test-workflow.ps1"

Write-Host "🎉 AlphaDev2 setup complete!" -ForegroundColor Green
```

**Usage:**
```powershell
# For disaster recovery (old drive as D:)
powershell -ExecutionPolicy Bypass -File "scripts\complete-setup.ps1" -SourceDrive "D"

# For fresh installation
powershell -ExecutionPolicy Bypass -File "scripts\complete-setup.ps1" -FreshInstall
```

## 📋 **What You Get After Setup**

### **Complete Development Capabilities**
- ✅ **Local development** with Node.js, npm, Git
- ✅ **GitHub integration** via CLI (repos, PRs, issues)
- ✅ **Vercel deployment** via CLI (preview + production)
- ✅ **Supabase database** integration (if configured)
- ✅ **Secure credential management** system
- ✅ **Automated workflows** and scripts

### **One-Command Operations**
- ✅ Create GitHub repository: `gh repo create`
- ✅ Deploy to Vercel: `vercel --prod --token token`
- ✅ Complete pipeline test: `scripts\test-workflow.ps1`
- ✅ CLI authentication: `scripts\setup-cli-auth.ps1`

### **Organized Environment**
- ✅ All projects in structured directories
- ✅ All credentials securely stored
- ✅ All documentation and guides included
- ✅ All automation scripts ready to use

## 🎯 **Success Criteria**

Your setup is complete when:

1. **✅ Directory structure** exists and is organized
2. **✅ All CLI tools** installed and authenticated  
3. **✅ Workflow test** runs successfully and creates:
   - GitHub repository
   - Vercel deployment
   - Working website
4. **✅ One-command deployment** pipeline operational

## ⏱️ **Time Breakdown**

- **Copy/Setup Directory**: 5-10 minutes
- **Install Applications**: 10-15 minutes  
- **Install CLI Tools**: 2-3 minutes
- **Configure Credentials**: 5-10 minutes
- **Test Workflow**: 5-10 minutes
- **Total**: 30-45 minutes

## 💡 **Pro Tips**

### **For Future Setups**
- Keep a current backup of your `alphadev2` directory
- Document any custom configurations you add
- Export browser bookmarks and IDE settings separately
- Keep a list of additional applications you install

### **For Team Onboarding**
- Create a shared backup with template credentials
- Document team-specific settings and workflows
- Include team coding standards and practices
- Add team-specific automation scripts

---

## 🏁 **You're Ready!**

After following this guide, you have a **complete, professional development environment** that can:

- **Deploy from code to live website** in minutes
- **Create and manage repositories** from command line
- **Handle databases, authentication, and storage** seamlessly
- **Work identically on any computer** you set it up on

**Status**: 🚀 **Complete Development Environment Ready**

**Quick Start**: Run `scripts\test-workflow.ps1` to deploy your first site!

**Last Updated:** 2025-01-11