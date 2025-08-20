# Bulk Turnstile Widget Creation Script
# Creates Turnstile widgets for all migration sites using Cloudflare API

param(
    [string]$ApiToken = "z0t1ykIPcEnaBytb_g3ULT6O_630QP5DxH9AzNfT",
    [string]$CsvPath = "..\..\SSH\gridpane-sites-corrected.csv",
    [string]$OutputFile = "turnstile-keys.csv"
)

# Cloudflare API configuration
$Headers = @{
    "Authorization" = "Bearer $ApiToken"
    "Content-Type" = "application/json"
}

# First, get account ID
Write-Host "Getting Cloudflare account ID..."
try {
    $AccountResponse = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/accounts" -Headers $Headers -Method GET
    if ($AccountResponse.success) {
        $AccountId = $AccountResponse.result[0].id
        Write-Host "Account ID: $AccountId"
    } else {
        throw "Failed to get account ID: $($AccountResponse.errors)"
    }
} catch {
    Write-Error "Error getting account ID: $_"
    exit 1
}

# Read sites from CSV
Write-Host "Reading sites from CSV..."
$Sites = Import-Csv -Path $CsvPath
$MigratedSites = $Sites | Where-Object { $_.VERCEL_PROJECT -ne "" -and $_.MIGRATION_STATUS -like "*Migrated*" }

Write-Host "Found $($MigratedSites.Count) migrated sites to process"

# Results array
$Results = @()

# Process each migrated site
foreach ($Site in $MigratedSites) {
    $Domain = $Site.DOMAIN
    $VercelUrl = $Site.VERCEL_URL
    
    Write-Host "Creating Turnstile widget for $Domain..."
    
    # Prepare domains for this site
    $Domains = @($Domain)
    if ($VercelUrl -and $VercelUrl -ne "") {
        $VercelDomain = ($VercelUrl -replace "https://", "")
        $Domains += $VercelDomain
    }
    
    # Add staging domain
    $StagingDomain = "staging.$Domain"
    $Domains += $StagingDomain
    
    # Widget name
    $WidgetName = "$Domain Contact Form"
    
    # API request body
    $Body = @{
        name = $WidgetName
        domains = $Domains
        mode = "managed"
    } | ConvertTo-Json -Depth 3
    
    try {
        # Create Turnstile widget
        $Response = Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/accounts/$AccountId/challenges/widgets" -Headers $Headers -Method POST -Body $Body
        
        if ($Response.success) {
            $SiteKey = $Response.result.sitekey
            $SecretKey = $Response.result.secret
            
            Write-Host "Success: $Domain"
            Write-Host "   Site Key: $SiteKey"
            Write-Host "   Secret Key: $SecretKey"
            
            # Add to results
            $Results += [PSCustomObject]@{
                Domain = $Domain
                VercelUrl = $VercelUrl
                VercelProject = $Site.VERCEL_PROJECT
                SiteKey = $SiteKey
                SecretKey = $SecretKey
                Domains = ($Domains -join ", ")
                Status = "Success"
                Error = ""
            }
        } else {
            $ErrorMsg = ($Response.errors | ForEach-Object { "$($_.code): $($_.message)" }) -join "; "
            Write-Warning "Failed: $Domain - $ErrorMsg"
            
            $Results += [PSCustomObject]@{
                Domain = $Domain
                VercelUrl = $VercelUrl
                VercelProject = $Site.VERCEL_PROJECT
                SiteKey = ""
                SecretKey = ""
                Domains = ($Domains -join ", ")
                Status = "Failed"
                Error = $ErrorMsg
            }
        }
    } catch {
        Write-Error "Exception for $Domain`: $_"
        
        $Results += [PSCustomObject]@{
            Domain = $Domain
            VercelUrl = $VercelUrl
            VercelProject = $Site.VERCEL_PROJECT
            SiteKey = ""
            SecretKey = ""
            Domains = ($Domains -join ", ")
            Status = "Exception"
            Error = $_.Exception.Message
        }
    }
    
    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 500
}

# Export results to CSV
$Results | Export-Csv -Path $OutputFile -NoTypeInformation
Write-Host "Results exported to: $OutputFile"

# Summary
$SuccessCount = ($Results | Where-Object { $_.Status -eq "Success" }).Count
$TotalCount = $Results.Count

Write-Host ""
Write-Host "SUMMARY"
Write-Host "========"
Write-Host "Total Sites Processed: $TotalCount"
Write-Host "Successful: $SuccessCount"
Write-Host "Failed: $($TotalCount - $SuccessCount)"
Write-Host ""

if ($SuccessCount -gt 0) {
    Write-Host "Turnstile widgets created successfully!"
    Write-Host "Next steps:"
    Write-Host "1. Review $OutputFile for all site keys"
    Write-Host "2. Configure environment variables for each site"
    Write-Host "3. Deploy contact forms to all sites"
} else {
    Write-Host "No widgets were created successfully. Please check errors above."
}

# Display first few successful results for quick reference
$SuccessfulResults = $Results | Where-Object { $_.Status -eq "Success" } | Select-Object -First 3
if ($SuccessfulResults) {
    Write-Host ""
    Write-Host "Sample Keys (first 3 sites):"
    Write-Host "================================"
    foreach ($Result in $SuccessfulResults) {
        Write-Host "$($Result.Domain):"
        Write-Host "  NEXT_PUBLIC_TURNSTILE_SITE_KEY=$($Result.SiteKey)"
        Write-Host "  TURNSTILE_SECRET_KEY=$($Result.SecretKey)"
        Write-Host ""
    }
}