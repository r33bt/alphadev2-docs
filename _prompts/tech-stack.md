@'
# AlphaDev2 Tech Stack Reference

## 🏗️ **PRIMARY TECHNOLOGY STACK**

### **Frontend Framework**
- **Next.js 14+** (App Router)
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **React Hook Form** for form management
- **Zod** for schema validation

### **Backend & Database**
- **Supabase** (PostgreSQL + Auth + Real-time)
- **WordPress REST API** (headless CMS during migration)
- **Vercel Edge Functions** for serverless logic

### **Authentication & Security**
- **Supabase Auth** (email, OAuth providers)
- **Cloudflare Turnstile** (CAPTCHA protection)
- **Environment variables** for secrets management

### **Email & Communication**
- **Resend.com** (transactional emails)
- **React Email** (email templates)

### **Development Tools**
- **Git** with feature branch workflow
- **GitHub CLI** for repository management
- **Vercel CLI** for deployment management
- **Node.js 22.12.0** and **npm 10.9.0**

## 🏠 **INFRASTRUCTURE SETUP**

### **Server Details**
- **cendol-may25** (162.243.15.7) - 20 WordPress sites
- **bessie** (68.183.24.139) - 34 WordPress sites  
- **legal-may25** (138.197.11.181) - 21 WordPress sites
- **kampung-may25** (162.243.4.151) - 1 WordPress site

## 🚀 **STANDARD PROJECT ARCHITECTURE**

### **Environment Variables Pattern**
```env
# WordPress API (during migration phase)
WORDPRESS_API_URL=https://staging.domain.com/wp-json/wp/v2
WORDPRESS_USERNAME=migration-admin
WORDPRESS_APP_PASSWORD=generated-password

# Supabase Database
NEXT_PUBLIC_SUPABASE_URL=https://project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiI...

# Email Service
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxx

# CAPTCHA Protection
NEXT_PUBLIC_TURNSTILE_SITE_KEY=0x4AAAAAxxxxxxxxxx
TURNSTILE_SECRET_KEY=0x4AAAAAxxxxxxxxxx
🔄 DEPLOYMENT WORKFLOW
Local Development → GitHub → Vercel → Production
🎯 PROJECT STAGES
Content Foundation - Pages, blog, WordPress migration
Directory Features - Business/product directories
SaaS Features - Auth, payments, subscriptions '@ | Out-File -FilePath "core\tech-stack.md" -Encoding UTF8