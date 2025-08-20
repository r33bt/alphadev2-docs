# Credentials & Environment Management Guide

**AlphaDev2 Development Environment**  
**Date:** 2025-01-11  
**Security Level:** Development Environment

## 🔐 **Security Philosophy**

### **The Three-Layer Approach**
1. **System Level** - Personal tokens, global credentials
2. **Environment Level** - Shared development resources  
3. **Project Level** - Application-specific secrets

### **Golden Rules**
- ✅ Never commit real credentials to Git
- ✅ Use environment-specific files (.env.development, .env.local)
- ✅ Keep production secrets in external vaults (never local)
- ✅ Use templates (.env.example) for onboarding
- ❌ Never store production credentials locally

## 📁 **Directory Structure**

```
alphadev2/
├── 📄 .gitignore                   # Global ignore rules
├── 📁 secrets/                     # 🚫 NOT in Git
│   ├── .env.global                 # Global dev credentials
│   ├── .env.local                  # Local overrides
│   ├── credentials/                # API keys, certificates
│   │   ├── github.token
│   │   ├── vercel.token
│   │   ├── openai.key
│   │   └── certificates/
│   └── templates/                  # Templates for new projects
│       ├── .env.template
│       ├── .env.node.template
│       └── .env.python.template
└── 📁 projects/
    └── web/
        └── my-app/
            ├── .env.example        # ✅ Committed template
            ├── .env.local          # 🚫 Your real values
            ├── .env.development    # 🚫 Dev environment
            └── .gitignore          # Project-specific ignores
```

## 🎯 **Credential Categories & Storage Locations**

| Credential Type | Storage Location | Example | Security Level |
|---|---|---|---|
| **Personal Access Tokens** | System Environment | GitHub PAT, Vercel token | High |
| **Development API Keys** | `secrets/.env.global` | OpenAI dev key, test Stripe | Medium |
| **Shared Dev Services** | `secrets/.env.global` | Local Redis, PostgreSQL | Low |
| **Project Secrets** | `project/.env.local` | App JWT secret, database name | Medium |
| **Production Secrets** | External Vault | Production API keys | Critical |

## 🛠️ **Setup Instructions**

### **1. Create Secure Directory Structure**

```powershell
# Create credentials structure
$secretsPath = "C:\Users\user\alphadev2\secrets"
New-Item -Path "$secretsPath" -ItemType Directory -Force
New-Item -Path "$secretsPath\credentials" -ItemType Directory -Force
New-Item -Path "$secretsPath\templates" -ItemType Directory -Force
New-Item -Path "$secretsPath\certificates" -ItemType Directory -Force

# Set restrictive permissions (Windows)
icacls "$secretsPath" /inheritance:r /grant:r "$env:USERNAME:(OI)(CI)F" /t

Write-Host "✅ Secure credentials structure created!" -ForegroundColor Green
```

### **2. Create Global .gitignore**

```gitignore
# File: alphadev2/.gitignore

# Credentials and Secrets
secrets/
*.env
!*.env.example
!*.env.template
credentials/
*.key
*.pem
*.p12
*.crt
*.pfx

# Development Files
.DS_Store
Thumbs.db
*.log
*.tmp
node_modules/
__pycache__/
.pytest_cache/
.coverage
*.pyc

# IDE and Editor Files
.vscode/settings.json
.vscode/launch.json
.idea/
*.swp
*.swo
*~

# OS Generated Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
```

### **3. Create Environment File Templates**

#### **Global Development Environment**
```bash
# File: secrets/.env.global
# Global development credentials and settings

# Development API Keys (non-production)
GITHUB_TOKEN=your_github_token_here
GITHUB_USERNAME=your_username
VERCEL_TOKEN=your_vercel_token_here
OPENAI_API_KEY=your_openai_dev_key_here

# Local Development Services
DATABASE_URL=postgresql://localhost:5432/dev_db
REDIS_URL=redis://localhost:6379
MAILCATCHER_URL=http://localhost:1080

# Development Ports Range
DEV_PORT_RANGE_START=3000
DEV_PORT_RANGE_END=3100

# Default Development Settings
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug
```

#### **Node.js Project Template**
```bash
# File: secrets/templates/.env.node.template
# Copy to your Node.js project and rename to .env.local

# Application Settings
APP_NAME=
APP_VERSION=1.0.0
PORT=3000
HOST=localhost

# Database
DATABASE_URL=
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_HOST=localhost
DB_PORT=5432

# Authentication
JWT_SECRET=
JWT_EXPIRES_IN=24h
SESSION_SECRET=

# Third-party Services
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
SENDGRID_API_KEY=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=

# Cloud Storage
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_BUCKET_NAME=
AWS_REGION=us-east-1

# Social Authentication
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
```

