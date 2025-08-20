# Next.js Project Generation Script
# Clones and customizes Next.js template for each domain
# Usage: ./03-nextjs-generator.ps1 -InputFile "script1-results.json" [-ValidateTemplate]

param(
    [Parameter(Mandatory=$false)]
    [string]$BatchFile,
    
    [Parameter(Mandatory=$false)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateTemplate,
    
    [Parameter(Mandatory=$false)]
    [switch]$WaitForScript1
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogDir = Join-Path $ScriptDir "logs"
$MasterTemplatePath = "C:\Users\user\alphadev2\migration\projects\stocktiming-headless\stocktiming-headless"
$ProjectsBasePath = "C:\Users\user\alphadev2\migration\projects"

# Load credentials paths
$CredentialsDir = Join-Path $ScriptDir "credentials"
$ResendKeyPath = "C:\Users\user\alphadev2\devops\secrets\credentials\resend.key"
$TurnstilePath = Join-Path $ScriptDir "turnstile-keys.txt"  # We'll create this

# Initialize logging
$LogFile = Join-Path $LogDir "03-nextjs-generator-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$ResultsFile = Join-Path $LogDir "script3-results.json"

function Write-LogMessage {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    $LogEntry | Out-File -FilePath $LogFile -Append
}

function Test-MasterTemplate {
    Write-LogMessage "🔍 Validating master template"
    
    $ValidationResults = @{
        "template_exists" = $false
        "required_files" = @{}
        "package_json_valid" = $false
        "env_template_exists" = $false
        "build_test_passed" = $false
    }
    
    # Check if template directory exists
    if (-not (Test-Path $MasterTemplatePath)) {
        Write-LogMessage "❌ Master template not found at: $MasterTemplatePath" "ERROR"
        return $ValidationResults
    }
    
    $ValidationResults.template_exists = $true
    Write-LogMessage "✅ Master template directory found"
    
    # Check required files
    $RequiredFiles = @{
        "package.json" = Join-Path $MasterTemplatePath "package.json"
        "next.config.js" = Join-Path $MasterTemplatePath "next.config.js"
        "src/app/layout.tsx" = Join-Path $MasterTemplatePath "src\app\layout.tsx"
        "src/app/page.tsx" = Join-Path $MasterTemplatePath "src\app\page.tsx"
        "src/lib/wordpress.ts" = Join-Path $MasterTemplatePath "src\lib\wordpress.ts"
        "src/components/Header.tsx" = Join-Path $MasterTemplatePath "src\components\Header.tsx"
        "src/components/Footer.tsx" = Join-Path $MasterTemplatePath "src\components\Footer.tsx"
        "src/components/ContactForm.tsx" = Join-Path $MasterTemplatePath "src\components\ContactForm.tsx"
        ".env.production" = Join-Path $MasterTemplatePath ".env.production"
    }
    
    foreach ($FileKey in $RequiredFiles.Keys) {
        $FilePath = $RequiredFiles[$FileKey]
        if (Test-Path $FilePath) {
            Write-LogMessage "✅ Required file found: $FileKey"
            $ValidationResults.required_files[$FileKey] = $true
        } else {
            Write-LogMessage "❌ Required file missing: $FileKey" "ERROR"
            $ValidationResults.required_files[$FileKey] = $false
        }
    }
    
    # Validate package.json
    try {
        $PackageJsonPath = Join-Path $MasterTemplatePath "package.json"
        $PackageJson = Get-Content $PackageJsonPath | ConvertFrom-Json
        
        if ($PackageJson.name -and $PackageJson.scripts -and $PackageJson.scripts.build) {
            Write-LogMessage "✅ package.json is valid"
            $ValidationResults.package_json_valid = $true
        } else {
            Write-LogMessage "❌ package.json is missing required fields" "ERROR"
        }
    } catch {
        Write-LogMessage "❌ Error validating package.json: $_" "ERROR"
    }
    
    # Check environment template
    $EnvPath = Join-Path $MasterTemplatePath ".env.production"
    if (Test-Path $EnvPath) {
        Write-LogMessage "✅ Environment template found"
        $ValidationResults.env_template_exists = $true
    } else {
        Write-LogMessage "❌ Environment template missing" "ERROR"
    }
    
    return $ValidationResults
}

function Load-APIKeys {
    Write-LogMessage "🔑 Loading API keys and credentials"
    
    $APIKeys = @{
        "resend_api_key" = ""
        "turnstile_site_key" = "0x4AAAAAABrmbM4_ZthcCAes"
        "turnstile_secret_key" = "0x4AAAAAABrmbFVyK7DST8dg3n7tTTDOW2w" 
        "supabase_url" = "https://nkcjwrksvmjzqsatwkac.supabase.co"
        "supabase_anon_key" = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5rY2p3cmtzdm1qenFzYXR3a2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ3NjE5NjQsImV4cCI6MjA3MDMzNzk2NH0.iGKlyAsBUYNdwA6XuX0fzv_0wZQRFB4BFpCbLXJfHuU"
    }
    
    # Load Resend API key
    if (Test-Path $ResendKeyPath) {
        $APIKeys.resend_api_key = (Get-Content $ResendKeyPath -Raw).Trim()
        Write-LogMessage "✅ Resend API key loaded"
    } else {
        Write-LogMessage "⚠️ Resend API key not found, using default" "WARNING"
        $APIKeys.resend_api_key = "re_MPtZwtkg_DW7de2PRMu38sfCwepKT6aDK"
    }
    
    return $APIKeys
}

function Create-NextJSProject {
    param(
        [string]$Domain,
        [string]$BrandName,
        [string]$AppPasswordFile,
        [hashtable]$APIKeys
    )
    
    Write-LogMessage "🚀 Creating Next.js project for $Domain"
    
    $ProjectResults = @{
        "domain" = $Domain
        "brand_name" = $BrandName
        "project_path" = ""
        "steps_completed" = @()
        "errors" = @()
    }
    
    try {
        # Define project path
        $ProjectName = "$Domain-headless"
        $ProjectPath = Join-Path $ProjectsBasePath $ProjectName
        $ProjectResults.project_path = $ProjectPath
        
        Write-LogMessage "Creating project directory: $ProjectPath"
        
        # Step 1: Clone template
        if (Test-Path $ProjectPath) {
            Write-LogMessage "⚠️ Project directory already exists, removing: $ProjectPath" "WARNING"
            Remove-Item -Path $ProjectPath -Recurse -Force
        }
        
        Copy-Item -Path $MasterTemplatePath -Destination $ProjectPath -Recurse
        Write-LogMessage "✅ Template cloned successfully"
        $ProjectResults.steps_completed += "template_cloned"
        
        # Step 2: Load app password
        if (-not (Test-Path $AppPasswordFile)) {
            throw "App password file not found: $AppPasswordFile"
        }
        
        $AppPassword = (Get-Content $AppPasswordFile -Raw).Trim()
        Write-LogMessage "✅ App password loaded from: $AppPasswordFile"
        $ProjectResults.steps_completed += "app_password_loaded"
        
        # Step 3: Update package.json
        Write-LogMessage "Updating package.json"
        $PackageJsonPath = Join-Path $ProjectPath "package.json"
        $PackageJson = Get-Content $PackageJsonPath | ConvertFrom-Json
        
        $PackageJson.name = $ProjectName.ToLower()
        $PackageJson.version = "1.0.0"
        $PackageJson | ConvertTo-Json -Depth 5 | Set-Content $PackageJsonPath
        
        Write-LogMessage "✅ package.json updated"
        $ProjectResults.steps_completed += "package_json_updated"
        
        # Step 4: Find and replace domain references
        Write-LogMessage "Updating domain references"
        
        $FilesToUpdate = @()
        $FilesToUpdate += Get-ChildItem -Path $ProjectPath -Recurse -Include "*.ts", "*.tsx", "*.js", "*.json" | Where-Object { 
            $_.FullName -notmatch "node_modules" -and $_.FullName -notmatch "\.git" 
        }
        
        foreach ($File in $FilesToUpdate) {
            try {
                $Content = Get-Content $File.FullName -Raw -Encoding UTF8
                $OriginalContent = $Content
                
                # Replace domain references
                $Content = $Content -replace 'stocktiming\.com', $Domain
                $Content = $Content -replace 'staging\.stocktiming\.com', "staging.$Domain"
                $Content = $Content -replace 'Stock Timing', $BrandName
                $Content = $Content -replace 'stocktiming-headless', $ProjectName
                
                if ($Content -ne $OriginalContent) {
                    Set-Content -Path $File.FullName -Value $Content -Encoding UTF8
                    Write-LogMessage "Updated: $($File.Name)"
                }
            } catch {
                Write-LogMessage "⚠️ Error updating file $($File.FullName): $_" "WARNING"
            }
        }
        
        Write-LogMessage "✅ Domain references updated"
        $ProjectResults.steps_completed += "domain_references_updated"
        
        # Step 5: Create environment file
        Write-LogMessage "Creating .env.production file"
        
        $EnvContent = @"
# WordPress API Configuration
WORDPRESS_API_URL=https://staging.$Domain/wp-json/wp/v2
WORDPRESS_URL=https://staging.$Domain
WORDPRESS_HOSTNAME=staging.$Domain
WORDPRESS_USERNAME=migration-admin
WORDPRESS_APP_PASSWORD=$AppPassword

# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=$($APIKeys.supabase_url)
NEXT_PUBLIC_SUPABASE_ANON_KEY=$($APIKeys.supabase_anon_key)

# Contact Form - Resend Email Service
RESEND_API_KEY=$($APIKeys.resend_api_key)

# Contact Form - Cloudflare Turnstile  
NEXT_PUBLIC_TURNSTILE_SITE_KEY=$($APIKeys.turnstile_site_key)
TURNSTILE_SECRET_KEY=$($APIKeys.turnstile_secret_key)

# Development Test Keys (Always Pass in Development)
NEXT_PUBLIC_TURNSTILE_SITE_KEY_DEV=1x00000000000000000000AA
TURNSTILE_SECRET_KEY_DEV=1x0000000000000000000000000000000AA

# Site Configuration
NEXT_PUBLIC_SITE_URL=https://$ProjectName.vercel.app
CONTACT_EMAIL=padocs@gmail.com
"@
        
        $EnvPath = Join-Path $ProjectPath ".env.production"
        $EnvContent | Set-Content -Path $EnvPath
        
        Write-LogMessage "✅ Environment file created"
        $ProjectResults.steps_completed += "env_file_created"
        
        # Step 6: Initialize Git repository
        Write-LogMessage "Initializing Git repository"
        
        Push-Location $ProjectPath
        try {
            # Initialize git
            & git init 2>&1 | Out-Null
            
            # Create .gitignore if it doesn't exist
            $GitIgnorePath = Join-Path $ProjectPath ".gitignore"
            if (-not (Test-Path $GitIgnorePath)) {
                $GitIgnoreContent = @"
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/

# Next.js
.next/
out/

# Production
build

# Misc
.DS_Store
*.tsbuildinfo
next-env.d.ts

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env.local
.env.development.local
.env.test.local
.env.production.local

# Vercel
.vercel
"@
                $GitIgnoreContent | Set-Content -Path $GitIgnorePath
            }
            
            # Add all files and create initial commit
            & git add . 2>&1 | Out-Null
            & git commit -m "Initial migration setup for $Domain

- Configured WordPress API integration
- Added contact form with Resend email service  
- Setup Cloudflare Turnstile CAPTCHA protection
- Configured Supabase database logging
- Customized branding for $BrandName
- Ready for GitHub repository connection" 2>&1 | Out-Null
            
            Write-LogMessage "✅ Git repository initialized with initial commit"
            $ProjectResults.steps_completed += "git_initialized"
            
        } catch {
            Write-LogMessage "❌ Error initializing Git: $_" "ERROR"
            $ProjectResults.errors += "Git initialization failed: $_"
        } finally {
            Pop-Location
        }
        
        # Step 7: Validate project structure
        Write-LogMessage "Validating project structure"
        
        $ValidationPassed = $true
        $RequiredProjectFiles = @(
            "package.json",
            "next.config.js", 
            "src/app/layout.tsx",
            "src/app/page.tsx",
            "src/components/ContactForm.tsx",
            ".env.production",
            ".git/config"
        )
        
        foreach ($RequiredFile in $RequiredProjectFiles) {
            $FilePath = Join-Path $ProjectPath $RequiredFile
            if (-not (Test-Path $FilePath)) {
                Write-LogMessage "❌ Required file missing after generation: $RequiredFile" "ERROR"
                $ProjectResults.errors += "Required file missing: $RequiredFile"
                $ValidationPassed = $false
            }
        }
        
        if ($ValidationPassed) {
            Write-LogMessage "✅ Project structure validation passed"
            $ProjectResults.steps_completed += "validation_passed"
        } else {
            Write-LogMessage "❌ Project structure validation failed" "ERROR"
        }
        
        Write-LogMessage "🎉 Next.js project created successfully for $Domain"
        return @{ "success" = $true; "message" = "Project created successfully"; "details" = $ProjectResults }
        
    } catch {
        $ErrorMsg = "Failed to create Next.js project for $Domain`: $_"
        Write-LogMessage "❌ $ErrorMsg" "ERROR"
        $ProjectResults.errors += $ErrorMsg
        return @{ "success" = $false; "message" = $ErrorMsg; "details" = $ProjectResults }
    }
}

# Main execution
Write-LogMessage "🚀 Starting Next.js Project Generation"

# Determine input source
$SitesToProcess = @()

if ($InputFile -and (Test-Path $InputFile)) {
    Write-LogMessage "📄 Loading sites from Script 1 results: $InputFile"
    
    try {
        $Script1Results = Get-Content $InputFile | ConvertFrom-Json
        
        if ($Script1Results.completed_sites -and $Script1Results.completed_sites.Count -gt 0) {
            # Load original batch file to get brand names
            if ($BatchFile -and (Test-Path $BatchFile)) {
                $OriginalSites = Import-Csv $BatchFile
                
                foreach ($Domain in $Script1Results.completed_sites) {
                    $SiteInfo = $OriginalSites | Where-Object { $_.Domain -eq $Domain }
                    if ($SiteInfo) {
                        $SitesToProcess += @{
                            "Domain" = $Domain
                            "BrandName" = $SiteInfo.BrandName
                            "AppPasswordFile" = $Script1Results.credentials_created[$Domain]
                        }
                    }
                }
            } else {
                Write-LogMessage "❌ BatchFile required when using InputFile to get brand names" "ERROR"
                exit 1
            }
        } else {
            Write-LogMessage "❌ No completed sites found in Script 1 results" "ERROR"
            exit 1
        }
    } catch {
        Write-LogMessage "❌ Error loading Script 1 results: $_" "ERROR"
        exit 1
    }
    
} elseif ($BatchFile -and (Test-Path $BatchFile)) {
    Write-LogMessage "📄 Loading sites from batch file: $BatchFile"
    
    $Sites = Import-Csv $BatchFile
    foreach ($Site in $Sites) {
        $AppPasswordFile = Join-Path $CredentialsDir "$($Site.Domain)-app-password.txt"
        $SitesToProcess += @{
            "Domain" = $Site.Domain
            "BrandName" = $Site.BrandName  
            "AppPasswordFile" = $AppPasswordFile
        }
    }
} else {
    Write-LogMessage "❌ Either InputFile or BatchFile must be provided" "ERROR"
    exit 1
}

Write-LogMessage "📊 Processing $($SitesToProcess.Count) sites"

# Validate master template if requested
if ($ValidateTemplate) {
    Write-LogMessage "🔍 Validating master template"
    $TemplateValidation = Test-MasterTemplate
    
    if (-not $TemplateValidation.template_exists) {
        Write-LogMessage "❌ Master template validation failed" "ERROR"
        exit 1
    }
    
    $RequiredFilesFailed = $TemplateValidation.required_files.GetEnumerator() | Where-Object { -not $_.Value }
    if ($RequiredFilesFailed.Count -gt 0) {
        Write-LogMessage "❌ Master template is missing required files" "ERROR"
        exit 1
    }
    
    Write-LogMessage "✅ Master template validation passed"
}

# Load API keys
$APIKeys = Load-APIKeys

# Initialize results
$Results = @{
    "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "total_sites" = $SitesToProcess.Count
    "completed_projects" = @()
    "failed_projects" = @()
    "project_details" = @{}
}

# Process each site
foreach ($Site in $SitesToProcess) {
    $Domain = $Site.Domain
    $BrandName = $Site.BrandName
    $AppPasswordFile = $Site.AppPasswordFile
    
    Write-LogMessage "🔧 Processing $Domain ($BrandName)"
    
    # Verify app password file exists
    if (-not (Test-Path $AppPasswordFile)) {
        Write-LogMessage "❌ App password file not found for $Domain`: $AppPasswordFile" "ERROR"
        $Results.failed_projects += $Domain
        $Results.project_details[$Domain] = @{
            "status" = "failed"
            "error" = "App password file not found: $AppPasswordFile"
        }
        continue
    }
    
    # Create the Next.js project
    $ProjectResult = Create-NextJSProject -Domain $Domain -BrandName $BrandName -AppPasswordFile $AppPasswordFile -APIKeys $APIKeys
    
    if ($ProjectResult.success) {
        Write-LogMessage "🎉 Successfully created project for $Domain" "SUCCESS"
        $Results.completed_projects += $Domain
        $Results.project_details[$Domain] = @{
            "status" = "completed"
            "project_path" = $ProjectResult.details.project_path
            "details" = $ProjectResult.details
        }
    } else {
        Write-LogMessage "❌ Failed to create project for $Domain`: $($ProjectResult.message)" "ERROR"
        $Results.failed_projects += $Domain
        $Results.project_details[$Domain] = @{
            "status" = "failed"
            "error" = $ProjectResult.message
            "details" = $ProjectResult.details
        }
    }
}

# Final summary
Write-LogMessage "📋 Next.js Project Generation Summary"
Write-LogMessage "Total Sites: $($SitesToProcess.Count)"
Write-LogMessage "Completed: $($Results.completed_projects.Count)"
Write-LogMessage "Failed: $($Results.failed_projects.Count)"

if ($Results.failed_projects.Count -gt 0) {
    Write-LogMessage "❌ Failed projects:" "ERROR"
    foreach ($FailedSite in $Results.failed_projects) {
        Write-LogMessage "   - $FailedSite" "ERROR"
    }
}

# Save results for next script
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $ResultsFile

Write-LogMessage "📄 Results saved to: $ResultsFile"
Write-LogMessage "📄 Log file: $LogFile"

if ($Results.failed_projects.Count -eq 0) {
    Write-LogMessage "🎉 All Next.js projects created successfully!" "SUCCESS"
    exit 0
} else {
    Write-LogMessage "⚠️ Some projects failed. Check logs for details." "WARNING"
    exit 1
}