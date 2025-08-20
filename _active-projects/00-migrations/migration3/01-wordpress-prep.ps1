# WordPress Backend Preparation Script
# Creates migration-admin user and generates app passwords for headless migration
# Usage: ./01-wordpress-prep.ps1 -BatchFile "sites-to-migrate.csv" [-ResumeFromState "state.json"]

param(
    [Parameter(Mandatory=$true)]
    [string]$BatchFile,
    
    [Parameter(Mandatory=$false)]
    [string]$ResumeFromState,
    
    [Parameter(Mandatory=$false)]
    [switch]$ParallelServers,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnableStateTracking
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogDir = Join-Path $ScriptDir "logs"
$CredentialsDir = Join-Path $ScriptDir "credentials"
$SSHKeyPath = "C:\Users\user\.ssh\gridpane_rsa"
$SitesDBPath = "C:\Users\user\alphadev2\SSH\gridpane-sites-corrected.csv"

# Initialize logging
$LogFile = Join-Path $LogDir "01-wordpress-prep-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$StateFile = Join-Path $LogDir "script1-state.json"
$ResultsFile = Join-Path $LogDir "script1-results.json"

function Write-LogMessage {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    $LogEntry | Out-File -FilePath $LogFile -Append
}

function Save-State {
    param($State)
    if ($EnableStateTracking) {
        $State | ConvertTo-Json -Depth 5 | Out-File -FilePath $StateFile
    }
}

function Load-State {
    if ($ResumeFromState -and (Test-Path $ResumeFromState)) {
        Write-LogMessage "Loading state from: $ResumeFromState"
        return Get-Content $ResumeFromState | ConvertFrom-Json
    } elseif (Test-Path $StateFile) {
        Write-LogMessage "Loading existing state from: $StateFile"
        return Get-Content $StateFile | ConvertFrom-Json
    } else {
        return @{
            "completed_sites" = @()
            "failed_sites" = @()
            "pending_sites" = @()
            "credentials_created" = @{}
        }
    }
}

function Execute-SSHCommand {
    param(
        [string]$Server,
        [string]$Command,
        [int]$TimeoutSeconds = 60
    )
    
    $SSHCommand = "ssh -i `"$SSHKeyPath`" -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@$Server `"$Command`""
    
    Write-LogMessage "Executing SSH command on $Server`: $Command"
    
    try {
        $Result = Invoke-Expression $SSHCommand 2>&1
        $ExitCode = $LASTEXITCODE
        
        if ($ExitCode -eq 0) {
            Write-LogMessage "✅ SSH command successful on $Server" "SUCCESS"
            return @{ "success" = $true; "output" = $Result; "exit_code" = $ExitCode }
        } else {
            Write-LogMessage "❌ SSH command failed on $Server (Exit Code: $ExitCode)" "ERROR"
            Write-LogMessage "Output: $Result" "ERROR"
            return @{ "success" = $false; "output" = $Result; "exit_code" = $ExitCode }
        }
    } catch {
        Write-LogMessage "❌ SSH command exception on $Server`: $_" "ERROR"
        return @{ "success" = $false; "output" = $_.Exception.Message; "exit_code" = -1 }
    }
}

function Test-WordPressRESTAPI {
    param(
        [string]$Domain,
        [string]$Username,
        [string]$Password
    )
    
    Write-LogMessage "Testing WordPress REST API for $Domain"
    
    $TestURL = "https://staging.$Domain/wp-json/wp/v2/posts?per_page=1"
    $EncodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$Username`:$Password"))
    
    try {
        $Headers = @{
            "Authorization" = "Basic $EncodedCredentials"
            "Content-Type" = "application/json"
        }
        
        $Response = Invoke-RestMethod -Uri $TestURL -Headers $Headers -TimeoutSec 30
        
        if ($Response -is [Array] -or $Response.Count -ge 0) {
            Write-LogMessage "✅ REST API validation successful for $Domain" "SUCCESS"
            return @{ "success" = $true; "message" = "REST API accessible" }
        } else {
            Write-LogMessage "⚠️ REST API returned unexpected response for $Domain" "WARNING"
            return @{ "success" = $false; "message" = "Unexpected API response" }
        }
    } catch {
        $ErrorMessage = $_.Exception.Message
        Write-LogMessage "❌ REST API validation failed for $Domain`: $ErrorMessage" "ERROR"
        
        # Common error analysis
        if ($ErrorMessage -match "401") {
            return @{ "success" = $false; "message" = "Authentication failed - check credentials" }
        } elseif ($ErrorMessage -match "403") {
            return @{ "success" = $false; "message" = "Access forbidden - check user permissions" }
        } elseif ($ErrorMessage -match "404") {
            return @{ "success" = $false; "message" = "API endpoint not found - check WordPress setup" }
        } else {
            return @{ "success" = $false; "message" = "API connection failed: $ErrorMessage" }
        }
    }
}

