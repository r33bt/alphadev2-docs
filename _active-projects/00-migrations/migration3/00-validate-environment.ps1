# Migration Environment Validation Script
# Validates all prerequisites before starting migration automation
# Usage: ./00-validate-environment.ps1 -BatchFile "sites-to-migrate.csv"

param(
    [Parameter(Mandatory=$true)]
    [string]$BatchFile
)

# Create required directories
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogDir = Join-Path $ScriptDir "logs"
$CredentialsDir = Join-Path $ScriptDir "credentials" 
$ReportsDir = Join-Path $ScriptDir "reports"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
New-Item -ItemType Directory -Force -Path $CredentialsDir | Out-Null
New-Item -ItemType Directory -Force -Path $ReportsDir | Out-Null

# Initialize log file
$LogFile = Join-Path $LogDir "00-environment-validation-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$ValidationResults = @{
    "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "total_sites" = 0
    "validation_passed" = $false
    "errors" = @()
    "warnings" = @()
    "site_validation" = @{}
    "credential_validation" = @{}
    "system_validation" = @{}
}

function Write-LogMessage {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    $LogEntry | Out-File -FilePath $LogFile -Append
}

function Test-CredentialFile {
    param([string]$Path, [string]$Description)
    
    Write-LogMessage "Validating $Description at: $Path"
    
    # Special handling for Master_Template (it's a directory)
    if ($Description -eq "Master_Template") {
        if (Test-Path $Path -PathType Container) {
            # Check if directory has required files
            $RequiredFiles = @("package.json", "src\app\layout.tsx", "src\components\ContactForm.tsx")
            $AllExist = $true
            foreach ($File in $RequiredFiles) {
                if (-not (Test-Path (Join-Path $Path $File))) {
                    $AllExist = $false
                    break
                }
            }
            if ($AllExist) {
                Write-LogMessage "[OK] ${Description}: Valid" "SUCCESS"
                return @{ "status" = "valid"; "path" = $Path }
            } else {
                Write-LogMessage "[ERROR] ${Description}: Directory exists but missing required files" "ERROR"
                return @{ "status" = "incomplete"; "path" = $Path }
            }
        } else {
            Write-LogMessage "[ERROR] ${Description}: Directory not found" "ERROR"
            return @{ "status" = "missing"; "path" = $Path }
        }
    }
    
    # Regular file validation
    if (Test-Path $Path) {
        $Content = Get-Content $Path -Raw -ErrorAction SilentlyContinue
        if ($Content -and $Content.Trim().Length -gt 0) {
            Write-LogMessage "[OK] ${Description}: Valid" "SUCCESS"
            return @{ "status" = "valid"; "path" = $Path }
        } else {
            Write-LogMessage "[ERROR] ${Description}: File exists but is empty" "ERROR"
            return @{ "status" = "empty"; "path" = $Path }
        }
    } else {
        Write-LogMessage "[ERROR] ${Description}: File not found" "ERROR"
        return @{ "status" = "missing"; "path" = $Path }
    }
}
}

Write-LogMessage "[STARTING] Migration Environment Validation"
Write-LogMessage "Batch File: $BatchFile"

# Validate batch file exists
if (-not (Test-Path $BatchFile)) {
    Write-LogMessage "[ERROR] Batch file not found: $BatchFile" "ERROR"
    $ValidationResults.errors += "Batch file not found: $BatchFile"
    $ValidationResults | ConvertTo-Json -Depth 5 | Out-File -FilePath (Join-Path $ReportsDir "validation-results.json")
    exit 1
}

# Read and validate sites from CSV
try {
    $Sites = Import-Csv $BatchFile
    $ValidationResults.total_sites = $Sites.Count
    Write-LogMessage "[INFO] Processing $($Sites.Count) sites from batch file"
    
    if ($Sites.Count -eq 0) {
        Write-LogMessage "[ERROR] No sites found in batch file" "ERROR"
        $ValidationResults.errors += "No sites found in batch file"
    }
    
    # Validate CSV structure
    $RequiredColumns = @("Domain", "BrandName")
    foreach ($Column in $RequiredColumns) {
        if (-not ($Sites | Get-Member -Name $Column)) {
            Write-LogMessage "[ERROR] Required column '$Column' missing from CSV" "ERROR"
            $ValidationResults.errors += "Required column '$Column' missing from CSV"
        }
    }
} catch {
    Write-LogMessage "[ERROR] Error reading batch file: $_" "ERROR"
    $ValidationResults.errors += "Error reading batch file: $_"
}

Write-LogMessage "[CREDENTIALS] Validating API Credentials"

# Validate all required credential files
$CredentialPaths = @{
    "SSH_Key" = "C:\Users\user\.ssh\gridpane_rsa"
    "Vercel_Token" = "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token"
    "GitHub_Token" = "C:\Users\user\alphadev2\devops\secrets\credentials\github.token"
    "Resend_Key" = "C:\Users\user\alphadev2\devops\secrets\credentials\resend.key"
    "Cloudflare_Token" = "C:\Users\user\alphadev2\devops\secrets\credentials\cloudflare.token"
    "Sites_Database" = "C:\Users\user\alphadev2\SSH\gridpane-sites-corrected.csv"
    "Master_Template" = "C:\Users\user\alphadev2\migration\projects\stocktiming-headless\stocktiming-headless"
}

foreach ($CredName in $CredentialPaths.Keys) {
    $Result = Test-CredentialFile -Path $CredentialPaths[$CredName] -Description $CredName
    $ValidationResults.credential_validation[$CredName] = $Result
    
    if ($Result.status -ne "valid") {
        $ValidationResults.errors += "$CredName validation failed: $($Result.status)"
    }
}

