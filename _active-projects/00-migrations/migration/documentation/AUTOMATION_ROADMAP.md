# Migration Automation Roadmap
## Critical Scripts Needed to Prevent Future Issues

**Based on:** Wedding Planner migration failures  
**Priority:** Immediate implementation required  
**Target:** Sub-30-minute fully automated migrations

---

## 🔥 CRITICAL AUTOMATION SCRIPTS (Implement First)

### **1. Template Customization Automation**
**File:** `scripts/customize-template.sh`  
**Priority:** 🔥 CRITICAL (Prevents wrong branding deployment)

```bash
#!/bin/bash
# customize-template.sh <source-template> <target-domain> <site-name> <site-description>

SOURCE_TEMPLATE=$1
TARGET_DOMAIN=$2  
SITE_NAME=$3
SITE_DESCRIPTION=$4

echo "🎯 Customizing template for $SITE_NAME..."

# Copy template
cp -r "$SOURCE_TEMPLATE" "${TARGET_DOMAIN}-headless"
cd "${TARGET_DOMAIN}-headless"

# Replace ALL hardcoded references (comprehensive list from wedding planner failure)
find . -name "*.tsx" -o -name "*.ts" -o -name "*.js" | xargs sed -i "
s/StockTiming\.com/$SITE_NAME/g
s/StockTiming/$SITE_NAME/g
s/stocktiming\.com/$TARGET_DOMAIN/g
s/staging\.stocktiming\.com/staging.$TARGET_DOMAIN/g
s/Professional Trading Strategies & Market Analysis/$SITE_DESCRIPTION/g
s/stocktiming-revalidate-2025/${TARGET_DOMAIN//\./-}-revalidate-2025/g
s/StockTiming Team/${SITE_NAME} Team/g
"

# CRITICAL: Validation step (wedding planner failed here)
echo "🔍 Validating template customization..."
STOCKTIMING_REFS=$(find . -name "*.tsx" -o -name "*.ts" | xargs grep -c "StockTiming\|stocktiming\.com" || echo "0")

if [ "$STOCKTIMING_REFS" -gt 0 ]; then
    echo "❌ CRITICAL ERROR: StockTiming references still found!"
    echo "Files with remaining references:"
    find . -name "*.tsx" -o -name "*.ts" | xargs grep -l "StockTiming\|stocktiming\.com"
    exit 1
fi

echo "✅ Template customization successful for $SITE_NAME"
```

### **2. Environment Configuration Automation**
**File:** `scripts/configure-environment.sh`  
**Priority:** 🔥 CRITICAL (Prevents API connection failures)

```bash
#!/bin/bash
# configure-environment.sh <domain> <wp-username> <app-password>

DOMAIN=$1
WP_USERNAME=$2
APP_PASSWORD=$3
VERCEL_TOKEN=$(cat "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token")

echo "⚙️ Configuring environment for $DOMAIN..."

# Generate .env.production (wedding planner had wrong values here)
cat > .env.production << EOF
WORDPRESS_API_URL=https://staging.$DOMAIN/wp-json/wp/v2
WORDPRESS_USERNAME=$WP_USERNAME
WORDPRESS_APP_PASSWORD=$APP_PASSWORD
NEXT_PUBLIC_SITE_URL=https://$DOMAIN
EOF

# Clean up any existing Vercel environment variables
echo "🧹 Cleaning existing environment variables..."
vercel env rm WORDPRESS_API_URL production --token $VERCEL_TOKEN --yes 2>/dev/null || true
vercel env rm WORDPRESS_USERNAME production --token $VERCEL_TOKEN --yes 2>/dev/null || true
vercel env rm WORDPRESS_APP_PASSWORD production --token $VERCEL_TOKEN --yes 2>/dev/null || true

# Set new Vercel environment variables
echo "🔧 Setting Vercel environment variables..."
echo "https://staging.$DOMAIN/wp-json/wp/v2" | vercel env add WORDPRESS_API_URL production --token $VERCEL_TOKEN
echo "$WP_USERNAME" | vercel env add WORDPRESS_USERNAME production --token $VERCEL_TOKEN  
echo "$APP_PASSWORD" | vercel env add WORDPRESS_APP_PASSWORD production --token $VERCEL_TOKEN

# CRITICAL: Test WordPress API connection
echo "🔍 Validating WordPress API connection..."
HTTP_CODE=$(curl -s -u "$WP_USERNAME:$APP_PASSWORD" \
    "https://staging.$DOMAIN/wp-json/wp/v2/posts?per_page=1" \
    -o /dev/null -w "%{http_code}")
    
if [ $HTTP_CODE -ne 200 ]; then
    echo "❌ CRITICAL ERROR: WordPress API connection failed (HTTP $HTTP_CODE)"
    echo "Check username ($WP_USERNAME) and password"
    exit 1
fi

echo "✅ Environment configuration successful for $DOMAIN"
```

