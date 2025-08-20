# WordPress to Next.js Migration Automation Plan
*Comprehensive Script-Based Migration for 40+ Sites*
*Created: 2025-08-14 | Status: Planning Phase*

## 🎯 **OVERVIEW**

**Mission**: Automate WordPress → Next.js headless migration for 40+ sites to reduce token costs from $2,300 to ~$200 (91% savings)

**Current Cost**: $57.69 per site × 40 sites = $2,307.60
**Automated Cost**: One-time development (~$200) + $0 execution = **$2,107.60 SAVINGS**

---

## 🗂️ **CREDENTIAL REFERENCES**

### **File Locations** (Exact Paths)
```
📁 SSH & Server Access:
├── C:\Users\user\.ssh\gridpane_rsa           # Private SSH key for all servers
├── C:\Users\user\.ssh\gridpane_rsa.pub       # Public SSH key
└── C:\Users\user\alphadev2\SSH\gridpane-sites.csv  # Master sites database

📁 API Credentials:
├── C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token      # Vercel deployment
├── C:\Users\user\alphadev2\devops\secrets\credentials\github.token      # GitHub API
├── C:\Users\user\alphadev2\devops\secrets\credentials\resend.key        # Resend email API
├── C:\Users\user\alphadev2\devops\secrets\credentials\cloudflare.token  # Cloudflare API (Turnstile)
└── C:\Users\user\alphadev2\devops\secrets\credentials\supabase.*        # Database (if needed)

📁 Templates & References:
├── C:\Users\user\alphadev2\migration\projects\stocktiming-headless\     # Master template
├── C:\Users\user\alphadev2\migration\CLAUDE.md                         # Migration guide
└── C:\Users\user\alphadev2\SSH\QUICK_REFERENCE.md                      # Server details

📁 Generated Outputs (Created by scripts):
├── C:\Users\user\alphadev2\migration-scripts\credentials\              # Per-site app passwords
├── C:\Users\user\alphadev2\migration-scripts\logs\                     # Execution logs
└── C:\Users\user\alphadev2\migration-scripts\reports\                  # Test results
```

### **Server Infrastructure Map**
```csv
Server,IP,Sites,SSH_Command
cendol-may25,162.243.15.7,20,ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7
bessie,68.183.24.139,34,ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@68.183.24.139
legal-may25,138.197.11.181,21,ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@138.197.11.181
kampung-may25,162.243.4.151,1,ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.4.151
```

### **WordPress Credentials Strategy**
```
⚠️  CRITICAL: WordPress credentials vary per site and must be generated dynamically

Standardized User Creation:
├── Username: "migration-admin"           # Created by Script 1 on each site
├── Email: "migration@{domain}.com"       # Dynamic email per site
├── Role: "administrator"                 # Required for full access
└── App Password: {GENERATED_PER_SITE}    # Created and stored per site

Storage Pattern:
└── C:\Users\user\alphadev2\migration-scripts\credentials\{domain}-app-password.txt

REST API Pattern: https://staging.{DOMAIN}/wp-json/wp/v2/
```

### **Fixed API Keys** (Same across all sites)
```
# Contact Form Services
RESEND_API_KEY=re_MPtZwtkg_DW7de2PRMu38sfCwepKT6aDK                    # From resend.key
TURNSTILE_SITE_KEY=0x4AAAAAABrmbM4_ZthcCAes                            # Same for all sites  
TURNSTILE_SECRET_KEY=0x4AAAAAABrmbFVyK7DST8dg3n7tTTDOW2w               # Same for all sites
SUPABASE_URL=https://nkcjwrksvmjzqsatwkac.supabase.co                  # Shared database
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...             # Shared access
```

---

## 📋 **AUTOMATED MIGRATION SCRIPTS**

### **Script 1: WordPress Backend Preparation**
**File**: `migration-scripts/01-wordpress-prep.ps1`
**Complexity**: ⭐⭐⭐ (Medium)
**Execution Time**: ~3 minutes per site

#### **Purpose**
Prepare WordPress backend for headless migration by configuring plugins, permissions, and API access.

#### **Required Credentials**
- **SSH Private Key**: `C:\Users\user\.ssh\gridpane_rsa`
- **Sites Database**: `C:\Users\user\alphadev2\SSH\gridpane-sites.csv`
- **No WordPress credentials needed** (script creates them)

#### **Input Parameters**
```powershell
# Single site mode
./01-wordpress-prep.ps1 -Domain "funmathgames.com"

# Batch mode  
./01-wordpress-prep.ps1 -BatchFile "sites-to-migrate.csv"
```

#### **Input CSV Format** (`sites-to-migrate.csv`)
```csv
Domain,BrandName
funmathgames.com,Fun Math Games
climatefinance.org,Climate Finance Solutions
coloradoroofingsolutions.com,Colorado Roofing Solutions
```