Write-LogMessage "[DATABASE] Validating Sites Database"

# Load and validate sites database
try {
    $SitesDB = Import-Csv "C:\Users\user\alphadev2\SSH\gridpane-sites-corrected.csv"
    Write-LogMessage "[INFO] Sites database contains $($SitesDB.Count) entries"
    
    # Validate each domain from batch file exists in sites database
    foreach ($Site in $Sites) {
        $Domain = $Site.Domain
        $SiteInfo = $SitesDB | Where-Object { $_.DOMAIN -eq $Domain }
        
        if ($SiteInfo) {
            Write-LogMessage "[OK] $Domain found in sites database (Server: $($SiteInfo.SERVER))"
            $ValidationResults.site_validation[$Domain] = @{
                "found_in_db" = $true
                "server" = $SiteInfo.SERVER
                "ip" = $SiteInfo.IP
                "system_user" = $SiteInfo.GRIDPANE_USER
            }
        } else {
            Write-LogMessage "[ERROR] $Domain NOT found in sites database" "ERROR"
            $ValidationResults.site_validation[$Domain] = @{
                "found_in_db" = $false
            }
            $ValidationResults.errors += "$Domain not found in sites database"
        }
    }
} catch {
    Write-LogMessage "[ERROR] Error reading sites database: $_" "ERROR"
    $ValidationResults.errors += "Error reading sites database: $_"
}

Write-LogMessage "[SYSTEM] Validating System Resources"

# Check disk space (need ~6GB for 30 sites)
$RequiredSpaceGB = [math]::Ceiling($Sites.Count * 0.2)  # 200MB per site
try {
    $Drive = Get-PSDrive -Name (Split-Path $ScriptDir -Qualifier).TrimEnd(':')
    $FreeSpaceGB = [math]::Round($Drive.Free / 1GB, 2)
    
    Write-LogMessage "[INFO] Available disk space: $FreeSpaceGB GB"
    Write-LogMessage "[INFO] Required disk space: $RequiredSpaceGB GB"
    
    if ($FreeSpaceGB -ge $RequiredSpaceGB) {
        Write-LogMessage "[OK] Sufficient disk space available" "SUCCESS"
        $ValidationResults.system_validation["disk_space"] = @{
            "available_gb" = $FreeSpaceGB
            "required_gb" = $RequiredSpaceGB
            "sufficient" = $true
        }
    } else {
        Write-LogMessage "[ERROR] Insufficient disk space" "ERROR"
        $ValidationResults.system_validation["disk_space"] = @{
            "available_gb" = $FreeSpaceGB
            "required_gb" = $RequiredSpaceGB
            "sufficient" = $false
        }
        $ValidationResults.errors += "Insufficient disk space: $FreeSpaceGB GB available, $RequiredSpaceGB GB required"
    }
} catch {
    Write-LogMessage "[ERROR] Error checking disk space: $_" "ERROR"
    $ValidationResults.errors += "Error checking disk space: $_"
}

Write-LogMessage "[NETWORK] Testing Network Connectivity"

# Test SSH connectivity to all servers
$Servers = @{
    "cendol-may25" = "162.243.15.7"
    "bessie" = "68.183.24.139"
    "legal-may25" = "138.197.11.181"
    "kampung-may25" = "162.243.4.151"
}

foreach ($ServerName in $Servers.Keys) {
    $ServerIP = $Servers[$ServerName]
    Write-LogMessage "Testing SSH connectivity to $ServerName ($ServerIP)"
    
    try {
        $SSHTest = Test-NetConnection -ComputerName $ServerIP -Port 22 -InformationLevel Quiet
        if ($SSHTest) {
            Write-LogMessage "[OK] SSH connectivity to ${ServerName}: Success" "SUCCESS"
            $ValidationResults.system_validation["connectivity_$ServerName"] = $true
        } else {
            Write-LogMessage "[ERROR] SSH connectivity to ${ServerName}: Failed" "ERROR"
            $ValidationResults.system_validation["connectivity_$ServerName"] = $false
            $ValidationResults.errors += "SSH connectivity failed to $ServerName ($ServerIP)"
        }
    } catch {
        Write-LogMessage "[ERROR] Error testing SSH connectivity to ${ServerName}: $_" "ERROR"
        $ValidationResults.system_validation["connectivity_$ServerName"] = $false
        $ValidationResults.errors += "Error testing SSH connectivity to ${ServerName}: $_"
    }
}

# Final validation summary
Write-LogMessage "[SUMMARY] Validation Summary"
Write-LogMessage "Total Sites: $($ValidationResults.total_sites)"
Write-LogMessage "Errors: $($ValidationResults.errors.Count)"
Write-LogMessage "Warnings: $($ValidationResults.warnings.Count)"

if ($ValidationResults.errors.Count -eq 0) {
    $ValidationResults.validation_passed = $true
    Write-LogMessage "[SUCCESS] All validations passed! Ready for migration automation." "SUCCESS"
    $ExitCode = 0
} else {
    $ValidationResults.validation_passed = $false
    Write-LogMessage "[ERROR] Validation failed with $($ValidationResults.errors.Count) errors:" "ERROR"
    foreach ($Error in $ValidationResults.errors) {
        Write-LogMessage "   - $Error" "ERROR"
    }
    $ExitCode = 1
}

# Save validation results
$ResultsFile = Join-Path $ReportsDir "validation-results.json"
$ValidationResults | ConvertTo-Json -Depth 5 | Out-File -FilePath $ResultsFile

Write-LogMessage "[SAVED] Validation results saved to: $ResultsFile"
Write-LogMessage "[SAVED] Detailed log saved to: $LogFile"

exit $ExitCode