# Credentials Master Template & Setup Guide

**AlphaDev2 Development Environment**  
**Date:** 2025-01-11  
**Security:** Template Only - No Real Values

## 🔐 **Security Guidelines**

### **❌ NEVER DO:**
- Paste real credentials in AI chats (including Claude Code CLI)
- Commit credentials to Git repositories
- Share credentials in plain text files
- Store production credentials locally

### **✅ SAFE APPROACH:**
1. Use this template to know what to collect
2. Populate credentials locally using secure methods
3. Use environment variables and secure files
4. Follow the credential hierarchy (System > Global > Project)

## 📋 **Credentials Inventory**

### **🔧 Core Development Tools**

#### **Git & Version Control**
```bash
# Required for Git commits
GIT_USER_NAME="Your Full Name"
GIT_USER_EMAIL="your.email@domain.com"

# GitHub Integration
GITHUB_USERNAME="your_username"
GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"  # Personal Access Token
# Scopes needed: repo, workflow, write:packages, read:user

# Git Configuration Commands:
# git config --global user.name "Your Full Name"  
# git config --global user.email "your.email@domain.com"
# git config --global credential.helper store
```

#### **Deployment & Hosting**
```bash
# Vercel
VERCEL_TOKEN="xxxxxxxxxx"  # From: vercel login or dashboard
VERCEL_ORG_ID="team_xxxxxxxxxx"  # Optional: for team deployments
VERCEL_PROJECT_ID="prj_xxxxxxxxxx"  # Per project

# Netlify (Alternative)
NETLIFY_AUTH_TOKEN="xxxxxxxxxx"
NETLIFY_SITE_ID="xxxxxxxxxx"

# Railway (Alternative) 
RAILWAY_TOKEN="xxxxxxxxxx"

# Heroku (Alternative)
HEROKU_API_KEY="xxxxxxxxxx"
```

### **🤖 AI & ML Services**

```bash
# OpenAI
OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
OPENAI_ORG_ID="org-xxxxxxxxxx"  # Optional

# Anthropic Claude
ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxx"

# Google AI
GOOGLE_AI_API_KEY="xxxxxxxxxx"
GOOGLE_AI_PROJECT_ID="your-project-id"

# Hugging Face
HUGGINGFACE_API_TOKEN="hf_xxxxxxxxxxxxxxxxxxxx"

# Replicate
REPLICATE_API_TOKEN="r8_xxxxxxxxxxxxxxxxxxxx"
```

### **💳 Payment Processing**

```bash
# Stripe (Development)
STRIPE_PUBLISHABLE_KEY="pk_test_xxxxxxxxxxxxxxxxxxxx"
STRIPE_SECRET_KEY="sk_test_xxxxxxxxxxxxxxxxxxxx"
STRIPE_WEBHOOK_SECRET="whsec_xxxxxxxxxxxxxxxxxxxx"

# PayPal (Development)
PAYPAL_CLIENT_ID="xxxxxxxxxx"
PAYPAL_CLIENT_SECRET="xxxxxxxxxx"
PAYPAL_MODE="sandbox"  # or "live" for production
```

### **📧 Email & Communication**

```bash
# SendGrid
SENDGRID_API_KEY="SG.xxxxxxxxxxxxxxxxxxxx"
SENDGRID_FROM_EMAIL="noreply@yourdomain.com"

# Mailgun
MAILGUN_API_KEY="key-xxxxxxxxxxxxxxxxxxxx"
MAILGUN_DOMAIN="yourdomain.com"

# Twilio
TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxx"
TWILIO_AUTH_TOKEN="xxxxxxxxxxxxxxxxxxxx"
TWILIO_PHONE_NUMBER="+1234567890"

# Discord (for notifications)
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/xxx/xxx"

# Slack
SLACK_BOT_TOKEN="xoxb-xxxxxxxxxxxxxxxxxxxx"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/xxx/xxx/xxx"
```

### **🗄️ Databases & Storage**

```bash
# Supabase (PostgreSQL-based Backend-as-a-Service)
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # Public key
SUPABASE_SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  # Admin key - server only!
SUPABASE_JWT_SECRET="your-jwt-secret"
SUPABASE_DB_URL="postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres"

# Next.js + Supabase
NEXT_PUBLIC_SUPABASE_URL="https://your-project.supabase.co"
NEXT_PUBLIC_SUPABASE_ANON_KEY="your_anon_key"

# PostgreSQL (Local/Self-hosted)
DATABASE_URL="postgresql://username:password@localhost:5432/dbname"
POSTGRES_USER="your_username"
POSTGRES_PASSWORD="your_password" 
POSTGRES_DB="your_database"

# MySQL
MYSQL_HOST="localhost"
MYSQL_USER="your_username"
MYSQL_PASSWORD="your_password"
MYSQL_DATABASE="your_database"

# MongoDB
MONGODB_URI="mongodb://username:password@localhost:27017/dbname"
MONGODB_URL="mongodb+srv://user:pass@cluster.mongodb.net/db"

# Redis
REDIS_URL="redis://localhost:6379"
REDIS_PASSWORD="your_redis_password"

# AWS Services
AWS_ACCESS_KEY_ID="AKIAxxxxxxxxxxxxxxxxxxxx"
AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxx"
AWS_REGION="us-east-1"
AWS_S3_BUCKET="your-bucket-name"

# Google Cloud
GOOGLE_CLOUD_PROJECT_ID="your-project-id"
GOOGLE_CLOUD_KEY_FILE="path/to/service-account.json"
GOOGLE_STORAGE_BUCKET="your-bucket-name"

# Azure
AZURE_STORAGE_ACCOUNT="yourstorageaccount"
AZURE_STORAGE_KEY="xxxxxxxxxxxxxxxxxxxx"
AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=https;..."
```

