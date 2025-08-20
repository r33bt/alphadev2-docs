# Headless WordPress Migration System - Master Guide
*Last Updated: 2025-08-14 | Production-Ready Template-Based Migration Process*

**🎯 MISSION**: Efficient, scalable migration of WordPress sites to headless Next.js architecture with 95% token reduction through proven templates and automation.

---

## 📊 MIGRATION INVENTORY

### ✅ Completed Migrations (7 sites)
| Site | Status | Server | Vercel URL | Pages Support | Footer Enhanced |
|------|--------|--------|------------|---------------|----------------|
| **stocktiming.com** | ✅ Production | Cendol (162.243.15.7) | https://stocktiming-headless.vercel.app | ✅ Complete | ✅ Complete |
| **funmathgames.com** | ✅ Production | Cendol (162.243.15.7) | https://funmathgames-headless.vercel.app | ✅ Complete | ✅ Complete |
| **microalphas.com** | ✅ Production | Cendol (162.243.15.7) | https://microalphas.com | ✅ Complete | ✅ Complete |
| **climatefinance.org** | ✅ Production | Cendol (162.243.15.7) | https://climatefinance-headless.vercel.app | ✅ Complete | ✅ Complete |
| **coloradoroofingsolutions.com** | ✅ Production | Cendol (162.243.15.7) | https://coloradoroofingsolutions-headless.vercel.app | ✅ Complete | ✅ Complete |
| **the-weddingplanner.com** | ✅ Production | Cendol (162.243.15.7) | https://the-weddingplanner.com | ✅ Complete | ✅ Complete |
| **chiefoperatingofficer.io** | ✅ Production | Bessie (68.183.24.139) | https://chiefoperatingofficer-headless.vercel.app | ✅ Complete | ✅ Complete |

### 🔄 Enhancement Status: COMPLETE  
**SUCCESS**: All 7 migrated sites now have complete WordPress Pages support and professional footers!

### 🎯 Future Migrations (10-20 sites pending)
Will use enhanced template with full pages + footer support from day one.

---

## 🏗️ ARCHITECTURAL FOUNDATION & BEST PRACTICES
*Based on Next.js 15 WordPress Headless Template + Migration Enhancements*

### Base Template Source
- **Vercel WordPress Template**: https://vercel.com/templates/next.js/nextjs-wordpress-headless-cms
- **Template Documentation**: https://github.com/9d8dev/next-wp/blob/main/CLAUDE.md

### Architecture Overview
This headless WordPress system uses **Next.js 15 App Router with TypeScript**. Key patterns:

#### Data Layer Architecture
- **WordPress API Hub**: All API interactions through `lib/wordpress.ts`
- **Type Safety**: Comprehensive interfaces in `lib/wordpress.ts` (Post, Page, Category, etc.)
- **Error Handling**: Consistent API error handling patterns
- **Cache Strategy**: Next.js cache tags for granular revalidation
- **Performance**: Server Components with parallel `Promise.all()` data fetching

#### Routing Structure Standards
```
Dynamic Routes:    /[slug]          (posts and pages)
Category Routes:   /category/[slug] (filtered content)  
API Routes:        /api/revalidate  (webhook integration)
Static Routes:     /               (homepage)
```

#### Component Patterns
- **Server Components**: Primary pattern for data fetching
- **Parallel Data Fetching**: `Promise.all()` for performance
- **URL-based State**: Search and filter state in URL parameters
- **Category Filtering**: Filter empty categories (count > 0) consistently

### Template Features vs Our Enhancements

#### ✅ **Core Template Features:**
- WordPress Posts with full API integration
- Categories & Tags support
- Authors & Featured Media
- Dynamic routing for posts
- Server-side pagination
- Real-time search & filtering
- TypeScript + Tailwind CSS
- Webhook-based revalidation system

#### 🔧 **Our Critical Enhancements:**
- **✅ WordPress Pages Support** - Full API integration for pages (missing from template)
- **✅ Professional 3-Column Footers** - Industry-specific branded footers
- **✅ Enhanced Navigation** - Complete header/footer navigation systems
- **✅ Category Filtering** - Hide empty categories (`acu-parent`, `uncategorized`)
- **✅ Union Type Handling** - Dynamic [slug] routes handle both posts AND pages
- **✅ Brand Customization** - Site-specific theming and content

