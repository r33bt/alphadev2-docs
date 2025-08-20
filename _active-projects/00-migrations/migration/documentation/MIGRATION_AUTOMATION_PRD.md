# Migration Automation System - Product Requirements Document
## Fully Automated Headless WordPress Migration Platform

**Version:** 1.0  
**Date:** August 12, 2025  
**Status:** Ready for Development  
**Target:** Sub-30-minute, zero-error migrations

---

## 📋 EXECUTIVE SUMMARY

### **Problem Statement**
Current headless WordPress migrations take 2+ hours with 7+ critical errors requiring manual intervention. The StockTiming and Wedding Planner migrations revealed systematic issues that repeat due to lack of automation and process adherence.

### **Solution**
A comprehensive automation system that reduces migration time by 78% and eliminates human error through scripted validation, template customization, and deployment processes.

### **Success Metrics**
- **Time**: 60+ minutes → 13 minutes (78% reduction)
- **Errors**: 7+ critical issues → 0-1 minor issues
- **Manual Steps**: 15+ → 3 (DNS + final verification)
- **User Experience**: No wrong branding visible, instant deployment

---

## 🎯 PRODUCT GOALS & OBJECTIVES

### **Primary Goals**
1. **Eliminate Template Customization Errors** - No more StockTiming branding on client sites
2. **Automate Environment Configuration** - No more API connection failures
3. **Enforce Process Compliance** - Always reference previous migration notes
4. **Reduce Manual Intervention** - Minimal user involvement required

### **Secondary Goals**
1. **DNS Automation** - Cloudflare API integration for zero-touch DNS
2. **Real-time Validation** - Catch issues before deployment
3. **Progress Monitoring** - Live migration status dashboard
4. **Documentation Generation** - Auto-generate migration reports

---

## 👥 USER PERSONAS & USE CASES

### **Primary User: Migration Operator (Claude/AI)**
**Profile:** AI assistant performing migrations based on user requests  
**Pain Points:** 
- Repeating solved issues from previous migrations
- Manual template customization prone to errors
- Time-consuming validation processes
- No systematic error prevention

**Use Cases:**
- Execute complete migration with single command
- Validate all prerequisites before starting
- Customize templates with zero hardcoded references
- Deploy with confidence of perfect branding

### **Secondary User: Business Owner**
**Profile:** Client requesting new headless WordPress site  
**Pain Points:**
- Waiting hours for migration completion
- Seeing wrong branding during deployment
- Multiple rounds of fixes required
- Unclear migration progress status

**Use Cases:**
- Provide domain name and site details
- Receive working site within 30 minutes
- See correct branding from first deployment
- Get clear progress updates throughout

---

## 🏗 SYSTEM ARCHITECTURE

### **Core Components**

```
Migration Automation System
├── 1. Pre-Migration Validator
├── 2. WordPress Configurator  
├── 3. Template Customizer
├── 4. Environment Manager
├── 5. Deployment Engine
├── 6. DNS Automator (Future)
├── 7. Post-Deployment Validator
└── 8. Migration Orchestrator
```

### **Data Flow**
1. **Input**: Domain, Site Name, Site Description
2. **Validation**: Check prerequisites and previous notes
3. **WordPress Setup**: User creation, API configuration, plugin installation
4. **Template Processing**: Clone, customize, validate branding
5. **Environment Setup**: Generate configs, set Vercel variables
6. **Deployment**: Build, deploy, domain configuration
7. **Validation**: Test functionality, branding, performance
8. **Output**: Live site URL, migration report, DNS instructions

---

## 🔧 DETAILED FEATURE REQUIREMENTS

### **1. Pre-Migration Validator**
**File:** `scripts/validate-prerequisites.sh`

**Functional Requirements:**
- ✅ Check previous migration documentation was reviewed
- ✅ Verify staging site accessibility (HTTP 200)
- ✅ Validate all required credentials exist
- ✅ Confirm template source availability
- ✅ Test SSH connectivity to GridPane server
- ✅ Verify Vercel token validity