### **🔐 Authentication & OAuth**

```bash
# Google OAuth
GOOGLE_CLIENT_ID="xxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com"
GOOGLE_CLIENT_SECRET="GOCSPX-xxxxxxxxxxxxxxxxxxxx"

# GitHub OAuth  
GITHUB_CLIENT_ID="Iv1.xxxxxxxxxxxxxxxxxxxx"
GITHUB_CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxx"

# Facebook OAuth
FACEBOOK_APP_ID="xxxxxxxxxxxxxxxxxxxx"
FACEBOOK_APP_SECRET="xxxxxxxxxxxxxxxxxxxx"

# Twitter OAuth
TWITTER_API_KEY="xxxxxxxxxxxxxxxxxxxx"
TWITTER_API_SECRET="xxxxxxxxxxxxxxxxxxxx"
TWITTER_ACCESS_TOKEN="xxxxxxxxxxxxxxxxxxxx"
TWITTER_ACCESS_TOKEN_SECRET="xxxxxxxxxxxxxxxxxxxx"

# Auth0
AUTH0_DOMAIN="your-domain.auth0.com"
AUTH0_CLIENT_ID="xxxxxxxxxxxxxxxxxxxx"
AUTH0_CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxx"

# Firebase
FIREBASE_API_KEY="xxxxxxxxxxxxxxxxxxxx"
FIREBASE_AUTH_DOMAIN="your-project.firebaseapp.com"
FIREBASE_PROJECT_ID="your-project-id"
```

### **📊 Analytics & Monitoring**

```bash
# Google Analytics
GOOGLE_ANALYTICS_ID="G-XXXXXXXXXX"  # GA4
GOOGLE_ANALYTICS_TRACKING_ID="UA-XXXXXXXXX-X"  # Universal Analytics

# Mixpanel
MIXPANEL_TOKEN="xxxxxxxxxxxxxxxxxxxx"

# PostHog
POSTHOG_API_KEY="phc_xxxxxxxxxxxxxxxxxxxx"
POSTHOG_HOST="https://app.posthog.com"

# Sentry
SENTRY_DSN="https://xxxxxxxxxxxxxxxxxxxx@sentry.io/xxxxxxx"
SENTRY_AUTH_TOKEN="xxxxxxxxxxxxxxxxxxxx"

# DataDog
DATADOG_API_KEY="xxxxxxxxxxxxxxxxxxxx"
DATADOG_APP_KEY="xxxxxxxxxxxxxxxxxxxx"
```

### **🔍 Search & APIs**

```bash
# Algolia
ALGOLIA_APP_ID="XXXXXXXXXX"
ALGOLIA_API_KEY="xxxxxxxxxxxxxxxxxxxx"
ALGOLIA_SEARCH_KEY="xxxxxxxxxxxxxxxxxxxx"

# Elasticsearch
ELASTICSEARCH_URL="https://localhost:9200"
ELASTICSEARCH_USERNAME="elastic"
ELASTICSEARCH_PASSWORD="xxxxxxxxxxxxxxxxxxxx"

# Mapbox
MAPBOX_ACCESS_TOKEN="pk.xxxxxxxxxxxxxxxxxxxx"

# News API
NEWS_API_KEY="xxxxxxxxxxxxxxxxxxxx"

# Weather API
OPENWEATHER_API_KEY="xxxxxxxxxxxxxxxxxxxx"
```

## 📁 **File Structure for Credentials**

### **1. Global Development Environment**
```bash
# File: secrets/.env.global
# Core development credentials that are reused across projects

# Version Control
GITHUB_TOKEN=ghp_your_token_here
GITHUB_USERNAME=your_username
GIT_USER_NAME=Your Full Name
GIT_USER_EMAIL=your.email@domain.com

# Deployment
VERCEL_TOKEN=your_vercel_token

# Development APIs
OPENAI_API_KEY=sk-your_dev_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here

# Local Services
DATABASE_URL=postgresql://localhost:5432/dev_db
REDIS_URL=redis://localhost:6379

# Development Settings
NODE_ENV=development
DEV_PORT_START=3000
DEV_PORT_END=3100
LOG_LEVEL=debug
```

### **2. Individual Credential Files (More Secure)**
```bash
# File: secrets/credentials/github.token
ghp_your_actual_token_here

# File: secrets/credentials/vercel.token  
your_vercel_token_here

# File: secrets/credentials/openai.key
sk-your_openai_key_here
```