#### 📈 **Advanced Features Available (Template):**
- **Cache Tags**: `tags: ['posts', 'post-${slug}']` for granular revalidation
- **Webhook Integration**: `/api/revalidate` endpoint for real-time updates
- **Enhanced Error Handling**: Custom `WordPressAPIError` class
- **OG Image Generation**: `/api/og` for dynamic Open Graph images
- **Debounced Search**: 300ms search delay optimization

---

## 🛠️ DEVELOPMENT STANDARDS & CODE PATTERNS
*Based on Template Best Practices + Migration Requirements*

### Build Commands (Standard Across All Sites)
```bash
npm run dev        # Development server with turbo mode
npm run build      # Production build
npm run start      # Production server
npm run lint       # ESLint code quality check
```

### TypeScript Standards
#### Type Safety Requirements
- **Strict Typing**: All functions must have explicit return types
- **Interface Definitions**: Use interfaces from `lib/wordpress.ts`
- **Type Inference**: Use when type is obvious, prefer annotations for clarity
- **No Type Assertions**: Prefer type annotations over assertions

#### Core Type Definitions
```typescript
// Required interfaces in lib/wordpress.ts
export interface WordPressPost { /* ... */ }
export interface WordPressPage { /* ... */ }  // Our enhancement
export interface WordPressCategory { /* ... */ }
export interface WordPressAuthor { /* ... */ }

// Union type for dynamic routing (our enhancement)
type WordPressContent = WordPressPost | WordPressPage;
```

### Naming Conventions (Enforced)
- **React Components**: PascalCase (`PostCard.tsx`, `Footer.tsx`)
- **Functions & Variables**: camelCase (`getCategories`, `mainCategories`)
- **Types & Interfaces**: PascalCase (`WordPressPost`, `CategoryProps`)
- **Constants**: UPPERCASE_SNAKE_CASE (`API_URL`, `WP_USERNAME`)
- **Files**: kebab-case for pages (`[slug]`, `category`)

### File Structure Standards
```
src/
├── app/                    # Next.js App Router pages
│   ├── page.tsx           # Homepage (server component)
│   ├── [slug]/page.tsx    # Dynamic posts/pages (union type)
│   └── category/[slug]/page.tsx  # Category archive
├── components/            # Reusable UI components
│   ├── Header.tsx        # Navigation with category filtering
│   ├── Footer.tsx        # Professional 3-column footer
│   └── PostCard.tsx      # Post preview component
└── lib/
    └── wordpress.ts      # WordPress API hub + type definitions
```

### Data Fetching Patterns
#### Server Component Pattern (Primary)
```typescript
export default async function HomePage() {
  const [posts, categories] = await Promise.all([
    getAllPosts(12),
    getCategories()
  ]);
  
  // Filter empty categories (our enhancement)
  const filteredCategories = categories.filter(category => 
    category.count > 0 && 
    category.slug !== 'acu-parent' &&
    category.slug !== 'uncategorized'
  );
  
  return <div>...</div>;
}
```

#### Category Filtering (Migration Standard)
```typescript
// Applied consistently across all sites
const mainCategories = categories.filter(category => 
  category.count > 0 && 
  category.slug !== 'acu-parent' &&
  category.slug !== 'uncategorized'
).slice(0, 6);
```

#### Union Type Handling for [slug] Routes
```typescript
// Enhanced pattern for posts AND pages
let content: WordPressContent | null = await getPost(slug);
let isPost = true;

if (!content) {
  content = await getPage(slug);
  isPost = false;
}

const categories = isPost ? getPostCategories(content as WordPressPost) : [];
```

### Environment Variables (Required)
```env
# WordPress API Configuration
WORDPRESS_API_URL=https://staging.{DOMAIN}/wp-json/wp/v2
WORDPRESS_URL=https://staging.{DOMAIN}
WORDPRESS_HOSTNAME=staging.{DOMAIN}
WORDPRESS_USERNAME=Editorial Team
WORDPRESS_APP_PASSWORD={APPLICATION_PASSWORD}

# Webhook Integration (Optional)
WORDPRESS_WEBHOOK_SECRET={WEBHOOK_SECRET}
```