#### **Automated Tasks**
1. **Domain Lookup**: Query `gridpane-sites.csv` for server IP and system user
2. **SSH Connection**: Connect to appropriate server using SSH key
3. **Plugin Deactivation**: 
   ```bash
   sudo -u {SYSTEM_USER} wp plugin deactivate wordfence
   sudo -u {SYSTEM_USER} wp plugin deactivate force-login
   sudo -u {SYSTEM_USER} wp plugin deactivate wp-security-audit-log
   sudo -u {SYSTEM_USER} wp plugin deactivate all-in-one-wp-security
   ```
4. **Migration Admin User Creation**:
   ```bash
   # Create standardized migration admin user
   sudo -u {SYSTEM_USER} wp user create "migration-admin" "migration@{DOMAIN}.com" \
     --role=administrator \
     --display_name="Migration Admin" \
     --first_name="Migration" \
     --last_name="Admin"
   ```
5. **Application Password Creation**: 
   ```bash
   # Create app password for the new migration user
   sudo -u {SYSTEM_USER} wp user application-password create "migration-admin" "RESTAPI" --porcelain
   # Store password in: C:\Users\user\alphadev2\migration-scripts\credentials\{domain}-app-password.txt
   ```
6. **URL Configuration**: Set correct WordPress URLs
   ```bash
   sudo -u {SYSTEM_USER} wp option update home "https://staging.{DOMAIN}"
   sudo -u {SYSTEM_USER} wp option update siteurl "https://staging.{DOMAIN}"
   ```
7. **REST API Verification**: Test endpoint accessibility with new credentials

#### **Success Criteria**
- ✅ All security plugins deactivated
- ✅ Application password created and captured
- ✅ REST API responding with 200 status code
- ✅ WordPress URLs properly configured

#### **Output**
- **Log File**: `logs/{DOMAIN}-wordpress-prep.log`
- **Credentials File**: `credentials/{DOMAIN}-app-password.txt`
- **Status**: SUCCESS/FAILED with detailed error messages

---

### **Script 2: Content Audit & Analysis**
**File**: `migration-scripts/02-content-audit.ps1`
**Complexity**: ⭐⭐ (Easy)
**Execution Time**: ~1 minute per site

#### **Purpose**
Analyze WordPress content structure to plan migration complexity and identify potential issues.

#### **Required Credentials**
- **Sites Database**: `C:\Users\user\alphadev2\SSH\gridpane-sites.csv`
- **WordPress Credentials**: From Script 1 output or hardcoded

#### **Input Parameters**
```powershell
# Single site analysis
./02-content-audit.ps1 -Domain "funmathgames.com"

# Batch analysis
./02-content-audit.ps1 -BatchFile "sites-to-migrate.csv"
```

#### **Automated Tasks**
1. **REST API Queries**:
   ```bash
   # Posts count and structure
   curl -u "Editorial Team:WPmdQdvx28yjpWguZGWPZKey" "https://staging.{DOMAIN}/wp-json/wp/v2/posts?per_page=100"
   
   # Pages inventory
   curl -u "Editorial Team:WPmdQdvx28yjpWguZGWPZKey" "https://staging.{DOMAIN}/wp-json/wp/v2/pages?per_page=100"
   
   # Categories analysis
   curl -u "Editorial Team:WPmdQdvx28yjpWguZGWPZKey" "https://staging.{DOMAIN}/wp-json/wp/v2/categories"
   ```
2. **Content Analysis**:
   - Total posts, pages, categories count
   - URL structure patterns
   - Custom post types detection
   - Large media files identification
   - Migration complexity scoring

#### **Success Criteria**
- ✅ Complete content inventory generated
- ✅ Migration complexity assessed (Simple/Medium/Complex)
- ✅ Potential issues flagged
- ✅ Time estimates calculated

#### **Output**
- **Audit Report**: `audit/{DOMAIN}-content-audit.json`
- **Summary CSV**: `audit/migration-complexity-summary.csv`

---

### **Script 3: Next.js Project Generation**
**File**: `migration-scripts/03-nextjs-generator.ps1`
**Complexity**: ⭐⭐ (Easy)
**Execution Time**: ~2 minutes per site

#### **Purpose**
Clone and customize Next.js template for each domain with proper branding and configuration.

#### **Required Credentials**
- **Master Template**: `C:\Users\user\alphadev2\migration\projects\stocktiming-headless\`
- **Application Passwords**: From Script 1 output

#### **Input Parameters**
```powershell
# Single project generation
./03-nextjs-generator.ps1 -Domain "funmathgames.com" -BrandName "Fun Math Games"