**Non-Functional Requirements:**
- Execution time: <30 seconds
- Exit with clear error messages on any failure
- No false positives in validation checks

**Acceptance Criteria:**
- MUST block migration if any prerequisite fails
- MUST provide specific instructions to resolve failures
- MUST log all validation results for debugging

### **2. Template Customizer** 
**File:** `scripts/customize-template.sh`

**Functional Requirements:**
- ✅ Clone proven template to new directory
- ✅ Replace ALL hardcoded StockTiming references
- ✅ Update branding (site name, description, metadata)
- ✅ Update API tokens and security keys
- ✅ Validate no hardcoded references remain
- ✅ Update package.json with new project name

**Input Parameters:**
```bash
customize-template.sh <source-template> <target-domain> <site-name> <site-description>
```

**Hardcoded References to Replace:**
- `StockTiming.com` → Site Name
- `StockTiming` → Site Name  
- `stocktiming.com` → Target Domain
- `Professional Trading Strategies & Market Analysis` → Site Description
- `stocktiming-revalidate-2025` → `domain-revalidate-2025`
- `StockTiming Team` → `Site Name Team`

**Validation Rules:**
- ZERO StockTiming references allowed after processing
- ALL template files must be processed
- Validation MUST fail build if any references found

**Acceptance Criteria:**
- User never sees StockTiming branding on any client site
- Template customization is 100% reliable
- Clear error messages if customization fails

### **3. Environment Manager**
**File:** `scripts/configure-environment.sh`

**Functional Requirements:**
- ✅ Generate `.env.production` with correct values
- ✅ Clean existing Vercel environment variables
- ✅ Set new Vercel production environment variables
- ✅ Test WordPress API connectivity before proceeding
- ✅ Validate all environment variables are set correctly

**Environment Variables Managed:**
- `WORDPRESS_API_URL` → `https://staging.domain.com/wp-json/wp/v2`
- `WORDPRESS_USERNAME` → WordPress login name (not display name)
- `WORDPRESS_APP_PASSWORD` → Generated application password
- `NEXT_PUBLIC_SITE_URL` → Production domain URL

**Validation Requirements:**
- MUST test WordPress API with credentials before deployment
- MUST return HTTP 200 from WordPress REST API
- MUST fail if any environment variable is missing

**Acceptance Criteria:**
- Zero API connection failures in deployment
- All environment variables correctly configured
- WordPress content loads successfully in production

### **4. WordPress Configurator**
**File:** `scripts/configure-wordpress.sh`

**Functional Requirements:**
- ✅ Auto-detect site user from file ownership
- ✅ Generate fresh application password for site
- ✅ Configure WordPress URLs for staging environment  
- ✅ Deactivate conflicting plugins (Wordfence)
- ✅ Test REST API accessibility
- ✅ Install and activate Vercel refresh plugin

**Site User Detection:**
```bash
SITE_USER=$(stat -c '%U' wp-config.php)
```

**WordPress Configuration:**
```bash
sudo -u $SITE_USER wp option update home "https://staging.$DOMAIN"
sudo -u $SITE_USER wp option update siteurl "https://staging.$DOMAIN"
sudo -u $SITE_USER wp rewrite flush
```

**Application Password Generation:**
```bash
APP_PASSWORD=$(sudo -u $SITE_USER wp user application-password create $USERNAME "Headless API $(date +%Y)" --porcelain)
```

**Acceptance Criteria:**
- WordPress admin can save posts without "Updating failed" errors
- REST API returns WordPress content (not 401 errors)
- Auto-refresh plugin works with Vercel deployment

### **5. Deployment Engine**
**File:** `scripts/deploy-to-vercel.sh`

**Functional Requirements:**
- ✅ Run local build test before deployment
- ✅ Deploy to Vercel production with proper token
- ✅ Add custom domain to Vercel project
- ✅ Generate SSL certificate automatically
- ✅ Return deployment URL for validation