### **3. Project-Specific Environment**
```bash
# File: projects/my-app/.env.local
# Project-specific secrets

APP_NAME=my-awesome-app
PORT=3001
DATABASE_NAME=my_app_dev
JWT_SECRET=your_unique_jwt_secret_for_this_app

# Project-specific API keys
STRIPE_WEBHOOK_SECRET=whsec_project_specific
GOOGLE_CLIENT_ID=project_specific_oauth_id
```

## 🛠️ **Setup Commands**

### **1. Secure Credential Collection Script**
```powershell
# File: scripts/setup-credentials.ps1
Write-Host "🔐 AlphaDev2 Credentials Setup" -ForegroundColor Cyan

# Create secure credential files
$secretsPath = "C:\Users\user\alphadev2\secrets"

# GitHub Setup
Write-Host "`n📝 Setting up GitHub credentials..." -ForegroundColor Yellow
$githubToken = Read-Host -Prompt "Enter GitHub Personal Access Token (or press Enter to skip)" -AsSecureString
if ($githubToken.Length -gt 0) {
    $githubTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($githubToken))
    $githubTokenPlain | Out-File -FilePath "$secretsPath\credentials\github.token" -Encoding UTF8 -NoNewline
    Write-Host "✅ GitHub token saved securely" -ForegroundColor Green
}

# Vercel Setup  
Write-Host "`n📝 Setting up Vercel credentials..." -ForegroundColor Yellow
$vercelToken = Read-Host -Prompt "Enter Vercel Auth Token (or press Enter to skip)" -AsSecureString
if ($vercelToken.Length -gt 0) {
    $vercelTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($vercelToken))
    $vercelTokenPlain | Out-File -FilePath "$secretsPath\credentials\vercel.token" -Encoding UTF8 -NoNewline
    Write-Host "✅ Vercel token saved securely" -ForegroundColor Green
}

Write-Host "`n🎉 Credential setup complete!" -ForegroundColor Cyan
```

### **2. Environment Variable Setup**
```powershell
# Set system environment variables for frequently used credentials
[Environment]::SetEnvironmentVariable("GITHUB_USERNAME", "your_username", "User")
[Environment]::SetEnvironmentVariable("GIT_USER_NAME", "Your Full Name", "User")
[Environment]::SetEnvironmentVariable("GIT_USER_EMAIL", "your.email@domain.com", "User")
```

### **3. Git Configuration**
```bash
# Global Git setup
git config --global user.name "Your Full Name"
git config --global user.email "your.email@domain.com"
git config --global init.defaultBranch main
git config --global credential.helper store
```

## 🔄 **Credential Rotation Schedule**

### **Monthly (High Security)**
- [ ] GitHub Personal Access Tokens
- [ ] Vercel Auth Tokens  
- [ ] Production API keys (stored externally)

### **Quarterly (Medium Security)**
- [ ] Development API keys
- [ ] OAuth application secrets
- [ ] Database passwords

### **Annually (Low Security)**
- [ ] Service account keys
- [ ] Analytics tokens
- [ ] Non-sensitive API keys

## 📋 **Security Audit Checklist**

### **Before Each Commit**
- [ ] No credentials in code files
- [ ] .env.local in .gitignore
- [ ] Only .env.example files committed
- [ ] No API keys in configuration files

### **Weekly Review**
- [ ] Check for credential leaks in recent commits
- [ ] Verify credential file permissions
- [ ] Review active API keys and tokens
- [ ] Monitor for unused credentials

### **Monthly Security Review**
- [ ] Rotate development credentials
- [ ] Review access logs for APIs
- [ ] Update this master template
- [ ] Audit team member access

## 🚨 **Emergency Response**

### **If Credentials Are Compromised:**
1. **Immediate**: Revoke/deactivate the credential
2. **Assess**: Check scope of potential exposure  
3. **Rotate**: Generate new credentials
4. **Update**: All environments using the credential
5. **Monitor**: For unauthorized usage
6. **Document**: Incident for future prevention

### **Git History Cleanup (if needed)**
```bash
# Remove sensitive file from Git history
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch path/to/sensitive/file' \
--prune-empty --tag-name-filter cat -- --all

# Alternative: Use BFG Repo-Cleaner (recommended)
java -jar bfg-1.14.0.jar --delete-files sensitive-file.env
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

## 📚 **Where to Get Credentials**

### **Development Accounts (Free Tiers)**
- [GitHub Personal Access Tokens](https://github.com/settings/tokens)
- [Vercel Account Tokens](https://vercel.com/account/tokens)  
- [OpenAI API Keys](https://platform.openai.com/api-keys)
- [Stripe Test Keys](https://dashboard.stripe.com/test/apikeys)
- [SendGrid API Keys](https://app.sendgrid.com/settings/api_keys)

### **Setup Priority Order**
1. **Essential**: GitHub, Git config
2. **Deployment**: Vercel or preferred platform
3. **Development**: Local database, Redis
4. **Optional**: AI APIs, payment processors
5. **Later**: Analytics, monitoring tools

---

**⚠️ Security Reminder: Never commit this file with real credentials! This is a template only.**

**Next Step: Use the secure setup script to populate credentials locally.**

**Last Updated:** 2025-01-11