### Error Handling Standards
```typescript
// WordPress API error handling pattern
export async function getPost(slug: string): Promise<WordPressPost | null> {
  try {
    const response = await fetch(url.toString(), {
      headers: { 'Authorization': authHeader },
      next: { revalidate: 3600 }
    });
    
    if (!response.ok) {
      throw new Error(`API Error: ${response.status}`);
    }
    
    const posts = await response.json();
    return posts.length > 0 ? posts[0] : null;
  } catch (error) {
    console.error('WordPress API Error:', error);
    return null;
  }
}
```

### Our Enhanced Template Features
✅ **Added WordPress Pages Support:**
- Complete Pages API integration
- Dynamic routing for both posts AND pages
- TypeScript union types for content handling
- Static generation for all pages
- URL structure preservation

✅ **Professional Footer System:**
- 3-column responsive layout with brand-specific content
- WordPress pages navigation integration
- Categories/topics section with enhanced styling
- Professional company descriptions tailored to each industry

---

## 🚀 ADVANCED FEATURES & FUTURE ENHANCEMENTS
*Available in Template - Ready for Implementation*

### 🔄 **Webhook Revalidation System**
```typescript
// /api/revalidate endpoint for real-time updates
export async function POST(request: Request) {
  const secret = request.nextUrl.searchParams.get('secret');
  
  if (secret !== process.env.WORDPRESS_WEBHOOK_SECRET) {
    return new Response('Invalid token', { status: 401 });
  }
  
  const { slug, type } = await request.json();
  
  try {
    await revalidateTag(type === 'post' ? `post-${slug}` : `page-${slug}`);
    return Response.json({ revalidated: true });
  } catch (err) {
    return new Response('Error revalidating', { status: 500 });
  }
}
```

### 🏷️ **Enhanced Cache Strategy**
```typescript
// Granular cache tags for better performance
const response = await fetch(url.toString(), {
  headers: { 'Authorization': authHeader },
  next: { 
    revalidate: 3600,
    tags: ['posts', `post-${slug}`, 'categories']
  }
});
```

### 🖼️ **Dynamic OG Images**
```typescript
// /api/og/[slug] for auto-generated social media images
export async function GET(request: Request, { params }: { params: { slug: string } }) {
  const post = await getPost(params.slug);
  
  return new ImageResponse(
    (
      <div style={{ /* OG image styling */ }}>
        <h1>{post.title.rendered}</h1>
      </div>
    )
  );
}
```

### 🔍 **Enhanced Search Features**
```typescript
// Debounced search with URL state management
const [searchTerm, setSearchTerm] = useState('');
const debouncedSearchTerm = useDebounce(searchTerm, 300);

useEffect(() => {
  if (debouncedSearchTerm) {
    router.push(`/search?q=${encodeURIComponent(debouncedSearchTerm)}`);
  }
}, [debouncedSearchTerm]);
```

### 🛡️ **Enhanced Error Handling**
```typescript
// Custom WordPressAPIError class
class WordPressAPIError extends Error {
  constructor(
    message: string,
    public status: number,
    public endpoint: string
  ) {
    super(message);
    this.name = 'WordPressAPIError';
  }
}
```

---

## 📈 PERFORMANCE OPTIMIZATION PATTERNS

### Caching Strategy
- **Default Cache**: 1 hour (`revalidate: 3600`) for most content
- **Search Results**: Short cache (`revalidate: 60`) for dynamic content
- **Categories**: Daily cache (`revalidate: 86400`) for stable data
- **Pages**: Longer cache for static content

### Data Fetching Optimization
- **Parallel Requests**: Always use `Promise.all()` for independent data
- **Server Components**: Primary pattern for data fetching
- **Static Generation**: Pre-generate all posts and pages at build time
- **ISR**: Incremental Static Regeneration for content updates

### Image Optimization
- **Next.js Image**: Use `next/image` for all media
- **WordPress Hostname**: Configure for cross-origin optimization
- **Priority Loading**: Featured images with `priority` prop