**Pre-Deployment Checks:**
- Local `npm run build` must succeed
- All environment variables must be set
- WordPress API connectivity confirmed

**Deployment Process:**
```bash
vercel --prod --token $VERCEL_TOKEN
vercel domains add $DOMAIN --token $VERCEL_TOKEN
```

**Acceptance Criteria:**
- Single deployment attempt (no retries needed)
- SSL certificate auto-generated and active
- Custom domain properly configured
- Deployment URL accessible within 2 minutes

### **6. Post-Deployment Validator**
**File:** `scripts/validate-deployment.sh`

**Functional Requirements:**
- ✅ Test deployment URL accessibility
- ✅ Validate site shows correct branding (not StockTiming)
- ✅ Verify WordPress content is loading
- ✅ Check SSL certificate validity
- ✅ Test responsive design on multiple viewports

**Branding Validation:**
- Site title must match provided site name
- No "StockTiming" text anywhere in HTML
- Correct site description in metadata
- Proper author attribution

**Content Validation:**
- WordPress posts are visible
- Categories and tags loading
- Featured images displaying
- Navigation working properly

**Acceptance Criteria:**
- Client never sees incorrect branding
- All WordPress content loads correctly
- Site passes basic functionality tests

### **7. DNS Automator (Future Phase)**
**File:** `scripts/configure-dns-api.sh`

**Functional Requirements:**
- ✅ Integrate with Cloudflare API
- ✅ Auto-approve Vercel DNS requests
- ✅ Configure A records and CNAME records
- ✅ Verify DNS propagation
- ✅ Handle staging subdomain separately

**API Requirements:**
- Cloudflare API key stored in credentials
- Zone ID detection for domain
- Automatic record creation/updates
- DNS propagation testing

**Acceptance Criteria:**
- Zero manual DNS configuration required
- DNS resolves correctly within 5 minutes
- Both production and staging domains work

### **8. Migration Orchestrator**
**File:** `scripts/migrate-site.sh`

**Functional Requirements:**
- ✅ Execute all migration steps in correct order
- ✅ Stop on any error with clear diagnostics
- ✅ Provide real-time progress updates
- ✅ Generate migration completion report
- ✅ Handle rollback if critical errors occur

**Execution Flow:**
1. Pre-migration validation
2. WordPress configuration  
3. Template customization
4. Environment setup
5. Deployment execution
6. Post-deployment validation
7. DNS instructions (or automation)
8. Final report generation

**Progress Reporting:**
```
🚀 Starting migration for ClientSite.com
✅ [1/7] Pre-migration validation passed
✅ [2/7] WordPress configured successfully  
✅ [3/7] Template customized for Client Site
✅ [4/7] Environment variables configured
✅ [5/7] Deployed to https://clientsite.com
✅ [6/7] Post-deployment validation passed
📋 [7/7] DNS configuration required manually
🎉 Migration completed in 13 minutes!
```

**Acceptance Criteria:**
- Single command executes entire migration
- Clear progress visibility throughout
- Detailed error messages if any step fails
- Migration report saved for documentation

---

## 📊 TECHNICAL SPECIFICATIONS

### **Technology Stack**
- **Primary Language:** Bash scripting
- **Dependencies:** curl, sed, ssh, wp-cli, vercel-cli
- **Platform:** Windows (WSL/Git Bash compatible)
- **Storage:** Local filesystem with credential management

### **Performance Requirements**
- **Total Migration Time:** <30 minutes
- **Script Execution Time:** <5 minutes per component
- **API Response Time:** <10 seconds per call
- **Error Detection:** <30 seconds

### **Security Requirements**
- All credentials stored in secure directory structure
- No credentials in script files or logs
- SSH key-based authentication only
- Application passwords generated per-site

### **Error Handling**
- Fail-fast approach: exit on first error
- Detailed error logging with timestamps
- Rollback capability for critical failures
- Clear user instructions for manual resolution

---

## 🧪 TESTING STRATEGY