function Process-WordPressSite {
    param(
        [object]$Site,
        [object]$SiteInfo,
        [object]$State
    )
    
    $Domain = $Site.Domain
    $BrandName = $Site.BrandName
    $ServerIP = $SiteInfo.IP
    $ServerName = $SiteInfo.SERVER  
    $SystemUser = $SiteInfo.GRIDPANE_USER
    
    Write-LogMessage "🔧 Processing WordPress site: $Domain (Server: $ServerName)"
    
    # Check if already completed
    if ($State.completed_sites -contains $Domain) {
        Write-LogMessage "⏭️ Skipping $Domain (already completed)"
        return @{ "success" = $true; "message" = "Already completed" }
    }
    
    $SiteResults = @{
        "domain" = $Domain
        "brand_name" = $BrandName
        "server" = $ServerName
        "steps_completed" = @()
        "errors" = @()
        "app_password_file" = ""
    }
    
    try {
        # Step 1: Deactivate problematic plugins
        Write-LogMessage "Step 1: Deactivating security plugins for $Domain"
        
        $PluginsToDeactivate = @(
            "wordfence",
            "force-login", 
            "wp-security-audit-log",
            "all-in-one-wp-security",
            "sucuri-scanner",
            "ithemes-security"
        )
        
        foreach ($Plugin in $PluginsToDeactivate) {
            $DeactivateCmd = "cd /var/www/staging.$Domain/htdocs && sudo -u $SystemUser wp plugin deactivate $Plugin"
            $Result = Execute-SSHCommand -Server $ServerIP -Command $DeactivateCmd
            
            if ($Result.success) {
                Write-LogMessage "✅ Deactivated plugin '$Plugin' on $Domain"
            } else {
                Write-LogMessage "⚠️ Plugin '$Plugin' deactivation failed on $Domain (may not be installed)" "WARNING"
            }
        }
        $SiteResults.steps_completed += "plugins_deactivated"
        
        # Step 2: Create migration admin user
        Write-LogMessage "Step 2: Creating migration-admin user for $Domain"
        
        $CreateUserCmd = "cd /var/www/staging.$Domain/htdocs && sudo -u $SystemUser wp user create migration-admin migration@$Domain --role=administrator --display_name='Migration Admin' --first_name='Migration' --last_name='Admin' --porcelain"
        $UserResult = Execute-SSHCommand -Server $ServerIP -Command $CreateUserCmd
        
        if ($UserResult.success) {
            $UserID = $UserResult.output.Trim()
            Write-LogMessage "✅ Created migration-admin user (ID: $UserID) for $Domain"
            $SiteResults.steps_completed += "user_created"
        } else {
            # User might already exist - try to get existing user
            $GetUserCmd = "cd /var/www/staging.$Domain/htdocs && sudo -u $SystemUser wp user get migration-admin --field=ID"
            $ExistingUserResult = Execute-SSHCommand -Server $ServerIP -Command $GetUserCmd
            
            if ($ExistingUserResult.success) {
                $UserID = $ExistingUserResult.output.Trim()
                Write-LogMessage "✅ Using existing migration-admin user (ID: $UserID) for $Domain"
                $SiteResults.steps_completed += "user_exists"
            } else {
                $ErrorMsg = "Failed to create or find migration-admin user for $Domain"
                Write-LogMessage "❌ $ErrorMsg" "ERROR"
                $SiteResults.errors += $ErrorMsg
                return @{ "success" = $false; "message" = $ErrorMsg; "details" = $SiteResults }
            }
        }
        
        # Step 3: Create application password
        Write-LogMessage "Step 3: Creating application password for $Domain"
        
        $CreateAppPasswordCmd = "cd /var/www/staging.$Domain/htdocs && sudo -u $SystemUser wp user application-password create migration-admin 'Migration-API' --porcelain"
        $AppPasswordResult = Execute-SSHCommand -Server $ServerIP -Command $CreateAppPasswordCmd
        
        if ($AppPasswordResult.success) {
            $AppPassword = $AppPasswordResult.output.Trim()
            Write-LogMessage "✅ Created application password for $Domain"
            
            # Save app password to file
            $AppPasswordFile = Join-Path $CredentialsDir "$Domain-app-password.txt"
            $AppPassword | Out-File -FilePath $AppPasswordFile -NoNewline
            
            $SiteResults.app_password_file = $AppPasswordFile
            $SiteResults.steps_completed += "app_password_created"
            
            Write-LogMessage "💾 Saved app password to: $AppPasswordFile"
        } else {
            $ErrorMsg = "Failed to create application password for $Domain"
            Write-LogMessage "❌ $ErrorMsg" "ERROR"
            $SiteResults.errors += $ErrorMsg
            return @{ "success" = $false; "message" = $ErrorMsg; "details" = $SiteResults }
        }
        
        # Step 4: Verify WordPress URLs
        Write-LogMessage "Step 4: Verifying WordPress URLs for $Domain"
        
        $SetHomeURLCmd = "cd /var/www/staging.$Domain/htdocs && sudo -u $SystemUser wp option update home 'https://staging.$Domain'"
        $SetSiteURLCmd = "cd /var/www/staging.$Domain/htdocs && sudo -u $SystemUser wp option update siteurl 'https://staging.$Domain'"
        
        $HomeURLResult = Execute-SSHCommand -Server $ServerIP -Command $SetHomeURLCmd
        $SiteURLResult = Execute-SSHCommand -Server $ServerIP -Command $SetSiteURLCmd
        
        if ($HomeURLResult.success -and $SiteURLResult.success) {
            Write-LogMessage "✅ WordPress URLs configured for $Domain"
            $SiteResults.steps_completed += "urls_configured"
        } else {
            Write-LogMessage "⚠️ WordPress URL configuration may have issues for $Domain" "WARNING"
        }
        
        # Step 5: Validate REST API access
        Write-LogMessage "Step 5: Validating REST API access for $Domain"
        
        $APITest = Test-WordPressRESTAPI -Domain $Domain -Username "migration-admin" -Password $AppPassword
        
        if ($APITest.success) {
            Write-LogMessage "✅ REST API validation successful for $Domain"
            $SiteResults.steps_completed += "api_validated"
            
            # Update state
            $State.completed_sites += $Domain
            $State.credentials_created[$Domain] = $AppPasswordFile
            
            return @{ 
                "success" = $true; 
                "message" = "WordPress preparation completed successfully"; 
                "details" = $SiteResults;
                "app_password_file" = $AppPasswordFile
            }
        } else {
            $ErrorMsg = "REST API validation failed for $Domain`: $($APITest.message)"
            Write-LogMessage "❌ $ErrorMsg" "ERROR"
            $SiteResults.errors += $ErrorMsg
            return @{ "success" = $false; "message" = $ErrorMsg; "details" = $SiteResults }
        }
        
    } catch {
        $ErrorMsg = "Exception processing $Domain`: $_"
        Write-LogMessage "❌ $ErrorMsg" "ERROR"
        $SiteResults.errors += $ErrorMsg
        return @{ "success" = $false; "message" = $ErrorMsg; "details" = $SiteResults }
    }
}