# Batch generation with brand mapping
./03-nextjs-generator.ps1 -BatchFile "sites-with-brands.csv"
```

#### **Automated Tasks**
1. **Template Cloning**:
   ```powershell
   Copy-Item "C:\Users\user\alphadev2\migration\projects\stocktiming-headless\" -Destination "C:\Users\user\alphadev2\migration\projects\{DOMAIN}-headless" -Recurse
   ```
2. **Find/Replace Automation**:
   ```powershell
   # Domain references
   (Get-Content *.ts,*.tsx,*.js,*.json -Recurse) -replace 'stocktiming\.com', '{DOMAIN}' | Set-Content
   (Get-Content *.ts,*.tsx,*.js,*.json -Recurse) -replace 'staging\.stocktiming\.com', 'staging.{DOMAIN}' | Set-Content
   
   # Branding
   (Get-Content *.ts,*.tsx,*.js,*.json -Recurse) -replace 'Stock Timing', '{BRAND_NAME}' | Set-Content
   ```
3. **Environment Configuration**:
   ```env
   WORDPRESS_API_URL=https://staging.{DOMAIN}/wp-json/wp/v2
   WORDPRESS_URL=https://staging.{DOMAIN}
   WORDPRESS_HOSTNAME=staging.{DOMAIN}
   WORDPRESS_USERNAME=Editorial Team
   WORDPRESS_APP_PASSWORD={APP_PASSWORD_FROM_SCRIPT1}
   ```
4. **Package.json Updates**:
   ```json
   {
     "name": "{domain}-headless",
     "version": "1.0.0"
   }
   ```
5. **Git Initialization**:
   ```bash
   git init
   git add .
   git commit -m "Initial {DOMAIN} headless migration setup"
   ```

#### **Success Criteria**
- ✅ Project directory created and customized
- ✅ All template references updated
- ✅ Environment variables properly configured
- ✅ Git repository initialized with initial commit
- ✅ No build errors in generated project

#### **Output**
- **Project Directory**: `C:\Users\user\alphadev2\migration\projects\{DOMAIN}-headless\`
- **Configuration Log**: `logs/{DOMAIN}-generation.log`

---

### **Script 4: GitHub Repository Setup**
**File**: `migration-scripts/04-github-setup.ps1`  
**Complexity**: ⭐⭐⭐ (Medium)
**Execution Time**: ~2 minutes per site

#### **Purpose**
Create GitHub repositories and connect local projects for Vercel deployment workflow.

#### **Required Credentials**
- **GitHub Token**: `C:\Users\user\alphadev2\devops\secrets\credentials\github.token`
- **GitHub Username**: `r33bt` (from existing repos)

#### **Input Parameters**
```powershell
# Single repository creation
./04-github-setup.ps1 -Domain "funmathgames.com"

# Batch repository creation
./04-github-setup.ps1 -BatchFile "sites-to-migrate.csv"
```

#### **Automated Tasks**
1. **Load GitHub Token**:
   ```powershell
   $GitHubToken = (Get-Content "C:\Users\user\alphadev2\devops\secrets\credentials\github.token" -Raw).Trim()
   ```
2. **Create GitHub Repository**:
   ```bash
   curl -H "Authorization: token $GitHubToken" -X POST https://api.github.com/user/repos -d '{
     "name": "{domain}-headless",
     "description": "Headless WordPress migration for {domain}",
     "private": false,
     "auto_init": false
   }'
   ```
3. **Connect Local Repository**:
   ```bash
   cd "C:\Users\user\alphadev2\migration\projects\{DOMAIN}-headless"
   git remote add origin "https://github.com/r33bt/{domain}-headless.git"
   git branch -M main  
   git push -u origin main
   ```

#### **Success Criteria**
- ✅ GitHub repository created successfully
- ✅ Local project connected to remote
- ✅ Initial code pushed to main branch
- ✅ Repository accessible and properly configured

#### **Output**
- **GitHub URL**: `https://github.com/r33bt/{domain}-headless`
- **Connection Log**: `logs/{DOMAIN}-github-setup.log`

---

### **Script 5: Vercel Project Setup & Deployment**
**File**: `migration-scripts/05-vercel-deploy.ps1`
**Complexity**: ⭐⭐⭐⭐ (Complex)  
**Execution Time**: ~5 minutes per site

#### **Purpose**
Create Vercel projects, configure environment variables, and deploy from GitHub with proper domain configuration.

#### **Required Credentials**
- **Vercel Token**: `C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token`
- **Environment Templates**: From Script 3 output

#### **Input Parameters**
```powershell
# Single deployment  
./05-vercel-deploy.ps1 -Domain "funmathgames.com" -GitHubRepo "r33bt/funmathgames-headless"

# Batch deployment
./05-vercel-deploy.ps1 -BatchFile "sites-ready-for-deployment.csv"
```