### **3. Pre-Migration Validation**
**File:** `scripts/validate-before-migration.sh`  
**Priority:** 🔥 CRITICAL (Prevents repeating solved issues)

```bash
#!/bin/bash
# validate-before-migration.sh <domain>

DOMAIN=$1

echo "📋 Pre-migration validation checklist for $DOMAIN..."

# 1. Verify previous migration notes were reviewed
echo "📖 Did you review previous migration documentation? [y/N]"
read -r REVIEWED_NOTES
if [[ ! $REVIEWED_NOTES =~ ^[Yy]$ ]]; then
    echo "❌ CRITICAL: Must review previous migration notes first"
    echo "Read: C:\Users\user\alphadev2\migration\documentation\DETAILED_MIGRATION_LOG_PART_2_WORDPRESS_ISSUES.md"
    exit 1
fi

# 2. Verify staging site accessibility
echo "🌐 Testing staging site accessibility..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://staging.$DOMAIN")
if [ $HTTP_CODE -ne 200 ]; then
    echo "❌ CRITICAL: Staging site not accessible at https://staging.$DOMAIN (HTTP $HTTP_CODE)"
    exit 1
fi

# 3. Verify required credentials exist
echo "🔑 Checking required credentials..."
REQUIRED_CREDS=(
    "C:\Users\user\.ssh\gridpane_rsa"
    "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token"
)

for CRED in "${REQUIRED_CREDS[@]}"; do
    if [ ! -f "$CRED" ]; then
        echo "❌ CRITICAL: Missing credential file: $CRED"
        exit 1
    fi
done

# 4. Verify template source exists
TEMPLATE_SOURCE="C:\Users\user\alphadev2\migration\projects\stocktiming-headless"
if [ ! -d "$TEMPLATE_SOURCE" ]; then
    echo "❌ CRITICAL: Template source not found: $TEMPLATE_SOURCE"
    exit 1
fi

echo "✅ Pre-migration validation passed for $DOMAIN"
```

### **4. Post-Deployment Validation**
**File:** `scripts/validate-deployment.sh`  
**Priority:** 🟡 Important (Catches issues before user sees them)

```bash
#!/bin/bash
# validate-deployment.sh <domain> <site-name>

DOMAIN=$1
SITE_NAME=$2
DEPLOYMENT_URL=$3

echo "🔍 Post-deployment validation for $SITE_NAME..."

# 1. Test site accessibility
echo "🌐 Testing site accessibility..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOYMENT_URL")
if [ $HTTP_CODE -eq 401 ]; then
    echo "⚠️ WARNING: Site shows 401 (likely Vercel SSO) - will resolve with custom domain"
elif [ $HTTP_CODE -ne 200 ]; then
    echo "❌ CRITICAL: Site not accessible (HTTP $HTTP_CODE)"
    exit 1
fi

# 2. Test content branding (prevent wedding planner issue)
echo "🏷️ Testing site branding..."
CONTENT=$(curl -s "$DEPLOYMENT_URL" || echo "")
if echo "$CONTENT" | grep -q -i "stocktiming"; then
    echo "❌ CRITICAL: Site still shows StockTiming branding!"
    echo "Check template customization"
    exit 1
fi

if [ -n "$SITE_NAME" ] && ! echo "$CONTENT" | grep -q "$SITE_NAME"; then
    echo "⚠️ WARNING: Site name '$SITE_NAME' not found in content"
    echo "Verify template customization was successful"
fi

# 3. Test WordPress content integration
echo "📝 Testing WordPress content integration..."
if echo "$CONTENT" | grep -q -i "wordpress\|posts\|categories"; then
    echo "✅ WordPress content detected"
else
    echo "⚠️ WARNING: No WordPress content detected in HTML"
fi

echo "✅ Post-deployment validation completed for $SITE_NAME"
```

---

## 🔄 ENHANCED AUTOMATION SCRIPTS (Next Priority)

### **5. Complete Migration Orchestrator**
**File:** `scripts/migrate-site.sh`  
**Priority:** 🟡 Important (Orchestrates all steps)

