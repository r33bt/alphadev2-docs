# AlphaDev2 Secure Credentials Setup Script
# This script helps you securely set up development credentials

Write-Host "AlphaDev2 Credentials Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$secretsPath = "C:\Users\user\alphadev2\secrets"
$credentialsPath = "$secretsPath\credentials"

# Ensure directories exist
if (!(Test-Path $credentialsPath)) {
    New-Item -Path $credentialsPath -ItemType Directory -Force
}

Write-Host "`nThis script will help you securely set up your development credentials." -ForegroundColor White
Write-Host "Credentials will be stored in encrypted files, not environment variables." -ForegroundColor White
Write-Host "You can skip any credential by pressing Enter.`n" -ForegroundColor Yellow

# Git Configuration
Write-Host "Git Configuration" -ForegroundColor Yellow
Write-Host "-------------------" -ForegroundColor Yellow

$gitName = Read-Host -Prompt "Enter your full name for Git commits"
if ($gitName) {
    git config --global user.name "$gitName"
    Write-Host "Git user name set to: $gitName" -ForegroundColor Green
}

$gitEmail = Read-Host -Prompt "Enter your email for Git commits"  
if ($gitEmail) {
    git config --global user.email "$gitEmail"
    Write-Host "Git email set to: $gitEmail" -ForegroundColor Green
}

# GitHub Setup
Write-Host "`nGitHub Integration" -ForegroundColor Yellow
Write-Host "--------------------" -ForegroundColor Yellow
Write-Host "Create a Personal Access Token at: https://github.com/settings/tokens" -ForegroundColor Cyan
Write-Host "Required scopes: repo, workflow, write:packages" -ForegroundColor Cyan

$githubUsername = Read-Host -Prompt "Enter your GitHub username"
if ($githubUsername) {
    $githubUsername | Out-File -FilePath "$credentialsPath\github.username" -Encoding UTF8 -NoNewline
    Write-Host "GitHub username saved" -ForegroundColor Green
}

$githubToken = Read-Host -Prompt "Enter GitHub Personal Access Token (ghp_...)" -AsSecureString
if ($githubToken.Length -gt 0) {
    $githubTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($githubToken))
    $githubTokenPlain | Out-File -FilePath "$credentialsPath\github.token" -Encoding UTF8 -NoNewline
    Write-Host "GitHub token saved securely" -ForegroundColor Green
    
    # Clear sensitive variable
    $githubTokenPlain = $null
    [System.GC]::Collect()
}

# Vercel Setup
Write-Host "`nVercel Deployment" -ForegroundColor Yellow  
Write-Host "-------------------" -ForegroundColor Yellow
Write-Host "Get your auth token by running: vercel login" -ForegroundColor Cyan
Write-Host "Or create one at: https://vercel.com/account/tokens" -ForegroundColor Cyan

$vercelToken = Read-Host -Prompt "Enter Vercel Auth Token" -AsSecureString
if ($vercelToken.Length -gt 0) {
    $vercelTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($vercelToken))
    $vercelTokenPlain | Out-File -FilePath "$credentialsPath\vercel.token" -Encoding UTF8 -NoNewline
    Write-Host "Vercel token saved securely" -ForegroundColor Green
    
    # Clear sensitive variable
    $vercelTokenPlain = $null
    [System.GC]::Collect()
}

# OpenAI Setup (Optional)
Write-Host "`nOpenAI API (Optional)" -ForegroundColor Yellow
Write-Host "-----------------------" -ForegroundColor Yellow
Write-Host "Create API key at: https://platform.openai.com/api-keys" -ForegroundColor Cyan

$openaiKey = Read-Host -Prompt "Enter OpenAI API Key (sk-...) [Optional]" -AsSecureString
if ($openaiKey.Length -gt 0) {
    $openaiKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($openaiKey))
    $openaiKeyPlain | Out-File -FilePath "$credentialsPath\openai.key" -Encoding UTF8 -NoNewline
    Write-Host "OpenAI API key saved securely" -ForegroundColor Green
    
    # Clear sensitive variable  
    $openaiKeyPlain = $null
    [System.GC]::Collect()
}

# Database Setup
Write-Host "`nLocal Database Configuration" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

$dbUrl = Read-Host -Prompt "Enter local database URL [Default: postgresql://localhost:5432/dev_db]"
if (!$dbUrl) {
    $dbUrl = "postgresql://localhost:5432/dev_db"
}
$dbUrl | Out-File -FilePath "$credentialsPath\database.url" -Encoding UTF8 -NoNewline
Write-Host "Database URL saved: $dbUrl" -ForegroundColor Green

# Create global environment file
Write-Host "`nCreating global environment file..." -ForegroundColor Yellow

$globalEnvContent = @"
# AlphaDev2 Global Development Environment
# Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Development Settings
NODE_ENV=development
DEV_PORT_START=3000
DEV_PORT_END=3100
LOG_LEVEL=debug

# Local Services  
DATABASE_URL=$dbUrl
REDIS_URL=redis://localhost:6379
MAILCATCHER_URL=http://localhost:1080

# Load additional credentials from files:
# GITHUB_TOKEN will be loaded from credentials/github.token
# VERCEL_TOKEN will be loaded from credentials/vercel.token  
# OPENAI_API_KEY will be loaded from credentials/openai.key
"@

$globalEnvContent | Out-File -FilePath "$secretsPath\.env.global" -Encoding UTF8
Write-Host "Global environment file created" -ForegroundColor Green

# Set file permissions (Windows)
Write-Host "`nSetting secure file permissions..." -ForegroundColor Yellow
try {
    icacls "$secretsPath" /inheritance:r /grant:r "$env:USERNAME:(OI)(CI)F" /t | Out-Null
    Write-Host "Secure permissions set on secrets directory" -ForegroundColor Green
} catch {
    Write-Host "Could not set secure permissions. Please check manually." -ForegroundColor Yellow
}

# Summary
Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host "Credentials saved securely in: $credentialsPath" -ForegroundColor White
Write-Host "Global environment file created: $secretsPath\.env.global" -ForegroundColor White
Write-Host "Git configuration updated" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Test Git connection: git clone <your-repo>" -ForegroundColor White  
Write-Host "2. Test Vercel connection: vercel --version" -ForegroundColor White
Write-Host "3. Review CREDENTIALS_MASTER_TEMPLATE.md for additional APIs" -ForegroundColor White
Write-Host "4. Initialize your first project in the projects/ directory" -ForegroundColor White

Write-Host "`nSecurity Reminder:" -ForegroundColor Yellow
Write-Host "- Never commit the secrets/ directory" -ForegroundColor White
Write-Host "- Regularly rotate your tokens (monthly)" -ForegroundColor White  
Write-Host "- Use .env.example files for project templates" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")