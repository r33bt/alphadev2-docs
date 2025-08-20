# AI Context Management Functions
Write-Host "🤖 AI Context Management loaded! Commands: ai-scan, ai-context, ai-restore, ai-log, ai-update" -ForegroundColor Green

function ai-log {
    param([string]$Message)
    & ".ai-context\scripts\log-decision.ps1" $Message
}

function ai-scan {
    & ".ai-context\scripts\scan-project.ps1"
}

function ai-update {
    ai-log "Context update checkpoint"
    & ".ai-context\scripts\scan-project.ps1"
    & ".ai-context\scripts\generate-context.ps1" -Type 'update'
}

function ai-restore {
    & ".ai-context\scripts\generate-context.ps1"
}

function Generate-ProjectReadme {
    param([string]$ProjectName = (Split-Path (Get-Location) -Leaf))
    
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    $readmeFileName = "README-$ProjectName-$dateStamp.md"
    
    Write-Host "📝 Generating $readmeFileName..." -ForegroundColor Yellow
    
    $content = "# $ProjectName Project`n`n"
    $content += "*Auto-generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*`n"
    $content += "*Powered by AI Context Preservation System*`n`n"
    $content += "## Project Overview`n"
    $content += "**Project**: $ProjectName`n"
    $content += "**Location**: $(Get-Location)`n`n"
    $content += "## AI Context System`n"
    $content += "- Use ``ai-log 'message'`` to track progress`n"
    $content += "- Use ``ai-restore`` for AI conversation recovery`n`n"
    $content += "---`n"
    $content += "*Generated as: $readmeFileName*"
    
    $content | Out-File -FilePath $readmeFileName -Encoding UTF8
    Write-Host "✅ Generated $readmeFileName" -ForegroundColor Green
}

function Initialize-AIContext {
    param([string]$ProjectName = (Split-Path (Get-Location) -Leaf))
    
    Write-Host "🚀 Initializing AI Context for '$ProjectName' project..." -ForegroundColor Yellow
    
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    
    # Enhanced filenames
    $devLogFileName = "readme-development-log-$ProjectName-$dateStamp.md"
    $faqFileName = "SYSTEM-FAQ-$ProjectName-$dateStamp.md"
    
    # Create development log
    $devLogContent = "# $ProjectName Project - AI Context Log`n*Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*`n`n## 🔄 **RECENT ACTIVITY** (Newest First)`n`n"
    $devLogContent | Out-File -FilePath $devLogFileName -Encoding UTF8
    Write-Host "✅ Created $devLogFileName" -ForegroundColor Green
    
    # Copy SYSTEM-FAQ
    $sourcePath = "C:\Users\user\alphadev2\ai-context-system"
    if (Test-Path "$sourcePath\SYSTEM-FAQ.md") {
        Copy-Item "$sourcePath\SYSTEM-FAQ.md" -Destination $faqFileName
        Write-Host "✅ Created $faqFileName" -ForegroundColor Green
    }
    
    # Generate project README
    Generate-ProjectReadme $ProjectName
    
    Write-Host "🎉 Enhanced initialization complete!" -ForegroundColor Green
}

function Deploy-AIContextSystem {
    $projectName = Split-Path (Get-Location) -Leaf
    $aiDir = "AI-Context-System-$projectName"
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    
    Write-Host "🚀 Creating organized AI Context System for: $projectName" -ForegroundColor Cyan
    
    # Create the organized directory
    New-Item -ItemType Directory -Path $aiDir -Force | Out-Null
    Write-Host "✅ Created directory: $aiDir" -ForegroundColor Green
    
    # Copy .ai-context folder into organized directory  
    Copy-Item "C:\Users\user\alphadev2\ai-context-system\.ai-context" -Destination "$aiDir\.ai-context" -Recurse -Force
    Write-Host "✅ Copied .ai-context system" -ForegroundColor Green
    
    # Create the three organized files
    "# $projectName Project - AI Context Log" | Out-File -FilePath "$aiDir\readme-development-log-$projectName-$dateStamp.md" -Encoding UTF8
    Copy-Item "C:\Users\user\alphadev2\ai-context-system\SYSTEM-FAQ.md" -Destination "$aiDir\SYSTEM-FAQ-$projectName-$dateStamp.md"
    "# $projectName Project" | Out-File -FilePath "$aiDir\README-$projectName-$dateStamp.md" -Encoding UTF8
    Write-Host "✅ Created organized documentation files" -ForegroundColor Green
    
    Write-Host "🎯 Organized deployment complete: $aiDir" -ForegroundColor Magenta
}
