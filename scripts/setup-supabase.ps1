# AlphaDev2 Supabase Setup Script
# This script helps you securely set up Supabase credentials

Write-Host "Supabase Configuration Setup" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

$secretsPath = "C:\Users\user\alphadev2\secrets"
$credentialsPath = "$secretsPath\credentials"

# Ensure directories exist
if (!(Test-Path $credentialsPath)) {
    New-Item -Path $credentialsPath -ItemType Directory -Force
}

Write-Host "`nThis script will help you set up your Supabase database credentials." -ForegroundColor White
Write-Host "You'll need these from your Supabase project dashboard." -ForegroundColor White

Write-Host "`nSupabase Project Setup" -ForegroundColor Yellow
Write-Host "---------------------" -ForegroundColor Yellow
Write-Host "Get these values from: https://app.supabase.com/project/YOUR_PROJECT/settings/api" -ForegroundColor Cyan

# Project URL
$supabaseUrl = Read-Host -Prompt "Enter your Supabase Project URL (https://xxx.supabase.co)"
if ($supabaseUrl) {
    $supabaseUrl | Out-File -FilePath "$credentialsPath\supabase.url" -Encoding UTF8 -NoNewline
    Write-Host "Supabase URL saved" -ForegroundColor Green
}

# Anon/Public Key
$supabaseAnonKey = Read-Host -Prompt "Enter your Supabase Anon/Public Key" -AsSecureString
if ($supabaseAnonKey.Length -gt 0) {
    $supabaseAnonKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($supabaseAnonKey))
    $supabaseAnonKeyPlain | Out-File -FilePath "$credentialsPath\supabase.anon.key" -Encoding UTF8 -NoNewline
    Write-Host "Supabase Anon Key saved securely" -ForegroundColor Green
    
    # Clear sensitive variable
    $supabaseAnonKeyPlain = $null
    [System.GC]::Collect()
}

# Service Role Key (Optional but recommended for backend)
Write-Host "`nSupabase Service Role Key (Optional)" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host "This key has admin privileges - only for server-side use!" -ForegroundColor Red

$supabaseServiceKey = Read-Host -Prompt "Enter your Supabase Service Role Key [Optional]" -AsSecureString
if ($supabaseServiceKey.Length -gt 0) {
    $supabaseServiceKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($supabaseServiceKey))
    $supabaseServiceKeyPlain | Out-File -FilePath "$credentialsPath\supabase.service.key" -Encoding UTF8 -NoNewline
    Write-Host "Supabase Service Key saved securely" -ForegroundColor Green
    
    # Clear sensitive variable
    $supabaseServiceKeyPlain = $null
    [System.GC]::Collect()
}

# Database Connection String (Optional for direct PostgreSQL access)
Write-Host "`nDirect Database Connection (Optional)" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host "For direct PostgreSQL access - get from Database Settings" -ForegroundColor Cyan

$supabaseDbUrl = Read-Host -Prompt "Enter Supabase Database URL [Optional]" -AsSecureString
if ($supabaseDbUrl.Length -gt 0) {
    $supabaseDbUrlPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($supabaseDbUrl))
    $supabaseDbUrlPlain | Out-File -FilePath "$credentialsPath\supabase.database.url" -Encoding UTF8 -NoNewline
    Write-Host "Supabase Database URL saved securely" -ForegroundColor Green
    
    # Clear sensitive variable
    $supabaseDbUrlPlain = $null
    [System.GC]::Collect()
}

# Management API Token (Personal Access Token)
Write-Host "`nSupabase Management API Token (Optional)" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow
Write-Host "For CLI operations, automated deployments, and schema management" -ForegroundColor Cyan
Write-Host "Get from: https://app.supabase.com/account/tokens" -ForegroundColor Cyan

$supabaseAccessToken = Read-Host -Prompt "Enter Supabase Management/Personal Access Token [Optional]" -AsSecureString
if ($supabaseAccessToken.Length -gt 0) {
    $supabaseAccessTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($supabaseAccessToken))
    $supabaseAccessTokenPlain | Out-File -FilePath "$credentialsPath\supabase.access.token" -Encoding UTF8 -NoNewline
    Write-Host "Supabase Management API Token saved securely" -ForegroundColor Green
    
    # Clear sensitive variable
    $supabaseAccessTokenPlain = $null
    [System.GC]::Collect()
}

# Update global environment file with Supabase references
Write-Host "`nUpdating global environment file..." -ForegroundColor Yellow

$globalEnvPath = "$secretsPath\.env.global"
if (Test-Path $globalEnvPath) {
    $currentContent = Get-Content $globalEnvPath -Raw
    
    $supabaseSection = @"

# Supabase Configuration
# Credentials loaded from individual files:
# SUPABASE_URL loaded from credentials/supabase.url
# SUPABASE_ANON_KEY loaded from credentials/supabase.anon.key  
# SUPABASE_SERVICE_KEY loaded from credentials/supabase.service.key
# SUPABASE_DB_URL loaded from credentials/supabase.database.url
# SUPABASE_ACCESS_TOKEN loaded from credentials/supabase.access.token
"@
    
    # Only add if not already present
    if ($currentContent -notmatch "Supabase Configuration") {
        $currentContent + $supabaseSection | Out-File -FilePath $globalEnvPath -Encoding UTF8
        Write-Host "Global environment file updated with Supabase references" -ForegroundColor Green
    } else {
        Write-Host "Supabase section already exists in global environment file" -ForegroundColor Yellow
    }
} else {
    Write-Host "Global environment file not found. Run setup-credentials.ps1 first." -ForegroundColor Red
}

# Create Supabase-specific environment template
Write-Host "`nCreating Supabase project template..." -ForegroundColor Yellow

$supabaseTemplate = @"
# Supabase Project Environment Template
# Copy to your project and rename to .env.local

# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_KEY=your_supabase_service_key

# Database Direct Access (Optional)
DATABASE_URL=your_supabase_postgres_url

# Next.js Supabase (if using Next.js)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Management API (for CLI, deployments, schema management)
SUPABASE_ACCESS_TOKEN=your_management_api_token

# Additional Supabase Features
SUPABASE_JWT_SECRET=your_jwt_secret
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Storage Bucket (if using Supabase Storage)
SUPABASE_STORAGE_BUCKET=your_bucket_name
"@

$supabaseTemplate | Out-File -FilePath "$secretsPath\templates\.env.supabase.template" -Encoding UTF8
Write-Host "Supabase template created: secrets/templates/.env.supabase.template" -ForegroundColor Green

# Summary
Write-Host "`nSupabase Setup Complete!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host "Credentials saved securely in: $credentialsPath" -ForegroundColor White
Write-Host "Template created for new projects" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Test connection with your Supabase client" -ForegroundColor White
Write-Host "2. Copy .env.supabase.template to your project" -ForegroundColor White
Write-Host "3. Use the credential loading pattern in your app" -ForegroundColor White
Write-Host "4. Set up Row Level Security (RLS) policies in Supabase" -ForegroundColor White

Write-Host "`nSecurity Reminder:" -ForegroundColor Yellow
Write-Host "- Never expose Service Role Key in client-side code" -ForegroundColor White
Write-Host "- Use Anon Key for client-side, Service Key for server-side only" -ForegroundColor White
Write-Host "- Set up proper RLS policies for data security" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")