#### **Python/Django Project Template**
```bash
# File: secrets/templates/.env.python.template
# Copy to your Python project and rename to .env.local

# Django Settings
SECRET_KEY=
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# Database
DATABASE_URL=
DB_ENGINE=django.db.backends.postgresql
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_HOST=localhost
DB_PORT=5432

# Cache
REDIS_URL=redis://localhost:6379/0
CACHE_TTL=300

# Email
EMAIL_HOST=
EMAIL_PORT=587
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
EMAIL_USE_TLS=True

# API Keys
OPENAI_API_KEY=
STRIPE_SECRET_KEY=
```

## 🔧 **Environment Loading Patterns**

### **Node.js with dotenv**
```javascript
// config/environment.js
require('dotenv').config({ path: '.env.local' });           // Highest priority
require('dotenv').config({ path: '.env.development' });     // Environment specific
require('dotenv').config({ path: '../../../secrets/.env.global' }); // Global dev

module.exports = {
  port: process.env.PORT || 3000,
  database: process.env.DATABASE_URL,
  apiKeys: {
    github: process.env.GITHUB_TOKEN,
    openai: process.env.OPENAI_API_KEY,
  }
};
```

### **Python with python-dotenv**
```python
# config/settings.py
import os
from dotenv import load_dotenv

# Load environment variables in order of precedence
load_dotenv('../../../secrets/.env.global')  # Global first
load_dotenv('.env.development')               # Environment specific  
load_dotenv('.env.local')                     # Local overrides (highest priority)

# Configuration
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
DATABASE_URL = os.getenv('DATABASE_URL')
DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
```

### **Next.js Environment Loading**
```javascript
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },
  // Load additional env files
  experimental: {
    envFilePath: [
      '.env.local',
      '.env.development', 
      '../../../secrets/.env.global'
    ]
  }
}

module.exports = nextConfig
```

## 🚀 **Git Integration Setup**

### **Project-Specific .gitignore Template**
```gitignore
# Environment files
.env.local
.env.development.local
.env.test.local
.env.production.local

# Dependency directories
node_modules/
venv/
env/
__pycache__/

# Build outputs
dist/
build/
.next/
.nuxt/

# IDE
.vscode/settings.json
.idea/

# OS
.DS_Store
Thumbs.db
```

### **Initialize Git Repository**
```bash
# In each project directory
git init
git add .gitignore
git add .env.example
git commit -m "Initial commit with environment template"

# Connect to GitHub
git remote add origin https://github.com/username/project-name.git
git push -u origin main
```

## 📋 **Security Checklist**

### **Before Each Commit**
- [ ] Check for exposed credentials in code
- [ ] Verify .env.local is in .gitignore
- [ ] Ensure .env.example has placeholder values
- [ ] No API keys in configuration files
- [ ] No database passwords in code

### **Monthly Security Review**
- [ ] Rotate development API keys
- [ ] Review access tokens and permissions
- [ ] Update credential templates
- [ ] Check for leaked credentials in Git history
- [ ] Audit environment variable usage

### **New Project Setup**
- [ ] Copy appropriate .env template
- [ ] Create project-specific .gitignore
- [ ] Add .env.example with placeholders
- [ ] Configure environment loading
- [ ] Test credential access
- [ ] Document required environment variables

## 🆘 **Emergency Procedures**

### **Credential Leak Response**
1. **Immediate**: Revoke the exposed credential
2. **Assess**: Check Git history for exposure scope
3. **Rotate**: Generate new credentials
4. **Update**: All environments using the credential
5. **Monitor**: For unauthorized usage
6. **Document**: Incident for future prevention

### **Recovery Commands**
```bash
# Remove credential from Git history
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch path/to/file' \
--prune-empty --tag-name-filter cat -- --all

# Force push (dangerous - coordinate with team)
git push origin --force --all
git push origin --force --tags
```

## 📚 **Best Practices Summary**

1. **Separation of Concerns**: Global vs project-specific credentials
2. **Templates First**: Always create .env.example files  
3. **Least Privilege**: Only grant necessary permissions
4. **Regular Rotation**: Rotate development keys monthly
5. **Documentation**: Keep this guide updated
6. **Team Onboarding**: Use templates for new developers
7. **Production Isolation**: Never mix dev and prod credentials

## 🔗 **Related Resources**

- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Vercel CLI Authentication](https://vercel.com/docs/cli#commands/login)
- [Node.js dotenv Documentation](https://www.npmjs.com/package/dotenv)
- [Python python-dotenv Documentation](https://python-dotenv.readthedocs.io/)

---

**⚠️ Remember: This guide is for development environments only. Production credentials require enterprise-grade secret management solutions.**

**Last Updated:** 2025-01-11  
**Next Review:** 2025-02-11