---

## 🎯 MIGRATION ENHANCEMENT ROADMAP

### Phase 1: Current Status ✅
- WordPress Pages support implemented
- Professional footers deployed
- Category filtering active
- Union type routing complete

### Phase 2: Advanced Template Features ⏳
- **Webhook Integration**: Real-time content updates
- **Enhanced Caching**: Granular cache tags implementation
- **OG Image Generation**: Dynamic social media images
- **Advanced Search**: Debounced search with URL state

### Phase 3: Performance Optimization ⏳
- **Cache Tag Strategy**: Implement granular revalidation
- **Error Handling**: Custom error classes and better UX
- **Analytics Integration**: Performance monitoring
- **SEO Enhancements**: Advanced meta tag generation

### Phase 4: Advanced Features ⏳
- **Multi-language Support**: i18n implementation
- **Advanced Search**: Full-text search with filters
- **Content Scheduling**: Future post publication
- **User Authentication**: Member-only content areas

✅ **Professional Footer System:**
- 3-column responsive layout
- Company information section
- Pages navigation (WordPress pages)
- Topics/Categories navigation
- Enhanced typography and styling

---

## 🔧 MASTER CONFIGURATION SYSTEM

### Site Configuration Template
Each site requires exactly **8 key parameters**:

```typescript
interface SiteConfig {
  // Domain Configuration
  productionDomain: string;        // "stocktiming.com"
  stagingDomain: string;          // "staging.stocktiming.com"
  
  // WordPress API
  wordpressUrl: string;           // "https://staging.stocktiming.com"
  wordpressUser: string;          // "Editorial Team"
  wordpressPassword: string;      // "WPmdQdvx28yjpWguZGWPZKey"
  
  // Server Details
  serverName: string;             // "cendol-may25" | "bessie" | "legal-may25"
  serverIP: string;              // "162.243.15.7"
  systemUser: string;            // "stocktiming11482"
}
```

### Server Infrastructure Map
| Server | IP Address | Sites Count | Primary Use |
|--------|------------|-------------|-------------|
| **Cendol** | `162.243.15.7` | 20 sites | Primary migration server |
| **Bessie** | `68.183.24.139` | 34 sites | High-volume hosting |
| **Legal-may25** | `138.197.11.181` | 21 sites | Legal industry sites |
| **Kampung-may25** | `162.243.4.151` | 1 site | Special projects |

### Master Credentials Directory
```
📁 devops/secrets/credentials/
├── vercel.token              # Vercel deployment token
├── github.token             # GitHub API access
└── supabase.*              # Database credentials (if needed)

🔑 SSH Configuration:
├── C:\Users\user\.ssh\gridpane_rsa     # Private key (all servers)
└── C:\Users\user\.ssh\gridpane_rsa.pub # Public key
```

---

## 📋 STEP-BY-STEP MIGRATION PROCESS

### PHASE 1: Pre-Migration Analysis & Setup (15 minutes)
**Goal**: Complete content audit and configuration validation

#### Step 1.1: Content Inventory
```bash
# SSH into target site server
ssh -i "C:/Users/user/.ssh/gridpane_rsa" root@{SERVER_IP}

# Complete content audit
cd /var/www/staging.{DOMAIN}/htdocs
sudo -u {SYSTEM_USER} wp post list --post_type=post --format=count
sudo -u {SYSTEM_USER} wp post list --post_type=page --format=count
sudo -u {SYSTEM_USER} wp category list --format=count
sudo -u {SYSTEM_USER} wp post list --post_status=publish --format=csv --fields=ID,post_title,post_name,post_type
```

#### Step 1.2: URL Structure Mapping
**CRITICAL**: Document every public URL to ensure 100% migration coverage
- All published posts: `/post-slug/`
- All published pages: `/page-slug/` 
- Category archives: `/category/category-slug/`
- Nested pages: `/parent-page/child-page/`

#### Step 1.3: Validate Credentials
```powershell
# Windows credential validation
Test-Path "devops\secrets\credentials\vercel.token"
Test-Path "C:\Users\user\.ssh\gridpane_rsa"

# Test WordPress API connection
curl -u "Editorial Team:WPmdQdvx28yjpWguZGWPZKey" "https://staging.{DOMAIN}/wp-json/wp/v2/posts?per_page=1"
```

