# Migration Troubleshooting Guide - Common Issues & Solutions

## 🚨 TOP 10 MIGRATION BLOCKERS & SOLUTIONS

### 1. SSH CONNECTION TIMEOUT
**Symptom:** `ssh: connect to host X.X.X.X port 22: Connection timed out`

**❌ WRONG APPROACH:**
- Using DNS-resolved IP addresses
- Trying random server IPs
- Assuming SSH is broken

**✅ CORRECT SOLUTION:**
```bash
# ALWAYS use documented server IP
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 'echo "Test"'
# NOT DNS lookup results!
```

**Root Cause:** Confusing DNS resolution with server management access

---

### 2. VERCEL TOKEN AUTHENTICATION FAILED
**Symptom:** `Error: The specified token is not valid`

**❌ WRONG APPROACH:**
```bash
export VERCEL_TOKEN=token_value
vercel --prod --yes
```

**✅ CORRECT SOLUTION:**
```bash
vercel --prod --yes --token="$(sed 's/^\xEF\xBB\xBF//' C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token)"
```

**Root Cause:** Environment variables ignored, BOM characters in token file

---

### 3. WORDPRESS REST API 401 UNAUTHORIZED
**Symptom:** `{"code":"rest_unauthorized","message":"Only authenticated users can access the REST API."}`

**❌ WRONG APPROACH:**
- Trying random username/password combinations
- Assuming API is completely broken
- Giving up on API access

**✅ CORRECT SOLUTION:**
```bash
# 1. Check active security plugins
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 'cd /var/www/staging.DOMAIN/htdocs && wp plugin list --allow-root | grep -E "(active|wp-force-login|wordfence)"'

# 2. Deactivate blocking plugins
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 'cd /var/www/staging.DOMAIN/htdocs && wp plugin deactivate wp-force-login wordfence --allow-root'

# 3. Create application password
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 'cd /var/www/staging.DOMAIN/htdocs && wp user application-password create "USERNAME" "DOMAIN_API" --allow-root'
```

**Root Cause:** Security plugins blocking REST API access

---

### 4. WRONG WORDPRESS USERNAME
**Symptom:** Valid application password but still getting 401

**❌ WRONG APPROACH:**
- Assuming `sh3rlock22` works for all sites
- Using admin login usernames

**✅ CORRECT SOLUTION:**
```bash
# List actual WordPress users for each site
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 'cd /var/www/staging.DOMAIN/htdocs && wp user list --allow-root'
# Use the actual display_name or user_login from results
```

**Root Cause:** Each site has different WordPress admin users

---

### 5. NODE_MODULES COPY TIMEOUTS
**Symptom:** Copy operations taking 2+ minutes and timing out

**❌ WRONG APPROACH:**
```bash
cp -r ../previous-project/* ../new-project/  # Includes node_modules!
```

**✅ CORRECT SOLUTION:**
```bash
# Copy everything EXCEPT node_modules
cp -r ../previous-project/* ../new-project/ && rm -rf ../new-project/node_modules
# Then run fresh install
cd ../new-project && npm install
```

**Root Cause:** node_modules folders are massive and unnecessary to copy

---

### 6. DARK MODE CSS OVERRIDES
**Symptom:** Navigation appears broken, Tailwind styles don't work

**❌ WRONG APPROACH:**
- Debugging individual CSS rules
- Recreating Tailwind configuration
- Assuming template is broken

**✅ CORRECT SOLUTION:**
Check `globals.css` for dark mode overrides:
```css
/* This breaks everything: */
@media (prefers-color-scheme: dark) {
  /* ALL styles overridden */
}

/* Change to: */
/* Dark mode disabled to ensure Tailwind styles work correctly */
```

**Root Cause:** Dark mode CSS overrides ALL Tailwind styling

---

### 7. DOCUMENTATION IGNORANCE
**Symptom:** Repeating solved problems, wasting time on known issues

**❌ WRONG APPROACH:**
- Starting migration without reading docs
- Guessing solutions
- Debugging from scratch

**✅ CORRECT SOLUTION:**
```bash
# MANDATORY first step for ANY migration
cat C:\Users\user\alphadev2\SSH\COMPLETE_SETUP_DOCUMENTATION.md
cat C:\Users\user\alphadev2\migration\documentation\*
```

**Root Cause:** Not referencing existing documentation

---

### 8. BULK TEXT REPLACEMENT CORRUPTION
**Symptom:** Broken strings after using `sed` for bulk replacements

**❌ WRONG APPROACH:**
```bash
# This corrupts files
sed -i 's/OldSiteName/NewSiteName/g' **/*.tsx **/*.ts **/*.json
```

**✅ CORRECT SOLUTION:**
```bash
# Manual file-by-file updates
# Update: package.json, Header.tsx, layout.tsx, page.tsx, sitemap.ts, robots.ts
```

**Root Cause:** `sed` doesn't handle complex text patterns safely

---

### 9. VERCEL BUILD CACHE ISSUES
**Symptom:** Old content appearing on new deployment

**❌ WRONG APPROACH:**
- Assuming deployment failed
- Re-deploying multiple times
- Debugging application code

**✅ CORRECT SOLUTION:**
```bash
# Clear cache between deployments
vercel --prod --yes --token="TOKEN" --force
```

**Root Cause:** Vercel caches builds between deployments

---

### 10. MISSING .ENV.PRODUCTION UPDATE
**Symptom:** WordPress API calls fail on production but work locally

**❌ WRONG APPROACH:**
- Debugging API endpoints
- Checking network connectivity
- Assuming server issues

**✅ CORRECT SOLUTION:**
```bash
# Ensure .env.production has correct credentials
cat .env.production
# Must match newly created application password
```

**Root Cause:** Outdated WordPress credentials in environment file

---

## 🛡️ PREVENTION CHECKLIST

### Before Starting Migration
- [ ] Read ALL documentation in `/migration/documentation/`
- [ ] Test SSH: `ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 'echo "OK"'`
- [ ] Test Vercel: `vercel whoami --token="CLEAN_TOKEN"`
- [ ] Check domain exists: `ssh ... 'ls /var/www/ | grep DOMAIN'`

### During WordPress Setup  
- [ ] List users: `wp user list --allow-root`
- [ ] Check plugins: `wp plugin list --allow-root | grep -E "active|security"`
- [ ] Test API immediately after creating password
- [ ] Never reuse passwords across sites

### During Template Creation
- [ ] Copy files without node_modules
- [ ] Update files manually, one by one
- [ ] Verify dark mode CSS is disabled
- [ ] Test build locally if possible

### During Deployment
- [ ] Use `--token` parameter, not environment variables
- [ ] Clean BOM from token files
- [ ] Update .env.production with fresh credentials
- [ ] Verify WordPress API responses (not 401)

---

## 🎯 SUCCESS METRICS
- **Target Time:** 15-20 minutes total
- **Zero Infrastructure Issues:** Pre-check everything
- **Zero Token Problems:** Use --token method
- **Zero API 401s:** Deactivate security plugins first
- **Zero Documentation Lookups During Migration:** Read everything first

**Key Principle:** Spend 5 minutes checking infrastructure to save 45 minutes of troubleshooting.