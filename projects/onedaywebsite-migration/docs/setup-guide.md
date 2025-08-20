# Setup Guide
## Initial Environment Configuration

### Prerequisites

#### System Requirements
- Node.js 18+ installed
- Git installed and configured
- curl and wget available
- Python 3.8+ (for content parsing)
- Text editor or IDE

#### Account Setup Required
1. **GitHub Account** with Personal Access Token
2. **Vercel Account** linked to GitHub
3. **Supabase Account** (optional, for enhanced features)

#### Verification Commands
```bash
# Verify installations
node --version    # Should be 18+
git --version     # Any recent version
curl --version    # Should be available
python3 --version # Should be 3.8+
```

### Step 1: Project Setup

#### 1.1 Create Project Directory
```bash
mkdir onedaywebsite-migration
cd onedaywebsite-migration

# Create directory structure
mkdir -p {docs,scripts,templates,data,generated-sites}
mkdir -p scripts/utils
mkdir -p templates/{nextjs-components,config-files,deployment}
mkdir -p data/{extracted-content}
```

#### 1.2 Initialize Git Repository
```bash
git init
git remote add origin https://github.com/YOUR_USERNAME/onedaywebsite-migration.git
```

### Step 2: Tool Authentication

#### 2.1 GitHub CLI Setup
```bash
# Install GitHub CLI (if not installed)
# macOS: brew install gh
# Ubuntu: sudo apt install gh

# Authenticate
gh auth login
# Follow interactive prompts
```

#### 2.2 Vercel CLI Setup
```bash
# Install Vercel CLI
npm install -g vercel@latest

# Authenticate
vercel login
# Follow browser authentication
```

#### 2.3 Supabase CLI Setup (Optional)
```bash
# Install Supabase CLI
npm install -g supabase@latest

# Authenticate
supabase login
# Follow browser authentication
```

### Step 3: Environment Configuration

#### 3.1 Create Environment File
```bash
# Create .env file
cat > .env << 'EOF'
# Site Configuration
SOURCE_DOMAIN="onedaywebsite.org"
TARGET_DOMAIN="onedaywebsite.org"

# GitHub Configuration
GITHUB_USERNAME="your_username_here"
GITHUB_REPO_NAME="onedaywebsite-nextjs"

# Vercel Configuration
VERCEL_ORG_ID="your_vercel_org_id"

# Optional: Supabase Configuration
SUPABASE_ORG_ID="your_supabase_org_id"

# Optional: MainWP Configuration (for scaling)
MAINWP_DASHBOARD_URL="https://your-mainwp-dashboard.com"
MAINWP_BEARER_TOKEN="your_mainwp_token_here"
EOF
```

#### 3.2 Configure Git Ignore
```bash
cat > .gitignore << 'EOF'
# Environment files
.env
.env.local

# Node modules
node_modules/
npm-debug.log*

# Build outputs
.next/
out/
build/

# Runtime data
*.log
*.pid
*.seed

# Directory for generated sites
generated-sites/*/node_modules/
generated-sites/*/.next/

# Extracted content (may contain sensitive data)
data/extracted-content/

# OS generated files
.DS_Store
Thumbs.db
EOF
```

### Step 4: Validation & Testing

#### 4.1 Test External Access
```bash
# Test site accessibility
curl -I https://www.onedaywebsite.org/
# Should return 200 OK

# Test sitemap access
curl -s https://www.onedaywebsite.org/sitemap.xml | head -10
# Should return XML sitemap data
```

#### 4.2 Test Tool Authentication
```bash
# Test GitHub access
gh repo list --limit 1
# Should list your repositories

# Test Vercel access
vercel whoami
# Should display your username

# Test Supabase access (if configured)
supabase projects list
# Should list your projects
```

#### 4.3 Test Content Extraction
```bash
# Test sample content extraction
curl -s "https://www.onedaywebsite.org/about/" | grep -oP '<title>\K[^<]*'
# Should return page title
```

### Step 5: Project Configuration Files

#### 5.1 Install Dependencies
```bash
# Install dependencies
npm install

# Set script permissions (Linux/macOS)
chmod +x scripts/*.sh scripts/utils/*.sh
```

### Step 6: Ready State Verification

#### 6.1 Checklist
- [ ] Project directory structure created
- [ ] All CLI tools authenticated
- [ ] Environment variables configured  
- [ ] Site accessibility verified
- [ ] Dependencies installed
- [ ] Git repository initialized

#### 6.2 Final Test
```bash
# Run environment check
echo "Checking environment setup..."
echo "Node version: $(node --version)"
echo "Git configured: $(git config user.name)"
echo "GitHub authenticated: $(gh auth status --hostname github.com | grep Logged)"
echo "Vercel authenticated: $(vercel whoami)"
echo "Source site accessible: $(curl -o /dev/null -s -w "%{http_code}" https://www.onedaywebsite.org/)"

echo "Setup complete! Ready to run migration scripts."
```

### Next Steps
Once setup is complete, proceed to execute the migration scripts in order:
1. `npm run analyze` - Analyze site structure
2. `npm run extract` - Extract all content  
3. `npm run generate` - Generate Next.js site
4. `npm run deploy` - Deploy to Vercel

### Troubleshooting Common Setup Issues

#### Authentication Issues
```bash
# Clear and re-authenticate
gh auth logout
gh auth login

vercel logout
vercel login
```

#### Permission Issues
```bash
# Fix script permissions
chmod +x scripts/*.sh
```

#### Network Issues
```bash
# Test connectivity
ping google.com
curl -I https://api.github.com
```