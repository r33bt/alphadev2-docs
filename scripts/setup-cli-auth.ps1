# AlphaDev2 CLI Authentication Setup
# This script authenticates all development CLIs using stored credentials

Write-Host "CLI Authentication Setup" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

$secretsPath = "C:\Users\user\alphadev2\secrets\credentials"

# Function to read credential files securely
function Read-CredentialFile($filename) {
    $filePath = Join-Path $secretsPath $filename
    if (Test-Path $filePath) {
        return Get-Content $filePath -Raw
    }
    return $null
}

# GitHub CLI Authentication
Write-Host "`nAuthenticating GitHub CLI..." -ForegroundColor Yellow
Write-Host "-----------------------------" -ForegroundColor Yellow

$githubToken = Read-CredentialFile "github.token"
if ($githubToken) {
    # Set the token as an environment variable temporarily for gh auth login
    $env:GITHUB_TOKEN = $githubToken.Trim()
    
    # Login to GitHub CLI
    try {
        echo $githubToken.Trim() | gh auth login --with-token
        Write-Host "GitHub CLI authenticated successfully" -ForegroundColor Green
        
        # Verify authentication
        gh auth status
    }
    catch {
        Write-Host "Failed to authenticate GitHub CLI: $_" -ForegroundColor Red
    }
    finally {
        # Clear the environment variable
        Remove-Item Env:GITHUB_TOKEN -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "GitHub token not found. Run setup-credentials.ps1 first." -ForegroundColor Red
}

# Vercel CLI Authentication
Write-Host "`nAuthenticating Vercel CLI..." -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

$vercelToken = Read-CredentialFile "vercel.token"
if ($vercelToken) {
    # Set the token as an environment variable for Vercel CLI
    $env:VERCEL_TOKEN = $vercelToken.Trim()
    
    try {
        # Login to Vercel CLI using token
        vercel login --token $vercelToken.Trim()
        Write-Host "Vercel CLI authenticated successfully" -ForegroundColor Green
        
        # Verify authentication
        vercel whoami
    }
    catch {
        Write-Host "Failed to authenticate Vercel CLI: $_" -ForegroundColor Red
    }
    finally {
        # Clear the environment variable
        Remove-Item Env:VERCEL_TOKEN -ErrorAction SilentlyContinue
    }
} else {
    Write-Host "Vercel token not found. Run setup-credentials.ps1 first." -ForegroundColor Red
}

# Supabase CLI Authentication
Write-Host "`nSupabase CLI Setup..." -ForegroundColor Yellow
Write-Host "---------------------" -ForegroundColor Yellow

# Check if Supabase CLI is installed
try {
    $supabaseVersion = & supabase --version 2>$null
    if ($supabaseVersion) {
        Write-Host "Supabase CLI found: $supabaseVersion" -ForegroundColor Green
        
        $supabaseAccessToken = Read-CredentialFile "supabase.access.token"
        if ($supabaseAccessToken) {
            # Set the token as an environment variable
            $env:SUPABASE_ACCESS_TOKEN = $supabaseAccessToken.Trim()
            
            try {
                # Login to Supabase CLI
                supabase login --token $supabaseAccessToken.Trim()
                Write-Host "Supabase CLI authenticated successfully" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to authenticate Supabase CLI: $_" -ForegroundColor Red
            }
            finally {
                # Clear the environment variable
                Remove-Item Env:SUPABASE_ACCESS_TOKEN -ErrorAction SilentlyContinue
            }
        } else {
            Write-Host "Supabase access token not found. Run setup-supabase.ps1 first." -ForegroundColor Red
        }
    } else {
        Write-Host "Supabase CLI not installed. Please install manually:" -ForegroundColor Yellow
        Write-Host "- Download from: https://github.com/supabase/cli/releases" -ForegroundColor Cyan
        Write-Host "- Or use: scoop install supabase" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "Supabase CLI not installed. Please install manually:" -ForegroundColor Yellow
    Write-Host "- Download from: https://github.com/supabase/cli/releases" -ForegroundColor Cyan
    Write-Host "- Or use: scoop install supabase" -ForegroundColor Cyan
}

# Git Configuration Check
Write-Host "`nVerifying Git Configuration..." -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

$gitName = git config --global user.name
$gitEmail = git config --global user.email

if ($gitName -and $gitEmail) {
    Write-Host "Git configured with:" -ForegroundColor Green
    Write-Host "  Name: $gitName" -ForegroundColor White
    Write-Host "  Email: $gitEmail" -ForegroundColor White
} else {
    Write-Host "Git not fully configured. Please run:" -ForegroundColor Yellow
    Write-Host "  git config --global user.name 'Your Name'" -ForegroundColor Cyan
    Write-Host "  git config --global user.email 'your.email@domain.com'" -ForegroundColor Cyan
}

# Summary
Write-Host "`nCLI Authentication Summary" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green

Write-Host "Checking authentication status..." -ForegroundColor White

# GitHub CLI Status
try {
    $ghStatus = gh auth status 2>&1
    if ($ghStatus -like "*Logged in*") {
        Write-Host "✅ GitHub CLI: Authenticated" -ForegroundColor Green
    } else {
        Write-Host "❌ GitHub CLI: Not authenticated" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ GitHub CLI: Authentication check failed" -ForegroundColor Red
}

# Vercel CLI Status
try {
    $vercelUser = vercel whoami 2>&1
    if ($vercelUser -and $vercelUser -notlike "*Error*") {
        Write-Host "✅ Vercel CLI: Authenticated as $vercelUser" -ForegroundColor Green
    } else {
        Write-Host "❌ Vercel CLI: Not authenticated" -ForegroundColor Red
    }
}
catch {
    Write-Host "❌ Vercel CLI: Authentication check failed" -ForegroundColor Red
}

# Git Status
if ($gitName -and $gitEmail) {
    Write-Host "✅ Git: Configured ($gitName)" -ForegroundColor Green
} else {
    Write-Host "❌ Git: Not fully configured" -ForegroundColor Red
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Test the workflow with a sample project" -ForegroundColor White
Write-Host "2. Initialize a repository: git init" -ForegroundColor White
Write-Host "3. Create on GitHub: gh repo create" -ForegroundColor White
Write-Host "4. Deploy to Vercel: vercel --prod" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")