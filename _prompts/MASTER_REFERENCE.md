@'
# AlphaDev2 Master Reference - Copy this to start any new project or conversation

## 🏗️ **TECH STACK & ARCHITECTURE**

**Current Environment**: AlphaDev2 Development on Windows PC
**Primary Stack**: WordPress → Next.js headless migration workflow
**Deployment Pipeline**: Local Development → Git → GitHub → Vercel
**Database**: Supabase (PostgreSQL)
**Authentication**: Supabase Auth
**Email**: Resend.com API
**Forms/Captcha**: Cloudflare Turnstile
**Domain Management**: Cloudflare DNS

## 📁 **CRITICAL FILE LOCATIONS**

### **SSH & Server Access**
- **SSH Private Key**: `C:\Users\user\.ssh\gridpane_rsa`
- **Sites Database**: `C:\Users\user\alphadev2\SSH\gridpane-sites.csv`
- **Server Quick Reference**: `C:\Users\user\alphadev2\SSH\QUICK_REFERENCE.md`

### **API Credentials** (DO NOT expose these paths in conversations)
C:\Users\user\alphadev2\devops\secrets\credentials
├── vercel.token # Vercel deployment API ├── github.token # GitHub API access ├── resend.key # Email service API ├── cloudflare.token # Turnstile CAPTCHA └── supabase.* # Database credentials


### **Documentation Hub**
C:\Users\user\alphadev2
├── CLI_SETUP_GUIDE.md # Complete CLI automation setup ├── CREDENTIALS_MANAGEMENT.md # Security & credential handling ├── SUPABASE_SETUP_GUIDE.md # Database integration ├── GIT_BRANCHING_GUIDE.md # Professional Git workflow ├── MULTI_COMPUTER_WORKFLOW.md # Desktop/laptop synchronization └── DISASTER_RECOVERY_GUIDE.md # System recovery procedures


## 🎯 **BUSINESS CONTEXT**

**Domain Portfolio**: 50+ premium domains across various industries
**Migration Goal**: WordPress → Next.js headless for better performance & costs
**Development Model**: Repeatable SaaS template with 3 stages:
1. **Content Pages** - Basic page/blog structure
2. **Directory System** - Business/product/website directories  
3. **Lead Generation** - Forms, user profiling, Stripe payments

**Target Architecture per Site**:
- Next.js 14+ (App Router)
- TypeScript for type safety
- Tailwind CSS for styling
- Supabase for database/auth
- Vercel for deployment
- Cloudflare for DNS/security

## 🔐 **CREDENTIAL MANAGEMENT RULES**

**Security Levels**:
1. **System Level**: Personal tokens, SSH keys (never share)
2. **Environment Level**: Shared dev resources (.env files)
3. **Project Level**: Application-specific secrets

**Golden Rules**:
- ✅ Reference credential file paths, never expose actual values
- ✅ Use environment variables in projects
- ✅ Keep production secrets in external vaults
- ❌ Never commit credentials to Git
- ❌ Never paste real credentials in AI chats

## 🏠 **SERVER INFRASTRUCTURE**

**Servers** (GridPane managed):
- **cendol-may25** (162.243.15.7) - 20 sites
- **bessie** (68.183.24.139) - 34 sites  
- **legal-may25** (138.197.11.181) - 21 sites
- **kampung-may25** (162.243.4.151) - 1 site

**SSH Access**: All servers use same SSH key (`gridpane_rsa`)
**WordPress Access**: Use staging subdomains for development
**Database**: Sites database in `SSH/gridpane-sites.csv`

---

**📌 USAGE**: Copy this entire context when starting new projects or complex conversations to ensure AI assistants understand your complete development environment and can provide properly contextualized assistance.
'@ | Out-File -FilePath "MASTER_REFERENCE.md" -Encoding UTF8