#### **Automated Tasks**
1. **Load Vercel Token**:
   ```powershell
   $VercelToken = (Get-Content "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token" -Raw).Trim()
   ```
2. **Create Vercel Project**:
   ```bash
   vercel --token $VercelToken projects add {domain}-headless --repo r33bt/{domain}-headless
   ```
3. **Configure Environment Variables**:
   ```bash
   # WordPress API Configuration (using credentials from Script 1)
   vercel env add WORDPRESS_API_URL --token $VercelToken --scope production --value "https://staging.{DOMAIN}/wp-json/wp/v2"
   vercel env add WORDPRESS_USERNAME --token $VercelToken --scope production --value "migration-admin"
   vercel env add WORDPRESS_APP_PASSWORD --token $VercelToken --scope production --value "{APP_PASSWORD_FROM_SCRIPT1}"
   
   # Contact Form Configuration
   vercel env add RESEND_API_KEY --token $VercelToken --scope production --value "re_MPtZwtkg_DW7de2PRMu38sfCwepKT6aDK"
   vercel env add NEXT_PUBLIC_TURNSTILE_SITE_KEY --token $VercelToken --scope production --value "0x4AAAAAABrmbM4_ZthcCAes"
   vercel env add TURNSTILE_SECRET_KEY --token $VercelToken --scope production --value "0x4AAAAAABrmbFVyK7DST8dg3n7tTTDOW2w"
   
   # Database Configuration
   vercel env add NEXT_PUBLIC_SUPABASE_URL --token $VercelToken --scope production --value "https://nkcjwrksvmjzqsatwkac.supabase.co"
   vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY --token $VercelToken --scope production --value "{SUPABASE_ANON_KEY}"
   ```
4. **Trigger GitHub Push** (This triggers Vercel auto-deployment):
   ```bash
   # Navigate to project directory
   cd "C:\Users\user\alphadev2\migration\projects\{DOMAIN}-headless"
   
   # Create deployment commit with environment variables
   git add .
   git commit -m "Production deployment: Add contact form and final configurations

   - Configure WordPress API integration
   - Add Resend email service  
   - Setup Cloudflare Turnstile CAPTCHA
   - Configure Supabase database logging
   - Ready for production deployment"
   
   # Push to GitHub (triggers automatic Vercel deployment via GitHub integration)
   git push origin main
   ```
5. **Monitor Vercel Deployment**:
   ```bash
   # Wait for automatic deployment to complete (GitHub → Vercel webhook)
   vercel --token $VercelToken ls {domain}-headless  # Check deployment status
   ```
6. **Domain Configuration** (if needed):
   ```bash
   vercel domains add {domain}.com --token $VercelToken
   ```

#### **Success Criteria**  
- ✅ Vercel project created and linked to GitHub
- ✅ All environment variables configured
- ✅ Successful production deployment
- ✅ Site accessible and returning 200 status
- ✅ Basic functionality test passed

#### **Output**
- **Live URL**: `https://{domain}-headless.vercel.app`
- **Deployment Log**: `logs/{DOMAIN}-vercel-deploy.log`
- **Environment Config**: `configs/{DOMAIN}-vercel-env.json`

---

### **Script 6: Post-Migration Testing & Validation**
**File**: `migration-scripts/06-testing-suite.ps1`
**Complexity**: ⭐⭐⭐ (Medium)
**Execution Time**: ~3 minutes per site

#### **Purpose**
Comprehensive testing of migrated sites to ensure full functionality and identify issues.

#### **Required Credentials**
- **Site URLs**: From Script 5 output
- **WordPress Credentials**: For admin access verification

#### **Input Parameters**
```powershell
# Single site testing
./06-testing-suite.ps1 -Domain "funmathgames.com" -LiveURL "https://funmathgames-headless.vercel.app"

# Batch testing
./06-testing-suite.ps1 -BatchFile "deployed-sites.csv"
```

#### **Automated Tasks**
1. **Homepage Testing**:
   ```powershell
   $Response = Invoke-WebRequest -Uri "https://{domain}-headless.vercel.app" -Method GET
   # Verify 200 status, load time, basic content
   ```
2. **Content Testing**:
   ```powershell
   # Test sample post URLs
   # Test sample page URLs  
   # Test category pages
   # Verify no 404 errors on critical paths
   ```
3. **Contact Form Testing**:
   ```powershell
   # Test form submission
   # Verify email delivery
   # Test CAPTCHA functionality
   ```
4. **WordPress Admin Verification**:
   ```powershell
   # Ensure WordPress admin still accessible
   # Verify staging site functionality preserved
   ```
