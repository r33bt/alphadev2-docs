# WordPress Content Audit Script
# Analyzes content structure and complexity for migration planning
# Usage: ./02-content-audit.ps1 -BatchFile "sites-to-migrate.csv" [-Parallel]

param(
    [Parameter(Mandatory=$true)]
    [string]$BatchFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$Parallel,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxParallelJobs = 5
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogDir = Join-Path $ScriptDir "logs"
$ReportsDir = Join-Path $ScriptDir "reports"

# Initialize logging
$LogFile = Join-Path $LogDir "02-content-audit-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$ResultsFile = Join-Path $LogDir "script2-results.json"
$AuditReportFile = Join-Path $ReportsDir "content-audit-summary.csv"

function Write-LogMessage {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Write-Host $LogEntry
    $LogEntry | Out-File -FilePath $LogFile -Append
}

function Test-WordPressAPIEndpoint {
    param(
        [string]$Domain,
        [string]$Endpoint
    )
    
    $URL = "https://staging.$Domain/wp-json/wp/v2/$Endpoint"
    
    try {
        $Response = Invoke-RestMethod -Uri $URL -TimeoutSec 30 -ErrorAction Stop
        return @{ "success" = $true; "data" = $Response; "count" = $Response.Count }
    } catch {
        $StatusCode = $_.Exception.Response.StatusCode.value__
        if ($StatusCode) {
            Write-LogMessage "⚠️ API endpoint $Endpoint returned status $StatusCode for $Domain" "WARNING"
            return @{ "success" = $false; "error" = "HTTP $StatusCode"; "count" = 0 }
        } else {
            Write-LogMessage "❌ API endpoint $Endpoint failed for $Domain`: $($_.Exception.Message)" "ERROR"
            return @{ "success" = $false; "error" = $_.Exception.Message; "count" = 0 }
        }
    }
}

function Get-ContentAnalysis {
    param([string]$Domain)
    
    Write-LogMessage "🔍 Analyzing content for $Domain"
    
    $Analysis = @{
        "domain" = $Domain
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "api_accessible" = $false
        "posts" = @{
            "total_count" = 0
            "published_count" = 0
            "draft_count" = 0
            "sample_posts" = @()
        }
        "pages" = @{
            "total_count" = 0
            "published_count" = 0
            "sample_pages" = @()
        }
        "categories" = @{
            "total_count" = 0
            "non_empty_count" = 0
            "categories_list" = @()
        }
        "tags" = @{
            "total_count" = 0
            "used_tags_count" = 0
        }
        "media" = @{
            "total_count" = 0
            "large_files_count" = 0
        }
        "custom_post_types" = @()
        "migration_complexity" = "Unknown"
        "estimated_migration_time" = "Unknown"
        "potential_issues" = @()
        "recommendations" = @()
    }
    
    try {
        # Test basic API accessibility
        Write-LogMessage "Testing WordPress REST API accessibility for $Domain"
        $BasicTest = Test-WordPressAPIEndpoint -Domain $Domain -Endpoint "posts?per_page=1"
        
        if (-not $BasicTest.success) {
            Write-LogMessage "❌ WordPress REST API not accessible for $Domain" "ERROR"
            $Analysis.potential_issues += "WordPress REST API not accessible"
            return $Analysis
        }
        
        $Analysis.api_accessible = $true
        Write-LogMessage "✅ WordPress REST API accessible for $Domain"
        
        # Analyze Posts
        Write-LogMessage "Analyzing posts for $Domain"
        
        # Get total post count
        $PostsResult = Test-WordPressAPIEndpoint -Domain $Domain -Endpoint "posts?per_page=100&status=any"
        if ($PostsResult.success -and $PostsResult.data) {
            $AllPosts = $PostsResult.data
            $Analysis.posts.total_count = $AllPosts.Count
            $Analysis.posts.published_count = ($AllPosts | Where-Object { $_.status -eq "publish" }).Count
            $Analysis.posts.draft_count = ($AllPosts | Where-Object { $_.status -eq "draft" }).Count
            
            # Get sample posts for URL structure analysis
            $SamplePosts = $AllPosts | Select-Object -First 5 | ForEach-Object {
                @{
                    "id" = $_.id
                    "title" = $_.title.rendered
                    "slug" = $_.slug
                    "status" = $_.status
                    "date" = $_.date
                    "categories" = $_.categories
                    "tags" = $_.tags
                }
            }
            $Analysis.posts.sample_posts = $SamplePosts
            
            Write-LogMessage "📊 Posts analysis: Total=$($Analysis.posts.total_count), Published=$($Analysis.posts.published_count), Drafts=$($Analysis.posts.draft_count)"
        }
        
        # Analyze Pages
        Write-LogMessage "Analyzing pages for $Domain"
        
        $PagesResult = Test-WordPressAPIEndpoint -Domain $Domain -Endpoint "pages?per_page=100&status=any"
        if ($PagesResult.success -and $PagesResult.data) {
            $AllPages = $PagesResult.data
            $Analysis.pages.total_count = $AllPages.Count
            $Analysis.pages.published_count = ($AllPages | Where-Object { $_.status -eq "publish" }).Count
            
            # Get sample pages for URL structure analysis
            $SamplePages = $AllPages | Select-Object -First 5 | ForEach-Object {
                @{
                    "id" = $_.id
                    "title" = $_.title.rendered
                    "slug" = $_.slug
                    "status" = $_.status
                    "parent" = $_.parent
                    "date" = $_.date
                }
            }
            $Analysis.pages.sample_pages = $SamplePages
            
            Write-LogMessage "📊 Pages analysis: Total=$($Analysis.pages.total_count), Published=$($Analysis.pages.published_count)"
        }
        
        # Analyze Categories
        Write-LogMessage "Analyzing categories for $Domain"
        
        $CategoriesResult = Test-WordPressAPIEndpoint -Domain $Domain -Endpoint "categories?per_page=100"
        if ($CategoriesResult.success -and $CategoriesResult.data) {
            $AllCategories = $CategoriesResult.data
            $Analysis.categories.total_count = $AllCategories.Count
            $NonEmptyCategories = $AllCategories | Where-Object { $_.count -gt 0 }
            $Analysis.categories.non_empty_count = $NonEmptyCategories.Count
            
            # Store category details for migration planning
            $CategoryList = $AllCategories | ForEach-Object {
                @{
                    "id" = $_.id
                    "name" = $_.name
                    "slug" = $_.slug
                    "count" = $_.count
                    "parent" = $_.parent
                }
            }
            $Analysis.categories.categories_list = $CategoryList
            
            Write-LogMessage "📊 Categories analysis: Total=$($Analysis.categories.total_count), Non-empty=$($Analysis.categories.non_empty_count)"
        }
        
        # Analyze Tags
        Write-LogMessage "Analyzing tags for $Domain"
        
        $TagsResult = Test-WordPressAPIEndpoint -Domain $Domain -Endpoint "tags?per_page=100"
        if ($TagsResult.success -and $TagsResult.data) {
            $AllTags = $TagsResult.data
            $Analysis.tags.total_count = $AllTags.Count
            $UsedTags = $AllTags | Where-Object { $_.count -gt 0 }
            $Analysis.tags.used_tags_count = $UsedTags.Count
            
            Write-LogMessage "📊 Tags analysis: Total=$($Analysis.tags.total_count), Used=$($Analysis.tags.used_tags_count)"
        }
        
        # Analyze Media (basic count)
        Write-LogMessage "Analyzing media for $Domain"
        
        $MediaResult = Test-WordPressAPIEndpoint -Domain $Domain -Endpoint "media?per_page=100"
        if ($MediaResult.success -and $MediaResult.data) {
            $AllMedia = $MediaResult.data
            $Analysis.media.total_count = $AllMedia.Count
            
            # Check for potentially large files (>1MB)
            $LargeFiles = $AllMedia | Where-Object { 
                $_.media_details -and 
                $_.media_details.filesize -and 
                $_.media_details.filesize -gt 1048576 
            }
            $Analysis.media.large_files_count = $LargeFiles.Count
            
            Write-LogMessage "📊 Media analysis: Total=$($Analysis.media.total_count), Large files (>1MB)=$($Analysis.media.large_files_count)"
        }
        
        # Determine migration complexity
        $TotalContent = $Analysis.posts.total_count + $Analysis.pages.total_count
        $ComplexFactors = 0
        
        if ($TotalContent -gt 100) { $ComplexFactors++ }
        if ($Analysis.categories.total_count -gt 20) { $ComplexFactors++ }
        if ($Analysis.media.total_count -gt 50) { $ComplexFactors++ }
        if ($Analysis.media.large_files_count -gt 10) { $ComplexFactors++ }
        
        switch ($ComplexFactors) {
            0 { $Analysis.migration_complexity = "Simple"; $Analysis.estimated_migration_time = "15-20 minutes" }
            1 { $Analysis.migration_complexity = "Simple"; $Analysis.estimated_migration_time = "20-25 minutes" }
            2 { $Analysis.migration_complexity = "Medium"; $Analysis.estimated_migration_time = "25-35 minutes" }
            3 { $Analysis.migration_complexity = "Medium"; $Analysis.estimated_migration_time = "35-45 minutes" }
            default { $Analysis.migration_complexity = "Complex"; $Analysis.estimated_migration_time = "45+ minutes" }
        }
        
        # Generate recommendations
        if ($Analysis.posts.total_count -eq 0 -and $Analysis.pages.total_count -eq 0) {
            $Analysis.potential_issues += "No published content found"
            $Analysis.recommendations += "Verify content exists and is published"
        }
        
        if ($Analysis.categories.non_empty_count -eq 0 -and $Analysis.posts.total_count -gt 0) {
            $Analysis.potential_issues += "Posts exist but no categories are used"
            $Analysis.recommendations += "Review category structure for better organization"
        }
        
        if ($Analysis.media.large_files_count -gt 20) {
            $Analysis.potential_issues += "Many large media files detected"
            $Analysis.recommendations += "Consider media optimization before migration"
        }
        
        if ($Analysis.pages.total_count -gt 50) {
            $Analysis.potential_issues += "Large number of pages may require URL mapping"
            $Analysis.recommendations += "Prepare comprehensive URL redirect strategy"
        }
        
        Write-LogMessage "✅ Content analysis completed for $Domain (Complexity: $($Analysis.migration_complexity))"
        
    } catch {
        Write-LogMessage "❌ Error analyzing content for $Domain`: $_" "ERROR"
        $Analysis.potential_issues += "Content analysis failed: $($_.Exception.Message)"
    }
    
    return $Analysis
}

# Main execution
Write-LogMessage "🚀 Starting WordPress Content Audit"
Write-LogMessage "Batch File: $BatchFile"

# Load sites
if (-not (Test-Path $BatchFile)) {
    Write-LogMessage "❌ Batch file not found: $BatchFile" "ERROR"
    exit 1
}

$Sites = Import-Csv $BatchFile
Write-LogMessage "📊 Analyzing $($Sites.Count) sites"

# Initialize results
$Results = @{
    "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "total_sites" = $Sites.Count
    "completed_audits" = @()
    "failed_audits" = @()
    "site_analyses" = @{}
    "summary_statistics" = @{
        "total_posts" = 0
        "total_pages" = 0
        "total_categories" = 0
        "complexity_distribution" = @{
            "Simple" = 0
            "Medium" = 0
            "Complex" = 0
        }
    }
}

$AuditData = @()

# Process sites
if ($Parallel -and $Sites.Count -gt 1) {
    Write-LogMessage "🔄 Processing sites in parallel (Max jobs: $MaxParallelJobs)"
    
    $Jobs = @()
    $SiteChunks = @()
    
    # Split sites into chunks for parallel processing
    $ChunkSize = [Math]::Ceiling($Sites.Count / $MaxParallelJobs)
    for ($i = 0; $i -lt $Sites.Count; $i += $ChunkSize) {
        $Chunk = $Sites[$i..[Math]::Min($i + $ChunkSize - 1, $Sites.Count - 1)]
        $SiteChunks += ,$Chunk
    }
    
    # Start parallel jobs
    foreach ($Chunk in $SiteChunks) {
        $Job = Start-Job -ScriptBlock {
            param($SiteChunk, $ScriptPath)
            
            # Import the analysis function
            . $ScriptPath
            
            $ChunkResults = @()
            foreach ($Site in $SiteChunk) {
                $Analysis = Get-ContentAnalysis -Domain $Site.Domain
                $ChunkResults += $Analysis
            }
            return $ChunkResults
        } -ArgumentList $Chunk, $PSCommandPath
        
        $Jobs += $Job
    }
    
    # Wait for all jobs to complete and collect results
    foreach ($Job in $Jobs) {
        $JobResults = Receive-Job -Job $Job -Wait
        foreach ($Analysis in $JobResults) {
            $Domain = $Analysis.domain
            $Results.site_analyses[$Domain] = $Analysis
            
            if ($Analysis.api_accessible) {
                $Results.completed_audits += $Domain
                $Results.summary_statistics.total_posts += $Analysis.posts.total_count
                $Results.summary_statistics.total_pages += $Analysis.pages.total_count
                $Results.summary_statistics.total_categories += $Analysis.categories.total_count
                $Results.summary_statistics.complexity_distribution[$Analysis.migration_complexity]++
            } else {
                $Results.failed_audits += $Domain
            }
            
            # Prepare data for CSV report
            $AuditRow = [PSCustomObject]@{
                Domain = $Analysis.domain
                API_Accessible = $Analysis.api_accessible
                Total_Posts = $Analysis.posts.total_count
                Published_Posts = $Analysis.posts.published_count
                Total_Pages = $Analysis.pages.total_count
                Published_Pages = $Analysis.pages.published_count
                Total_Categories = $Analysis.categories.total_count
                Non_Empty_Categories = $Analysis.categories.non_empty_count
                Total_Tags = $Analysis.tags.total_count
                Used_Tags = $Analysis.tags.used_tags_count
                Media_Files = $Analysis.media.total_count
                Large_Media_Files = $Analysis.media.large_files_count
                Migration_Complexity = $Analysis.migration_complexity
                Estimated_Time = $Analysis.estimated_migration_time
                Potential_Issues = ($Analysis.potential_issues -join "; ")
                Recommendations = ($Analysis.recommendations -join "; ")
                Audit_Timestamp = $Analysis.timestamp
            }
            $AuditData += $AuditRow
        }
        Remove-Job -Job $Job
    }
    
} else {
    # Sequential processing
    Write-LogMessage "🔄 Processing sites sequentially"
    
    foreach ($Site in $Sites) {
        $Domain = $Site.Domain
        $Analysis = Get-ContentAnalysis -Domain $Domain
        
        $Results.site_analyses[$Domain] = $Analysis
        
        if ($Analysis.api_accessible) {
            $Results.completed_audits += $Domain
            $Results.summary_statistics.total_posts += $Analysis.posts.total_count
            $Results.summary_statistics.total_pages += $Analysis.pages.total_count
            $Results.summary_statistics.total_categories += $Analysis.categories.total_count
            $Results.summary_statistics.complexity_distribution[$Analysis.migration_complexity]++
        } else {
            $Results.failed_audits += $Domain
        }
        
        # Prepare data for CSV report
        $AuditRow = [PSCustomObject]@{
            Domain = $Analysis.domain
            API_Accessible = $Analysis.api_accessible
            Total_Posts = $Analysis.posts.total_count
            Published_Posts = $Analysis.posts.published_count
            Total_Pages = $Analysis.pages.total_count
            Published_Pages = $Analysis.pages.published_pages
            Total_Categories = $Analysis.categories.total_count
            Non_Empty_Categories = $Analysis.categories.non_empty_count
            Total_Tags = $Analysis.tags.total_count
            Used_Tags = $Analysis.tags.used_tags_count
            Media_Files = $Analysis.media.total_count
            Large_Media_Files = $Analysis.media.large_files_count
            Migration_Complexity = $Analysis.migration_complexity
            Estimated_Time = $Analysis.estimated_migration_time
            Potential_Issues = ($Analysis.potential_issues -join "; ")
            Recommendations = ($Analysis.recommendations -join "; ")
            Audit_Timestamp = $Analysis.timestamp
        }
        $AuditData += $AuditRow
    }
}

# Generate summary report
Write-LogMessage "📋 Content Audit Summary"
Write-LogMessage "Total Sites: $($Sites.Count)"
Write-LogMessage "Successful Audits: $($Results.completed_audits.Count)"
Write-LogMessage "Failed Audits: $($Results.failed_audits.Count)"
Write-LogMessage "Total Posts Across All Sites: $($Results.summary_statistics.total_posts)"
Write-LogMessage "Total Pages Across All Sites: $($Results.summary_statistics.total_pages)"
Write-LogMessage "Total Categories Across All Sites: $($Results.summary_statistics.total_categories)"

Write-LogMessage "Migration Complexity Distribution:"
foreach ($Complexity in $Results.summary_statistics.complexity_distribution.Keys) {
    $Count = $Results.summary_statistics.complexity_distribution[$Complexity]
    Write-LogMessage "   $Complexity`: $Count sites"
}

if ($Results.failed_audits.Count -gt 0) {
    Write-LogMessage "❌ Failed audits:" "ERROR"
    foreach ($FailedSite in $Results.failed_audits) {
        Write-LogMessage "   - $FailedSite" "ERROR"
    }
}

# Save results
$Results | ConvertTo-Json -Depth 5 | Out-File -FilePath $ResultsFile

# Export CSV report
$AuditData | Export-Csv -Path $AuditReportFile -NoTypeInformation

Write-LogMessage "📄 Results saved to: $ResultsFile"
Write-LogMessage "📄 CSV report saved to: $AuditReportFile"
Write-LogMessage "📄 Log file: $LogFile"

if ($Results.failed_audits.Count -eq 0) {
    Write-LogMessage "🎉 All content audits completed successfully!" "SUCCESS"
    exit 0
} else {
    Write-LogMessage "⚠️ Some audits failed. Check logs for details." "WARNING"
    exit 1
}