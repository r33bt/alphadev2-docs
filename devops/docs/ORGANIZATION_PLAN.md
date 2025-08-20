# AlphaDev2 Development Environment Organization Plan

**Target Directory:** `C:\Users\user\alphadev2`  
**Date:** 2025-01-11  
**Status:** Implementation Phase

## Current Situation Analysis

Based on the user profile directory contents, the following development-related items have been identified:

### Configuration Folders (Hidden - Start with dot)
- `.cache` (12/9/2024) - General application cache
- `.chocolatey` (1/29/2025) - Chocolatey package manager cache  
- `.claude` (8/11/2025) - Claude AI configurations
- `.cursor` (4/28/2025) - Cursor AI editor settings
- `.cursor-tutor*` (9/6/2024) - Cursor tutorial materials (3 folders)
- `.docker` (9/7/2024) - Docker Desktop configurations
- `.matplotlib` (12/15/2024) - Python matplotlib library cache
- `.ScreamingFrogSEOSpider` (8/3/2024) - SEO tool cache
- `.ssh` (2/10/2025) - SSH keys and configurations ⚠️ **DO NOT MOVE**
- `.vscode` (7/28/2024) - Visual Studio Code settings
- `.wdm` (12/25/2024) - WebDriver Manager cache
- `.wp-cli` (1/30/2025) - WordPress CLI settings

### Development Projects
- `my-wordpress-site` (9/5/2024) - WordPress development project
- `Postman` (12/7/2024) - API development collections

### Configuration Files
- `.claude` (8/11/2025) - Claude configuration (12 KB)
- `.claude.json.backup` (8/11/2025) - Claude backup (2 KB)
- `.gitconfig` (1/14/2025) - Git configuration (1 KB)

## Directory Structure Created

```
alphadev2/
├── 📁 projects/                    # Active development projects
│   ├── web/                        # Web development projects
│   ├── mobile/                     # Mobile app projects
│   ├── desktop/                    # Desktop application projects
│   └── scripts/                    # Utility scripts and automation
├── 📁 tools/                       # Development tools
│   ├── utilities/                  # Development utilities
│   └── portable-apps/              # Portable development applications
├── 📁 cache/                       # Relocated cache folders
│   ├── chocolatey/                 # Chocolatey package cache
│   └── general/                    # Other application caches
├── 📁 config/                      # Configuration backups
│   └── backups/                    # Backed up configurations
├── 📁 resources/                   # Documentation and learning
│   ├── tutorials/                  # Tutorial materials
│   └── documentation/              # Development documentation
├── 📁 sandbox/                     # Temporary/experimental projects
└── 📁 installers/                  # Downloaded installer files
```

## File Move Plan & Commands

### Phase 1: Safe Moves (Can be done immediately)

#### Tutorial Materials
```powershell
# Move Cursor tutorial folders
Move-Item "C:\Users\user\.cursor-tutor" "C:\Users\user\alphadev2\resources\tutorials\cursor-tutor"
Move-Item "C:\Users\user\.cursor-tutor-1" "C:\Users\user\alphadev2\resources\tutorials\cursor-tutor-1"
Move-Item "C:\Users\user\.cursor-tutor-2" "C:\Users\user\alphadev2\resources\tutorials\cursor-tutor-2"
```

#### Cache Folders (Low Risk)
```powershell
# Move cacheable folders
Move-Item "C:\Users\user\.matplotlib" "C:\Users\user\alphadev2\cache\general\matplotlib"
Move-Item "C:\Users\user\.wdm" "C:\Users\user\alphadev2\cache\general\wdm"
Move-Item "C:\Users\user\.ScreamingFrogSEOSpider" "C:\Users\user\alphadev2\cache\general\ScreamingFrogSEOSpider"
```

#### Development Projects
```powershell
# Move development projects
Move-Item "C:\Users\user\my-wordpress-site" "C:\Users\user\alphadev2\projects\web\my-wordpress-site"
Move-Item "C:\Users\user\Postman" "C:\Users\user\alphadev2\tools\utilities\Postman"
```

### Phase 2: Configuration Backups (Backup first, then move)

```powershell
# Create backups before moving
Copy-Item "C:\Users\user\.vscode" "C:\Users\user\alphadev2\config\backups\vscode-backup" -Recurse
Copy-Item "C:\Users\user\.cursor" "C:\Users\user\alphadev2\config\backups\cursor-backup" -Recurse  
Copy-Item "C:\Users\user\.docker" "C:\Users\user\alphadev2\config\backups\docker-backup" -Recurse
Copy-Item "C:\Users\user\.wp-cli" "C:\Users\user\alphadev2\config\backups\wp-cli-backup" -Recurse
Copy-Item "C:\Users\user\.claude" "C:\Users\user\alphadev2\config\backups\claude-backup" -Recurse

# After verification, optionally move originals
# Move-Item "C:\Users\user\.vscode" "C:\Users\user\alphadev2\config\vscode"
# Move-Item "C:\Users\user\.cursor" "C:\Users\user\alphadev2\config\cursor"
```

### Phase 3: Cache Relocation with Configuration Updates

#### Chocolatey Cache
```powershell
# Check current cache location
choco config get cacheLocation

# Move cache folder
Move-Item "C:\Users\user\.chocolatey" "C:\Users\user\alphadev2\cache\chocolatey"

# Update Chocolatey configuration
choco config set cacheLocation "C:\Users\user\alphadev2\cache\chocolatey"
```