5. **Performance Testing**:
   ```powershell
   # Page load speed analysis
   # Core Web Vitals check
   # Mobile responsiveness
   ```

#### **Success Criteria**
- ✅ All critical pages loading (200 status)
- ✅ Contact form functional with email delivery
- ✅ WordPress admin accessible
- ✅ No 404 errors on expected URLs
- ✅ Acceptable performance metrics

#### **Output**
- **Test Report**: `reports/{DOMAIN}-test-results.json`
- **Issues Log**: `reports/{DOMAIN}-issues.log`
- **Summary Dashboard**: `reports/migration-summary.html`

---

## 🚀 **CRITICAL DEPENDENCY ANALYSIS & BATCH WORKFLOW**

### **Script Dependencies & Batch Processing Logic**

```
DEPENDENCY CHAIN:
Script 1 → Script 3 → Script 4 → Script 5 → Script 6
    ↓        ↓        ↓        ↓        ↓
WordPress  Next.js   GitHub   Vercel   Testing
Backend    Projects  Repos    Deploy   Validation
    ↓
Script 2 (Independent - can run parallel with Script 1)
```

### **Batch Processing Model: 30 Sites Example**

#### **STAGE 1: WordPress Backend Preparation (Script 1)**
**Goal**: Process all 30 WordPress sites to create admin users and app passwords

```powershell
# Input: 30 domains in CSV
./01-wordpress-prep.ps1 -BatchFile "30-sites-batch1.csv"

# What happens:
# - Loops through all 30 domains
# - SSH to each server (4 different servers: cendol, bessie, legal, kampung)
# - Deactivates security plugins on each site
# - Creates "migration-admin" user on each site
# - Generates app password for each site
# - Stores 30 individual password files in credentials/

# OUTPUT REQUIRED FOR NEXT STEPS:
# ✅ 30 files: credentials/{domain}-app-password.txt
# ✅ All WordPress sites accessible via REST API
```

**⚠️ CRITICAL DEPENDENCY**: Scripts 3, 4, 5 CANNOT proceed without Script 1 completing successfully for all sites.

#### **STAGE 2: Content Audit (Script 2) - PARALLEL**
**Goal**: Analyze content complexity for all 30 sites (runs independently)

```powershell
# Can run in parallel with Script 1 or after
./02-content-audit.ps1 -BatchFile "30-sites-batch1.csv"

# What happens:
# - REST API calls to each of 30 sites
# - Counts posts, pages, categories
# - Identifies migration complexity
# - Generates audit reports

# OUTPUT:
# ✅ audit/content-audit-summary.csv (30 sites analyzed)
# ✅ Migration complexity assessment
```

**🟢 NO DEPENDENCIES**: Can run anytime, even before Script 1 if WordPress sites are accessible.

#### **STAGE 3: Next.js Project Generation (Script 3)**
**Goal**: Generate 30 customized Next.js projects

```powershell
# REQUIRES: Script 1 completed (needs app passwords)
./03-nextjs-generator.ps1 -BatchFile "30-sites-batch1.csv"

# What happens:
# - Clones master template 30 times
# - Customizes each project (domain, branding)
# - Reads app passwords from credentials/{domain}-app-password.txt
# - Creates .env.production for each project
# - Initializes Git in each project directory

# OUTPUT REQUIRED FOR NEXT STEPS:
# ✅ 30 directories: migration/projects/{domain}-headless/
# ✅ Each with customized code and environment variables
# ✅ Each with initialized Git repository
```

**⚠️ CRITICAL DEPENDENCIES**: 
- Script 1 must complete successfully
- All 30 app password files must exist
- Master template must be available

#### **STAGE 4: GitHub Repository Creation (Script 4)**
**Goal**: Create 30 GitHub repositories and push initial code

```powershell
# REQUIRES: Script 3 completed (needs local Git repos)
./04-github-setup.ps1 -BatchFile "30-sites-batch1.csv"

# What happens:
# - Creates 30 GitHub repositories via API
# - Connects each local project to its GitHub repo
# - Pushes initial code for all 30 projects
# - Verifies all repositories are accessible

# OUTPUT REQUIRED FOR NEXT STEPS:
# ✅ 30 GitHub repositories: github.com/r33bt/{domain}-headless
# ✅ All code pushed to main branch
# ✅ Ready for Vercel connection
```

**⚠️ CRITICAL DEPENDENCIES**:
- Script 3 must complete successfully
- All 30 local Git repositories must exist
- GitHub API token must be valid
- Network connectivity required

#### **STAGE 5: Vercel Deployment (Script 5)**
**Goal**: Deploy all 30 sites to production