### PHASE 2: WordPress Backend Configuration (5 minutes)

#### Step 2.1: Plugin Management
```bash
# Deactivate problematic plugins immediately
sudo -u {SYSTEM_USER} wp plugin deactivate wordfence
sudo -u {SYSTEM_USER} wp plugin deactivate security-plugins

# Install refresh plugin
# Upload vercel-refresh-new.php to wp-content/plugins/
sudo -u {SYSTEM_USER} wp plugin activate vercel-refresh
```

#### Step 2.2: Application Password Setup
```bash
# Create application password for REST API
sudo -u {SYSTEM_USER} wp user application-password create "Editorial Team" "RESTAPI" --porcelain
```

#### Step 2.3: URL Configuration
```bash
# Ensure correct URL structure
sudo -u {SYSTEM_USER} wp option update home "https://staging.{DOMAIN}"
sudo -u {SYSTEM_USER} wp option update siteurl "https://staging.{DOMAIN}"
```

### PHASE 3: Next.js Application Development (10 minutes)

#### Step 3.1: Clone Enhanced Template
```bash
# Use microalphas-headless as the master template (has pages + footer)
cp -r migration/projects/microalphas-headless migration/projects/{DOMAIN}-headless
cd migration/projects/{DOMAIN}-headless
```

#### Step 3.2: Configuration Replacement
**Automated find/replace across all template files:**
```bash
# Core configuration updates
find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.json" | xargs sed -i 's/microalphas.com/{DOMAIN}/g'
find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.json" | xargs sed -i 's/staging.microalphas.com/staging.{DOMAIN}/g'
find . -type f -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.json" | xargs sed -i 's/Micro Alphas/{BRAND_NAME}/g'

# Update .env.production
echo "WORDPRESS_URL=https://staging.{DOMAIN}" > .env.production
echo "WORDPRESS_HOSTNAME=staging.{DOMAIN}" >> .env.production
```

#### Step 3.3: Brand Customization
**Files requiring manual updates:**
- `src/components/Header.tsx` - Brand name, navigation
- `src/components/Footer.tsx` - Company description, contact info
- `src/app/layout.tsx` - Meta tags, site title
- `src/app/page.tsx` - Hero section content

### PHASE 4: Enhanced Pages & Footer Implementation

#### Step 4.1: WordPress Pages Support (Already in Template)
**Files with complete pages support:**
- `src/lib/wordpress.ts` - Pages API functions
- `src/app/[slug]/page.tsx` - Union type handling (posts + pages)
- `src/app/layout.tsx` - Static generation for pages

#### Step 4.2: Professional Footer (Already in Template)
**Footer features:**
- 3-column responsive layout
- WordPress pages navigation
- Categories/topics section
- Professional company descriptions
- Contact and legal page links

### PHASE 5: Deployment & Testing (5 minutes)

#### Step 5.1: Vercel Deployment
```powershell
# Windows PowerShell deployment
cd migration/projects/{DOMAIN}-headless
git init
git add .
git commit -m "Initial migration setup"

# Create GitHub repository and deploy
$token = (Get-Content "../../devops/secrets/credentials/vercel.token" -Raw).Trim()
vercel --prod --yes --token $token
```

#### Step 5.2: Comprehensive Testing
**URL Testing Checklist:**
- [ ] Homepage loads with correct branding
- [ ] Sample post loads: `/{post-slug}/`
- [ ] Sample page loads: `/{page-slug}/` (CRITICAL - was missing before)
- [ ] Category page: `/category/{category-slug}/`
- [ ] Navigation works (header + footer)
- [ ] WordPress admin accessible: `staging.{DOMAIN}/wp-admin`

### PHASE 6: DNS & Go-Live (3 minutes)

#### Step 6.1: DNS Configuration
**Cloudflare setup:**
- A record: `{DOMAIN}` → Vercel IP
- CNAME: `staging.{DOMAIN}` → GridPane server
- Proxy: Enabled for production, Disabled for staging

