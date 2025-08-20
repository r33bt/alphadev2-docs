param([string]$Type = 'full')

function Generate-FullContext {
    Write-Host "Generating full AI context..." -ForegroundColor Yellow
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $workingDir = Get-Location
    
    $context = @"
# Complete AI Context Restore Package
*Generated: $timestamp*
*Working Directory: $workingDir*

---

## 🤖 AI INSTRUCTIONS (READ FIRST)
$(if (Test-Path '.ai-context\genspark-rules.md') { Get-Content '.ai-context\genspark-rules.md' -Raw } else { "AI rules file not found" })

---

## 📍 QUICK NAVIGATION FOR NEW AI
**Project Location**: C:\Users\user\alphadev2\ai-context-system\

**Essential Files to Reference**:
- readme-ai-context-system.md - Complete system documentation
- readme-development-log.md - Latest development activity (CHECK FIRST!)
- QUICK-REFERENCE.md - Command reference
- .ai-context\genspark-rules.md - AI behavior guidelines (includes logging workflow)

**Load System Functions**: . .ai-context\powershell-functions.ps1

**Core Commands**:
- ai-log "message" - Log development progress
- ai-update - Refresh context for conversation recovery
- ai-restore - Display context for new AI chat

**For Logging**: Ask me to analyze our conversation and suggest an ai-log entry with file paths and technical details.

**For More Details**: Ask me to show contents of any specific file above.

---

## 📋 CURRENT PROJECT STATE
$(if (Test-Path '.ai-context\project-state.md') { Get-Content '.ai-context\project-state.md' -Raw } else { "Project state file not found" })

---

## 🔄 LATEST DEVELOPMENT ACTIVITY (CRITICAL - MOST RECENT WORK)
$(if (Test-Path 'readme-development-log.md') { 
    # Get the recent activity section from development log
    $devLog = Get-Content 'readme-development-log.md' -Raw
    $recentSection = ($devLog -split '## 🔄 \*\*RECENT ACTIVITY\*\*')[1]
    if ($recentSection) {
        $recentSection = ($recentSection -split '## 📚 \*\*PROJECT MILESTONES\*\*')[0]
        "## 🔄 **RECENT DEVELOPMENT ACTIVITY**" + $recentSection
    } else {
        "No recent development activity found"
    }
} else { "Development log not found" })

---

## 🏗️ TECHNICAL SNAPSHOT
$(if (Test-Path '.ai-context\latest-scan.md') { Get-Content '.ai-context\latest-scan.md' -Raw } else { "Run ai-scan to generate technical snapshot" })

---

## 🚀 READY TO ASSIST - CONTEXT RESTORED
I now have complete context of the AI Context Preservation System project including:
- Latest development activity and recent decisions
- Current project state and technical details
- All system components and their status
- Enhanced logging workflow for comprehensive tracking

Generate PowerShell commands for Windows development environment.
Continue from where the latest development log entries left off.

**For Logging Recent Work**: Ask me to analyze our conversation and create a comprehensive ai-log entry with file paths and technical details.

"@

    $context | Out-File -FilePath '.ai-context\current-context.md' -Encoding utf8
    Write-Host "✅ Full context generated with enhanced logging guidance" -ForegroundColor Green
}

switch ($Type) {
    'full' { Generate-FullContext }
    'update' { 
        & '.ai-context\scripts\scan-project.ps1'
        Generate-FullContext 
    }
}