```powershell
# REQUIRES: Script 4 completed (needs GitHub repos)
./05-vercel-deploy.ps1 -BatchFile "30-sites-batch1.csv"

# What happens:
# - Creates 30 Vercel projects linked to GitHub
# - Configures environment variables for each project
# - Triggers deployment by pushing to GitHub
# - Monitors deployment status for all 30 sites
# - Records live URLs

# OUTPUT REQUIRED FOR NEXT STEPS:
# ✅ 30 live websites: {domain}-headless.vercel.app
# ✅ All environment variables configured
# ✅ Contact forms functional
```

**⚠️ CRITICAL DEPENDENCIES**:
- Script 4 must complete successfully
- All 30 GitHub repositories must exist and be accessible
- Vercel API token must be valid
- WordPress sites must be accessible (for API integration)

#### **STAGE 6: Testing & Validation (Script 6)**
**Goal**: Validate all 30 migrated sites

```powershell
# REQUIRES: Script 5 completed (needs live sites)
./06-testing-suite.ps1 -BatchFile "30-sites-batch1.csv"

# What happens:
# - Tests homepage, posts, pages for all 30 sites
# - Tests contact forms on all 30 sites
# - Verifies WordPress admin access still works
# - Generates comprehensive report

# OUTPUT:
# ✅ reports/final-migration-report.html
# ✅ Pass/fail status for all 30 sites
```

---

### **CRITICAL FAILURE SCENARIOS & MITIGATION**

#### **Scenario 1: Script 1 fails on 5 out of 30 sites**
**Problem**: SSH timeouts, plugin conflicts, user creation failures
**Impact**: Scripts 3, 4, 5 cannot proceed for failed sites
**Solution**: 
```powershell
# Identify failed sites
$FailedSites = @("domain1.com", "domain2.com", "domain3.com", "domain4.com", "domain5.com")

# Create retry CSV with only failed sites
$FailedSites | Export-Csv "failed-sites-retry.csv"

# Retry Script 1 for failed sites only
./01-wordpress-prep.ps1 -BatchFile "failed-sites-retry.csv"

# Continue with successful 25 sites
$SuccessfulSites = @("other25domains...")
$SuccessfulSites | Export-Csv "successful-sites.csv"
./03-nextjs-generator.ps1 -BatchFile "successful-sites.csv"
```

#### **Scenario 2: GitHub API rate limiting in Script 4**
**Problem**: Creating 30 repositories rapidly hits rate limits
**Impact**: Some repositories not created, Script 5 cannot proceed
**Solution**: 
```powershell
# Implement delays and batching in Script 4
# Process 10 sites at a time with 1-minute delays
$Batches = @(
    @("site1", "site2", ..., "site10"),
    @("site11", "site12", ..., "site20"), 
    @("site21", "site22", ..., "site30")
)

foreach ($Batch in $Batches) {
    # Process batch
    Start-Sleep -Seconds 60  # Rate limit mitigation
}
```

#### **Scenario 3: Vercel deployment failures in Script 5**
**Problem**: Build errors, environment variable issues
**Impact**: Some sites don't deploy successfully
**Solution**: 
```powershell
# Implement deployment monitoring
$DeploymentStatus = @{}
foreach ($Domain in $Domains) {
    $Status = Deploy-VercelSite -Domain $Domain
    $DeploymentStatus[$Domain] = $Status
    
    if ($Status -eq "Failed") {
        Write-Log "Deployment failed for $Domain - will retry"
        # Add to retry queue
    }
}

# Generate retry list for failed deployments
$FailedDeployments | Export-Csv "deployment-failures.csv"
```

---

### **BATCH PROCESSING OPTIMIZATIONS**

#### **Parallel Processing Opportunities**
```powershell
# Script 1: SSH operations can be parallelized per server
$CendolSites = Get-SitesForServer -Server "cendol-may25"
$BessieSites = Get-SitesForServer -Server "bessie"
$LegalSites = Get-SitesForServer -Server "legal-may25"
$KampungSites = Get-SitesForServer -Server "kampung-may25"

# Process each server in parallel
$Jobs = @()
$Jobs += Start-Job { Process-WordPressSites -Sites $CendolSites -Server "cendol-may25" }
$Jobs += Start-Job { Process-WordPressSites -Sites $BessieSites -Server "bessie" }
$Jobs += Start-Job { Process-WordPressSites -Sites $LegalSites -Server "legal-may25" }
$Jobs += Start-Job { Process-WordPressSites -Sites $KampungSites -Server "kampung-may25" }

# Wait for all jobs to complete
$Jobs | Wait-Job | Receive-Job
```

