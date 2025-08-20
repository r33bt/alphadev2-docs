# AI Assistant Instructions

## Project Context
This is the AI Context Preservation System - a meta-project that creates tools to solve AI context loss during conversation compacting.

## Development Environment
- **OS**: Windows PC
- **Terminal**: PowerShell
- **Project Location**: C:\Users\user\alphadev2\ai-context-system\
- **Purpose**: Create PowerShell scripts for AI context management

## Code Generation Guidelines
- Generate PowerShell commands for Windows environment
- Provide complete, copy-pasteable command blocks
- Focus on the AI context preservation system functionality

## Project Goal
Build a comprehensive system that allows developers to:
1. Preserve project knowledge across AI conversation resets
2. Quickly restore AI context with copy-paste workflows
3. Maintain development momentum despite context limitations

## CRITICAL: Logging Workflow for New Conversations

When the user asks to log recent work or says "log this" or similar:

### Step 1: Analyze the Conversation
**Identify**:
- Key accomplishments achieved
- Important decisions made
- Files created, modified, or enhanced (with full paths)
- Functions/scripts that were updated
- Problems solved or features implemented
- Current project status after the work

### Step 2: Generate Comprehensive Log Entry
**Format**: Create a concise but detailed summary (2-3 sentences max) including:
- **What was accomplished**: Main achievements
- **Technical details**: Files/functions modified
- **Impact**: How it improves the system
- **Status**: Current state after changes

### Step 3: Present the Command
**Always provide the exact PowerShell command**:
```powershell
ai-log "your comprehensive summary here"
Example Response Format:
Based on our conversation, here's what should be logged:

**Analysis**:
- Enhanced scan-project.ps1 with intelligent Next.js detection
- Modified generate-context.ps1 to include development log content  
- Updated project-state.md to reflect production-ready status
- Improved context restoration with recent activity prominence

**Files Modified**:
- .ai-context/scripts/scan-project.ps1
- .ai-context/scripts/generate-context.ps1  
- .ai-context/project-state.md

**Impact**: Context restoration now includes recent development activity and intelligent project scanning

**Recommended Log Entry**:
```powershell
ai-log "Enhanced project scanner with Next.js intelligence and integrated development log into context restoration - modified scan-project.ps1 and generate-context.ps1 - major improvement to context quality and project detection"

## Current Focus
The AI Context Preservation System is PRODUCTION READY. Focus on:
- System improvements and optimizations
- User experience enhancements  
- Documentation updates
- Testing and validation## 🚨 CRITICAL: Logging Workflow Trigger

When user says ANY of these phrases:
- "Help me create an ai-log entry"
- "Log this conversation" 
- "Analyze this for logging"
- "What should I log from this chat?"

### IMMEDIATE RESPONSE SEQUENCE:

**Step 1**: Show recent log entries for context
Show the last 3-5 entries from readme-development-log.md so user can see what was previously logged.

**Step 2**: Analyze current conversation and identify:
- Key accomplishments since last log
- Files created/modified (with full paths)  
- Functions/scripts enhanced
- Problems solved or decisions made
- Current status after this work

**Step 3**: Generate the exact ai-log command:
Present it as: ai-log "comprehensive summary with file paths and technical details"

**Example Response**:
"Based on our conversation, here's what should be logged:

**Recent Log Context**: [show last few entries]
**This Session Accomplished**: [analysis of current work]
**Files Modified**: [list with paths]
**Recommended Command**: ai-log 'your summary here'"



## 🚨 CRITICAL: Logging Workflow Trigger

When user says ANY of these phrases:
- "Help me create an ai-log entry"
- "Log this conversation"
- "Analyze this for logging"
- "What should I log from this chat?"

### IMMEDIATE RESPONSE SEQUENCE:

**Step 1**: Show recent log entries for context
**Step 2**: Analyze current conversation for accomplishments, files modified, decisions made
**Step 3**: Generate exact ai-log command with comprehensive summary

**Example Response Format**:
"Based on our conversation, here's what should be logged:
- Recent context: [last few log entries]
- This session: [accomplishments and files modified]
- Recommended: ai-log 'comprehensive summary with file paths'"


## 📋 README-Development Log Synchronization

### When analyzing conversations for logging, also check:

**README Impact Analysis**:
- Did this work complete any planned items? → Use ai-complete "item description"
- Did this work reveal new requirements? → Use ai-plan "new requirement"  
- Should project status be updated? → Use ai-readme-update "status change"

### Enhanced Logging Response Format:
When user says "Help me create an ai-log entry":

1. **Show recent context** (log entries + README updates)
2. **Analyze conversation** for accomplishments and files modified
3. **Check README implications** (completions, new plans, status changes)
4. **Suggest commands**:
   - ai-log "main progress entry"
   - ai-complete "completed item" (if applicable)
   - ai-plan "new requirement" (if applicable)
   - ai-readme-update "status change" (if applicable)

### Example Enhanced Response:
"Based on our conversation and README status:

**Recent Context**: [recent log + README updates]
**This Session**: [accomplishments and files]
**README Impact**: This completes the logging workflow implementation planned earlier

**Recommended Commands**:
`powershell
ai-log "Implemented non-destructive README update system with ai-plan, ai-complete, ai-readme-update functions - enhanced powershell-functions.ps1 and genspark-rules.md"
ai-complete "Enhanced logging workflow with comprehensive analysis"
ai-readme-update "System now includes bidirectional documentation synchronization"
`"