### **Unit Testing**
- Each script component tested individually
- Mock API responses for offline testing
- Credential validation without actual API calls
- Template customization with test data

### **Integration Testing**
- Full migration on test domain
- WordPress API connectivity testing
- Vercel deployment pipeline testing
- End-to-end branding validation

### **User Acceptance Testing**
- Migration operator (Claude) executes full process
- Business owner reviews final deployed site
- Performance benchmarking against manual process
- Error scenario handling validation

---

## 🚀 DEVELOPMENT PHASES

### **Phase 1: Core Automation (Week 1)**
**Priority:** 🔥 Critical
- ✅ Template Customizer (`customize-template.sh`)
- ✅ Environment Manager (`configure-environment.sh`)
- ✅ Pre-Migration Validator (`validate-prerequisites.sh`)
- ✅ WordPress Configurator (`configure-wordpress.sh`)

**Deliverable:** 4 core automation scripts preventing all major issues

### **Phase 2: Deployment & Validation (Week 2)**
**Priority:** 🟡 Important  
- ✅ Deployment Engine (`deploy-to-vercel.sh`)
- ✅ Post-Deployment Validator (`validate-deployment.sh`)
- ✅ Migration Orchestrator (`migrate-site.sh`)

**Deliverable:** Complete automated migration system

### **Phase 3: Advanced Features (Month 2)**
**Priority:** 🎯 Future
- ✅ DNS Automator (`configure-dns-api.sh`)
- ✅ Migration Dashboard (web interface)
- ✅ Real-time progress monitoring
- ✅ Advanced error recovery

**Deliverable:** Zero-touch migration platform

---

## 📈 SUCCESS CRITERIA & METRICS

### **Quantitative Metrics**
| Metric | Current | Target | Success Threshold |
|---|---|---|---|
| Migration Time | 60+ min | 13 min | <30 min |
| Critical Errors | 7+ | 0 | <2 |
| Manual Steps | 15+ | 3 | <5 |
| Deployment Attempts | 2-3 | 1 | 1 |
| User Satisfaction | 6/10 | 9/10 | >8/10 |

### **Qualitative Success Criteria**
- ✅ User never sees incorrect branding during migration
- ✅ Migration operator follows consistent, documented process
- ✅ Zero repetition of previously solved issues
- ✅ Clear error messages with specific resolution steps
- ✅ Migration can be executed by any trained operator

### **Acceptance Testing Checklist**
- [ ] Complete migration in <30 minutes
- [ ] Deployed site shows correct branding from first load
- [ ] WordPress content loads properly
- [ ] SSL certificate active and valid
- [ ] No manual intervention required except DNS
- [ ] Migration report generated automatically
- [ ] All scripts pass validation tests

---

## 🔄 MAINTENANCE & UPDATES

### **Version Control**
- All scripts stored in Git repository
- Semantic versioning for releases
- Change logs for each update
- Backup copies of working versions

### **Documentation Updates**
- Script usage documentation auto-generated
- Migration reports stored for reference
- Issue resolution database maintained
- Performance metrics tracked over time

### **Continuous Improvement**
- Post-migration review process
- Script optimization based on usage
- New edge case handling
- Platform compatibility updates

---

## 📋 IMPLEMENTATION CHECKLIST

### **Development Ready Items**
- [x] Requirements defined and approved
- [x] Technical architecture planned
- [x] Test scenarios identified
- [x] Success criteria established
- [x] Development phases outlined

### **Pre-Development Setup**
- [ ] Development environment prepared
- [ ] Test domain and WordPress site configured
- [ ] All required credentials accessible
- [ ] Version control repository initialized
- [ ] Testing framework established

### **Development Execution**
- [ ] Phase 1 scripts developed and tested
- [ ] Phase 2 integration completed
- [ ] End-to-end testing performed
- [ ] Documentation updated
- [ ] Production deployment ready

---

**This PRD serves as the complete blueprint for developing a migration automation system that will eliminate the 7+ critical issues encountered in previous migrations and achieve the target of sub-30-minute, error-free deployments.**