#### **Progress Monitoring & Resumption**
```powershell
# Each script should maintain state file
$StateFile = "migration-state.json"
$State = @{
    "Script1_Completed" = @("domain1.com", "domain2.com")
    "Script1_Failed" = @("domain3.com")
    "Script1_Pending" = @("domain4.com", "domain5.com", ...)
    "Script3_Completed" = @()
    "Script3_Failed" = @()
    "Script3_Pending" = @()
}

# Resume from where we left off
./01-wordpress-prep.ps1 -BatchFile "30-sites.csv" -ResumeFromState $StateFile
```

---

### **EXECUTION TIMELINE (30 Sites)**

```
HOUR 0-2: Script 1 (WordPress Prep)
├── Parallel processing across 4 servers
├── ~4 minutes per site average = 120 minutes total
└── Output: 30 app password files

HOUR 2-3: Script 2 + Script 3 (Parallel)
├── Script 2: Content audit (REST API calls)
├── Script 3: Project generation (file operations)  
└── Output: 30 Next.js projects + audit report

HOUR 3-4: Script 4 (GitHub Setup)
├── Rate-limited GitHub API operations
├── ~2 minutes per site = 60 minutes
└── Output: 30 GitHub repositories

HOUR 4-8: Script 5 (Vercel Deployment)
├── Environment variable configuration: 30 minutes
├── Deployment triggers: 30 minutes
├── Deployment processing: 3+ hours (Vercel build time)
└── Output: 30 live websites

HOUR 8-9: Script 6 (Testing)
├── Automated testing across 30 sites
├── Report generation
└── Output: Final migration report

TOTAL: 8-9 hours for 30 sites (vs 22.5 hours manual)
```

---

### **REFINED EXECUTION MODEL**

```powershell
# STAGE 1: Prerequisites validation
./00-validate-environment.ps1 -BatchFile "30-sites-batch1.csv"

# STAGE 2: WordPress backend (WITH state management)
./01-wordpress-prep.ps1 -BatchFile "30-sites-batch1.csv" -EnableStateTracking

# STAGE 3: Parallel content audit + project generation
Start-Job { ./02-content-audit.ps1 -BatchFile "30-sites-batch1.csv" }
./03-nextjs-generator.ps1 -BatchFile "30-sites-batch1.csv" -WaitForScript1

# STAGE 4: GitHub repository creation (WITH rate limiting)
./04-github-setup.ps1 -BatchFile "30-sites-batch1.csv" -BatchSize 10 -DelaySeconds 60

# STAGE 5: Vercel deployment (WITH monitoring)
./05-vercel-deploy.ps1 -BatchFile "30-sites-batch1.csv" -MonitorDeployments

# STAGE 6: Comprehensive testing
./06-testing-suite.ps1 -BatchFile "30-sites-batch1.csv" -GenerateReport
```

---

## 📊 **COST & TIME ANALYSIS**

### **Development Investment**
- **Script Development Time**: ~8-10 hours
- **Token Cost for Development**: ~$200 (one-time)
- **Testing & Refinement**: ~4-6 hours

### **Execution Efficiency**
- **Total Execution Time**: 15-20 hours for 40 sites
- **Token Cost for Execution**: $0
- **Human Oversight Required**: Minimal (error handling only)

### **Comparison with Manual Process**
| Metric | Manual Process | Automated Process | Savings |
|--------|---------------|------------------|---------|
| **Time per Site** | 45 minutes | 20 minutes | 56% |
| **Token Cost per Site** | $57.69 | $0 | 100% |
| **Total Time (40 sites)** | 30 hours | 13 hours | 57% |
| **Total Cost (40 sites)** | $2,307.60 | $200 | 91% |
| **Error Rate** | High (manual) | Low (automated) | 80%+ |
| **Consistency** | Variable | Perfect | 100% |

---

## 🎯 **SUCCESS METRICS & VALIDATION**

### **Quantitative Goals**
- ✅ **95%+ automation rate** for repetitive tasks
- ✅ **90%+ cost reduction** compared to manual process
- ✅ **50%+ time savings** end-to-end
- ✅ **Zero configuration errors** across sites
- ✅ **100% deployment success** rate

### **Quality Assurance**
- ✅ **Comprehensive logging** for all operations
- ✅ **Rollback procedures** for failed deployments
- ✅ **Error handling** with human intervention points
- ✅ **Validation testing** for each migration phase

---

## 🔧 **RISK MITIGATION**

### **High-Risk Areas**
1. **SSH Automation**: Network timeouts, permission issues
2. **GitHub API**: Rate limiting, authentication failures  
3. **Vercel Deployment**: Build failures, environment variable issues
4. **Domain Configuration**: DNS propagation, SSL certificate issues

### **Mitigation Strategies**
1. **Comprehensive Error Handling**: Retry logic, fallback procedures
2. **Staged Execution**: Test with 5 sites first, then scale
3. **Backup Procedures**: Git commits, configuration backups
4. **Manual Override**: Human intervention points for complex issues