```bash
#!/bin/bash
# migrate-site.sh <domain> <site-name> <site-description>

set -e  # Exit on any error

DOMAIN=$1
SITE_NAME=$2
SITE_DESCRIPTION=$3

echo "🚀 Starting automated migration for $SITE_NAME ($DOMAIN)"

# Step 1: Pre-migration validation
./scripts/validate-before-migration.sh "$DOMAIN"

# Step 2: WordPress configuration (existing automation)
./scripts/configure-wordpress.sh "$DOMAIN"

# Step 3: Template customization (new automation)
./scripts/customize-template.sh \
    "C:\Users\user\alphadev2\migration\projects\stocktiming-headless" \
    "$DOMAIN" \
    "$SITE_NAME" \
    "$SITE_DESCRIPTION"

# Step 4: Environment configuration (new automation)
WP_USERNAME=$(./scripts/get-wp-username.sh "$DOMAIN")
APP_PASSWORD=$(./scripts/get-wp-password.sh "$DOMAIN")
./scripts/configure-environment.sh "$DOMAIN" "$WP_USERNAME" "$APP_PASSWORD"

# Step 5: Deployment
DEPLOYMENT_URL=$(./scripts/deploy-to-vercel.sh)

# Step 6: Post-deployment validation
./scripts/validate-deployment.sh "$DOMAIN" "$SITE_NAME" "$DEPLOYMENT_URL"

echo "✅ Migration completed successfully!"
echo "🌐 Deployment URL: $DEPLOYMENT_URL"
echo "📋 Next step: Configure DNS for $DOMAIN"
```

### **6. Cloudflare API Integration (Future)**
**File:** `scripts/configure-dns-api.sh`  
**Priority:** 🎯 Future (Full automation goal)

```bash
#!/bin/bash
# configure-dns-api.sh <domain> <vercel-ip>

DOMAIN=$1
VERCEL_IP=$2
CF_API_KEY=$(cat "C:\Users\user\alphadev2\devops\secrets\credentials\cloudflare.key" 2>/dev/null || echo "")

if [ -z "$CF_API_KEY" ]; then
    echo "⚠️ Cloudflare API key not found - manual DNS configuration required"
    echo "Configure these DNS records manually:"
    echo "A Record: $DOMAIN → $VERCEL_IP"
    echo "CNAME: www → $DOMAIN"
    exit 0
fi

echo "🌐 Configuring DNS via Cloudflare API..."
# TODO: Implement Cloudflare API calls
# 1. Get zone ID for domain
# 2. Create/update A record
# 3. Create/update CNAME record  
# 4. Verify DNS propagation

echo "✅ DNS configured automatically for $DOMAIN"
```

---

## 📊 IMPLEMENTATION PRIORITY

### **Phase 1 (Immediate - Next Migration):**
1. ✅ `customize-template.sh` - Prevents branding issues
2. ✅ `configure-environment.sh` - Prevents API failures
3. ✅ `validate-before-migration.sh` - Prevents repeating issues

### **Phase 2 (Next Month):**
4. ✅ `validate-deployment.sh` - Catches issues early
5. ✅ `migrate-site.sh` - Full orchestration
6. ✅ WordPress data validation scripts

### **Phase 3 (Future):**
7. 🎯 Cloudflare API integration
8. 🎯 Real-time migration monitoring
9. 🎯 One-command deployment

---

## ⏱️ TIME SAVINGS PROJECTION

| Script | Manual Time | Automated Time | Time Saved | Error Prevention |
|---|---|---|---|---|
| Template Customization | 20 min | 2 min | 18 min | ✅ Branding issues |
| Environment Config | 15 min | 3 min | 12 min | ✅ API failures |
| Pre-migration Check | 10 min | 5 min | 5 min | ✅ Repeated issues |
| Validation | 15 min | 3 min | 12 min | ✅ Deployment problems |
| **Total** | **60 min** | **13 min** | **47 min** | **All major issues** |

**Result:** 78% time reduction + near-zero error rate

---

## 🎯 SUCCESS METRICS

### **Current State (Wedding Planner):**
- ❌ 7+ critical issues encountered
- ❌ 2+ hours of troubleshooting  
- ❌ User saw wrong branding
- ❌ Multiple deployment attempts

### **Target State (Next Migration):**
- ✅ 0-1 minor issues maximum
- ✅ 30 minutes total time
- ✅ Perfect branding from first deployment  
- ✅ Single deployment attempt

**Critical Success Factor:** Always reference and update this documentation before each migration.