# Vercel Deployment Guide - Updated Methods

## 🚨 CRITICAL UPDATE: TOKEN PARAMETER METHOD

### ❌ BROKEN METHOD (Environment Variable)
```bash
# THIS DOES NOT WORK
export VERCEL_TOKEN=5aD1vf5YifXj5oak2JZjO1Wb
vercel --prod --yes
# Result: "No existing credentials found"
```

### ✅ WORKING METHOD (Token Parameter)
```bash
# THIS WORKS PERFECTLY
vercel --prod --yes --token="5aD1vf5YifXj5oak2JZjO1Wb"
```

## 🔧 COMPLETE DEPLOYMENT PROCESS

### 1. Clean Token (Remove BOM Characters)
```bash
# Token files may have BOM prefix that breaks authentication
TOKEN=$(sed 's/^\xEF\xBB\xBF//' "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token")
echo "Cleaned token: $TOKEN"
```

### 2. Test Token First
```bash
# Always verify token works before deployment
vercel whoami --token="$TOKEN"
# Should show: websitedn-9826
```

### 3. Deploy with Token Parameter
```bash
# Deploy to production
vercel --prod --yes --token="$TOKEN"
```

## 🛡️ TOKEN TROUBLESHOOTING

### Check Token File Issues
```bash
# Check for BOM characters
od -c "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token"
# Should NOT start with: 357 273 277 (BOM)

# Clean token if needed
sed 's/^\xEF\xBB\xBF//' vercel.token > vercel_clean.token
```

### Environment Variable vs Parameter
| Method | Status | Notes |
|--------|--------|-------|
| `export VERCEL_TOKEN=` | ❌ BROKEN | CLI ignores env var |
| `--token="value"` | ✅ WORKS | Direct parameter method |
| `vercel login` | ✅ WORKS | Interactive login |

## 📋 DEPLOYMENT CHECKLIST

### Pre-Deployment
- [ ] Token cleaned of BOM characters
- [ ] `vercel whoami --token="$TOKEN"` succeeds
- [ ] Project files ready in current directory
- [ ] `.env.production` has correct WordPress credentials

### Deployment Command
```bash
# Standard deployment command
vercel --prod --yes --token="$(sed 's/^\xEF\xBB\xBF//' C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token)"
```

### Post-Deployment
- [ ] Build completes successfully
- [ ] WordPress API connections work (no 401 errors)
- [ ] Site accessible at returned URL
- [ ] Content loads properly (not "No posts found")

## 🎯 INTEGRATION WITH MIGRATION PROCESS

### Phase 3: Deployment (5 minutes)
```bash
# 1. Verify token
TOKEN=$(sed 's/^\xEF\xBB\xBF//' "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token")
vercel whoami --token="$TOKEN"

# 2. Deploy
cd "C:\Users\user\alphadev2\migration\projects\DOMAIN-headless"
vercel --prod --yes --token="$TOKEN"

# 3. Verify deployment
curl -I https://RETURNED-URL
```

---

**Key Takeaway:** Never use environment variables for Vercel token. Always use `--token` parameter with BOM-cleaned token value.