---

## 📋 **MASTER INPUT/OUTPUT SPECIFICATION**

### **Primary Input File Format** (`sites-to-migrate.csv`)
```csv
Domain,BrandName,Priority,Notes
funmathgames.com,Fun Math Games,High,Math education site
climatefinance.org,Climate Finance Solutions,Medium,Professional services
coloradoroofingsolutions.com,Colorado Roofing Solutions,High,Local business
the-weddingplanner.com,The Wedding Planner,Low,Wedding services
chiefoperatingofficer.org,Chief Operating Officer,Medium,Business consultancy
```

### **Simple Execution Model**
```powershell
# Step 1: Prepare WordPress backends (creates credentials)
./01-wordpress-prep.ps1 -BatchFile "sites-to-migrate.csv"

# Step 2: Audit content (understand complexity)
./02-content-audit.ps1 -BatchFile "sites-to-migrate.csv"

# Step 3: Generate Next.js projects (template + customization)
./03-nextjs-generator.ps1 -BatchFile "sites-to-migrate.csv"

# Step 4: Create GitHub repos and push code
./04-github-setup.ps1 -BatchFile "sites-to-migrate.csv"

# Step 5: Deploy to Vercel (environment + deployment)
./05-vercel-deploy.ps1 -BatchFile "sites-to-migrate.csv"

# Step 6: Test everything (validation)
./06-testing-suite.ps1 -BatchFile "sites-to-migrate.csv"
```

### **Generated Output Files**
```
📁 C:\Users\user\alphadev2\migration-scripts\
├── credentials\
│   ├── funmathgames.com-app-password.txt         # WordPress credentials per site
│   └── climatefinance.org-app-password.txt      
├── logs\
│   ├── funmathgames.com-wordpress-prep.log      # Detailed execution logs
│   ├── funmathgames.com-vercel-deploy.log       
│   └── batch-execution-summary.log              # Overall progress
├── reports\
│   ├── content-audit-summary.csv                # Migration complexity analysis
│   ├── deployment-status.csv                    # Success/failure tracking
│   └── final-migration-report.html              # Complete results dashboard
└── projects\                                    # Generated in migration/projects/
    ├── funmathgames-headless\                   # Ready-to-deploy Next.js projects
    └── climatefinance-headless\
```

---

## 🚨 **CRITICAL PRE-REQUISITES**

### **Required Credential Files** (Must exist before execution)
```powershell
# Verify all credentials exist
Test-Path "C:\Users\user\.ssh\gridpane_rsa"                                    # SSH key
Test-Path "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token"    # Vercel API
Test-Path "C:\Users\user\alphadev2\devops\secrets\credentials\github.token"    # GitHub API  
Test-Path "C:\Users\user\alphadev2\devops\secrets\credentials\resend.key"      # Email API
Test-Path "C:\Users\user\alphadev2\devops\secrets\credentials\cloudflare.token" # Turnstile API
Test-Path "C:\Users\user\alphadev2\SSH\gridpane-sites.csv"                    # Sites database
```

### **Directory Structure Setup**
```powershell
# Create required directories
New-Item -ItemType Directory -Force -Path "C:\Users\user\alphadev2\migration-scripts\credentials"
New-Item -ItemType Directory -Force -Path "C:\Users\user\alphadev2\migration-scripts\logs" 
New-Item -ItemType Directory -Force -Path "C:\Users\user\alphadev2\migration-scripts\reports"
```

---

## 📋 **NEXT STEPS**

### **Phase 1: Validation & Setup** 
1. **✅ Review this plan** - Verify all requirements and logic
2. **✅ Validate credentials** - Ensure all API tokens accessible  
3. **✅ Test with 2-3 sites** - Proof-of-concept before full automation
4. **✅ Create input CSV** - List domains to migrate with priorities

### **Phase 2: Script Development Priority**
1. **Script 2 (Content Audit)** - Easiest, pure API calls
2. **Script 3 (Project Generator)** - File operations and templates  
3. **Script 1 (WordPress Prep)** - SSH automation, most complex
4. **Script 4 (GitHub Setup)** - API integration
5. **Script 5 (Vercel Deploy)** - Environment management
6. **Script 6 (Testing Suite)** - Validation and reporting

### **Phase 3: Production Execution**
1. **Start small**: 5 sites first batch
2. **Monitor closely**: Check logs and outputs
3. **Scale gradually**: 10, 20, then full 40 sites
4. **Document issues**: Continuous improvement

---

**🎯 CONCLUSION**: This automation plan reduces migration costs from $2,307 to $200 (91% savings) while providing higher quality and consistency than manual processes. The simple CSV input model enables batch processing of 40+ sites with minimal human intervention.**