#### General Cache
```powershell
# Move general cache
Move-Item "C:\Users\user\.cache" "C:\Users\user\alphadev2\cache\general\app-cache"
```

## Safety Classifications

### ✅ SAFE TO MOVE
- `.cursor-tutor*` - Tutorial materials
- `.matplotlib` - Python library cache  
- `.wdm` - WebDriver cache
- `.ScreamingFrogSEOSpider` - SEO tool cache
- `my-wordpress-site` - Development project
- `Postman` - API collections

### ⚠️ BACKUP FIRST
- `.vscode` - IDE settings and extensions
- `.cursor` - AI editor configuration
- `.docker` - Container configurations
- `.wp-cli` - WordPress CLI settings  
- `.claude` - AI assistant settings
- `.chocolatey` - Package manager (needs config update)
- `.cache` - General application cache

### ❌ DO NOT MOVE
- `.ssh` - SSH keys (security risk)
- `.gitconfig` - Git global configuration (system-wide)

## Environment Variables Setup

```powershell
# Set development environment variables
[Environment]::SetEnvironmentVariable("ALPHADEV_ROOT", "C:\Users\user\alphadev2", "User")
[Environment]::SetEnvironmentVariable("ALPHADEV_PROJECTS", "C:\Users\user\alphadev2\projects", "User")
[Environment]::SetEnvironmentVariable("ALPHADEV_CACHE", "C:\Users\user\alphadev2\cache", "User")
[Environment]::SetEnvironmentVariable("ALPHADEV_CONFIG", "C:\Users\user\alphadev2\config", "User")
```

## Verification Checklist

After each move, verify:
- [ ] VS Code opens and shows extensions
- [ ] Cursor loads with AI functionality  
- [ ] Docker Desktop starts correctly
- [ ] Chocolatey installs packages
- [ ] WordPress CLI commands work
- [ ] SSH connections still function
- [ ] Claude AI responds correctly

## Complete Move Script

```powershell
# Execute all safe moves in sequence
Write-Host "Phase 1: Safe moves..." -ForegroundColor Green

# Tutorial materials
Move-Item "C:\Users\user\.cursor-tutor" "C:\Users\user\alphadev2\resources\tutorials\cursor-tutor" -ErrorAction SilentlyContinue
Move-Item "C:\Users\user\.cursor-tutor-1" "C:\Users\user\alphadev2\resources\tutorials\cursor-tutor-1" -ErrorAction SilentlyContinue  
Move-Item "C:\Users\user\.cursor-tutor-2" "C:\Users\user\alphadev2\resources\tutorials\cursor-tutor-2" -ErrorAction SilentlyContinue

# Cache folders
Move-Item "C:\Users\user\.matplotlib" "C:\Users\user\alphadev2\cache\general\matplotlib" -ErrorAction SilentlyContinue
Move-Item "C:\Users\user\.wdm" "C:\Users\user\alphadev2\cache\general\wdm" -ErrorAction SilentlyContinue
Move-Item "C:\Users\user\.ScreamingFrogSEOSpider" "C:\Users\user\alphadev2\cache\general\ScreamingFrogSEOSpider" -ErrorAction SilentlyContinue

# Development projects  
Move-Item "C:\Users\user\my-wordpress-site" "C:\Users\user\alphadev2\projects\web\my-wordpress-site" -ErrorAction SilentlyContinue
Move-Item "C:\Users\user\Postman" "C:\Users\user\alphadev2\tools\utilities\Postman" -ErrorAction SilentlyContinue

Write-Host "Phase 2: Configuration backups..." -ForegroundColor Yellow

# Create configuration backups
Copy-Item "C:\Users\user\.vscode" "C:\Users\user\alphadev2\config\backups\vscode-backup" -Recurse -ErrorAction SilentlyContinue
Copy-Item "C:\Users\user\.cursor" "C:\Users\user\alphadev2\config\backups\cursor-backup" -Recurse -ErrorAction SilentlyContinue
Copy-Item "C:\Users\user\.docker" "C:\Users\user\alphadev2\config\backups\docker-backup" -Recurse -ErrorAction SilentlyContinue
Copy-Item "C:\Users\user\.wp-cli" "C:\Users\user\alphadev2\config\backups\wp-cli-backup" -Recurse -ErrorAction SilentlyContinue
Copy-Item "C:\Users\user\.claude" "C:\Users\user\alphadev2\config\backups\claude-backup" -Recurse -ErrorAction SilentlyContinue

Write-Host "Organization complete! Verify applications work before proceeding with cache relocation." -ForegroundColor Cyan
```

## Next Steps

1. **Execute Phase 1** safe moves
2. **Test applications** after each move
3. **Create configuration backups** in Phase 2
4. **Update cache locations** with proper configuration changes  
5. **Set environment variables** for easy access
6. **Clean up original locations** only after full verification

---

**⚠️ Important Reminders:**
- Always test after each move
- Keep SSH keys in original location
- Backup configurations before moving them  
- Update application settings for cache relocations
- Monitor applications for 48 hours after major moves

**Document generated:** 2025-01-11  
**Last updated:** Initial creation