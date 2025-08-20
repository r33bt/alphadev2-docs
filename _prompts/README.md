### 4. Fix README.md (simplified version)
```powershell
@'
# AlphaDev2 Prompt Management System

**Purpose**: Centralized prompt templates and context for efficient development workflow
**Created**: 2025-08-17
**Environment**: AlphaDev2 Windows Development Setup

## 🚀 **Quick Start Guide**

### **For New Projects with GenSpark AI**
1. Upload `MASTER_REFERENCE.md` + `claude.md` 
2. Add specific context from relevant project-type file
3. Start conversation with complete context

### **For WordPress Migration**
1. Upload: `MASTER_REFERENCE.md` + `claude.md` + `wordpress-migration.md` (when created)
2. Specify domain name in request
3. Request step-by-step migration guidance

## 🎯 **Usage Philosophy**

**Goal**: Never repeat the same context or explanations
**Method**: Upload comprehensive context files at conversation start
**Benefit**: AI assistants have full understanding immediately

### **Before This System**Okay, I'm gonna paste for you each of these four files, the content in them. Can you please double-check? So the first is the README. 
- ❌ Repeating same setup explanations every conversation
- ❌ Inconsistent context leading to suboptimal advice
- ❌ Time wasted on basic environment setup discussions

### **With This System**
- ✅ Upload files for instant complete context
- ✅ AI assistants understand your full environment
- ✅ Focus on actual problem-solving, not setup explanation

## 🔐 **Security Notes**

**Safe to Include**:
- ✅ File paths and directory structures
- ✅ Service names and general configuration patterns
- ✅ Workflow descriptions and process steps

**Never Include**:
- ❌ Actual API keys or tokens
- ❌ Real passwords or credentials
- ❌ Private SSH keys

**Reference Pattern**: Always reference credential file locations, never expose actual values.
'@ | Out-File -FilePath "README.md" -Encoding UTF8