# Main execution
Write-LogMessage "🚀 Starting WordPress Backend Preparation"
Write-LogMessage "Batch File: $BatchFile"

# Load sites and database
if (-not (Test-Path $BatchFile)) {
    Write-LogMessage "❌ Batch file not found: $BatchFile" "ERROR"
    exit 1
}

if (-not (Test-Path $SitesDBPath)) {
    Write-LogMessage "❌ Sites database not found: $SitesDBPath" "ERROR"
    exit 1
}

$Sites = Import-Csv $BatchFile
$SitesDB = Import-Csv $SitesDBPath
Write-LogMessage "📊 Processing $($Sites.Count) sites"

# Load or initialize state
$State = Load-State

# Initialize results tracking
$Results = @{
    "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "total_sites" = $Sites.Count
    "completed_sites" = @()
    "failed_sites" = @()
    "credentials_created" = @{}
    "site_details" = @{}
}

# Process each site
foreach ($Site in $Sites) {
    $Domain = $Site.Domain
    
    # Find site in database
    $SiteInfo = $SitesDB | Where-Object { $_.DOMAIN -eq $Domain }
    
    if (-not $SiteInfo) {
        Write-LogMessage "❌ Domain $Domain not found in sites database" "ERROR"
        $Results.failed_sites += $Domain
        $Results.site_details[$Domain] = @{
            "status" = "failed"
            "error" = "Domain not found in sites database"
        }
        continue
    }
    
    # Process the WordPress site
    $SiteResult = Process-WordPressSite -Site $Site -SiteInfo $SiteInfo -State $State
    
    if ($SiteResult.success) {
        Write-LogMessage "🎉 Successfully processed $Domain" "SUCCESS"
        $Results.completed_sites += $Domain
        $Results.credentials_created[$Domain] = $SiteResult.app_password_file
        $Results.site_details[$Domain] = @{
            "status" = "completed"
            "app_password_file" = $SiteResult.app_password_file
            "details" = $SiteResult.details
        }
    } else {
        Write-LogMessage "❌ Failed to process $Domain`: $($SiteResult.message)" "ERROR"
        $Results.failed_sites += $Domain
        $State.failed_sites += $Domain
        $Results.site_details[$Domain] = @{
            "status" = "failed"
            "error" = $SiteResult.message
            "details" = $SiteResult.details
        }
    }
    
    # Save state after each site
    Save-State $State
    Start-Sleep -Seconds 2  # Brief pause between sites
}

# Final summary
Write-LogMessage "📋 WordPress Preparation Summary"
Write-LogMessage "Total Sites: $($Sites.Count)"
Write-LogMessage "Completed: $($Results.completed_sites.Count)"
Write-LogMessage "Failed: $($Results.failed_sites.Count)"

if ($Results.failed_sites.Count -gt 0) {
    Write-LogMessage "❌ Failed sites:" "ERROR"
    foreach ($FailedSite in $Results.failed_sites) {
        Write-LogMessage "   - $FailedSite" "ERROR"
    }
}

# Save results for next script
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $ResultsFile

Write-LogMessage "📄 Results saved to: $ResultsFile"
Write-LogMessage "📄 Log file: $LogFile"

if ($Results.failed_sites.Count -eq 0) {
    Write-LogMessage "🎉 All sites processed successfully!" "SUCCESS"
    exit 0
} else {
    Write-LogMessage "⚠️ Some sites failed processing. Check logs for details." "WARNING"  
    exit 1
}