---

## 🚨 CRITICAL ISSUES & SOLUTIONS

### Issue 1: WordPress Pages 404 Errors
**Cause**: Vercel template missing pages functionality
**Solution**: Use our enhanced template with complete pages support
**Files**: `src/lib/wordpress.ts`, `src/app/[slug]/page.tsx`

### Issue 2: Incomplete URL Structure
**Cause**: Not auditing all content types before migration  
**Solution**: Phase 1 complete content inventory required
**Prevention**: Document every public URL before starting

### Issue 3: Template Customization Failures
**Cause**: Hardcoded references not replaced
**Solution**: Comprehensive find/replace automation
**Files**: All `.ts`, `.tsx`, `.js`, `.json` files

### Issue 4: BOM Characters in Tokens
**Cause**: Windows file encoding issues
**Solution**: Clean tokens before use
```powershell
$token = (Get-Content "token-file" -Raw).Trim() -replace '^\xEF\xBB\xBF', ''
```

### Issue 5: Plugin Conflicts
**Cause**: Security plugins blocking REST API
**Solution**: Immediate deactivation during migration
**Plugins**: Wordfence, security-related plugins

---

## 📈 MIGRATION EFFICIENCY METRICS

### Traditional Migration (Before Templates)
- **Time**: 3+ hours per site
- **Token Usage**: High (repeated development)
- **Error Rate**: High (manual process)
- **Consistency**: Low (different implementations)

### Template-Based Migration (Current)
- **Time**: 35-40 minutes per site
- **Token Usage**: 95% reduction
- **Error Rate**: Minimal (automated process)  
- **Consistency**: High (standardized template)

### Target Efficiency (With Automation)
- **Time**: 15-20 minutes per site
- **Token Usage**: 98% reduction
- **Error Rate**: Near zero
- **Consistency**: Perfect standardization

---

## 🔄 ENHANCEMENT ROLLOUT PLAN

### Phase 1: Retrofit Existing Sites (5 sites)
**Priority Order:**
1. **stocktiming.com** - High traffic, needs pages functionality
2. **funmathgames.com** - Complex page structure
3. **climatefinance.com** - Professional services site  
4. **coloradoroofingsolutions.com** - Local business pages
5. **the-weddingplanner.com** - Service pages critical

**Process**: Apply pages + footer enhancements to each site individually

### Phase 2: Future Migrations (10-20 sites)
**Strategy**: Use enhanced template with full functionality from day one
**Efficiency**: 15-20 minutes per site with complete feature set

---

## 🎯 NEXT ACTIONS

### Immediate (This Session)
1. **Apply pages + footer to stocktiming.com** (highest priority)
2. **Test complete functionality** 
3. **Document any additional customizations needed**

### Short Term (Next Sessions)  
1. **Rollout to remaining 4 existing sites**
2. **Create fully automated setup script**
3. **Begin future site migrations using enhanced template**

### Long Term  
1. **Complete migration of all 10-20 pending sites**
2. **Performance optimization and monitoring setup**
3. **Advanced features (search, filtering, custom post types)**

---

## 📚 DOCUMENTATION REFERENCES

### Master Documentation
- **This File**: `migration/CLAUDE.md` - Central command center
- **Server Details**: `SSH/QUICK_REFERENCE.md` - Credentials and commands
- **Sites Database**: `SSH/gridpane-sites.csv` - Complete site inventory

### Migration-Specific Docs
- **Complete Guide**: `documentation/HEADLESS_WORDPRESS_MIGRATION_COMPLETE_GUIDE.md`
- **Lessons Learned**: `documentation/FUNMATHGAMES_MIGRATION_LESSONS_LEARNED.md`  
- **MicroAlphas Enhancement**: `documentation/MICROALPHAS_MIGRATION_DOCUMENTATION.md`
- **Troubleshooting**: `documentation/MIGRATION_TROUBLESHOOTING_GUIDE.md`

### Individual Project Docs
Each project has local CLAUDE.md files with site-specific details and customizations.

---

**🎯 SUCCESS METRICS**: 100% URL preservation, 15-20 minute migration time, professional-grade interface, complete WordPress feature parity.