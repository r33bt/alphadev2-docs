param(
    [Parameter(Mandatory=$true)]
    [string]$Decision
)

$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$devLogFile = "readme-development-log.md"

# Read all lines
$lines = Get-Content $devLogFile

# Find the "RECENT ACTIVITY" section (should be near the top)
$insertIndex = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "RECENT ACTIVITY.*Newest First") {
        $insertIndex = $i + 2  # Insert after the section header and blank line
        break
    }
}

if ($insertIndex -ne -1) {
    # Create new entry to insert at the top
    $newEntry = @(
        "",
        "### $timestamp",
        "$Decision",
        ""
    )
    
    # Insert new entry at the top of the recent activity section
    $newLines = $lines[0..($insertIndex-1)] + $newEntry + $lines[$insertIndex..($lines.Count-1)]
    
    # Write back to file
    $newLines | Out-File -FilePath $devLogFile -Encoding UTF8
    
    Write-Host "✅ Progress logged to Development Log: $Decision" -ForegroundColor Green
} else {
    Write-Host "❌ Could not find RECENT ACTIVITY section" -ForegroundColor Red
}
