@'
# SaaS Template - Three-Tier Architecture Prompts

## 🎯 **COMPLETE PROJECT REQUEST**

I need to build a complete SaaS application for [DOMAIN_NAME] following our AlphaDev2 three-tier architecture.

STAGE 1 - Content Foundation:

WordPress-like page and post creation system
Blog with taxonomies (categories, tags, custom taxonomies)
Archive pages and taxonomy display pages
SEO optimization and content management
STAGE 2 - Directory System:

[SPECIFY: Product/Website/Business] directory
Custom fields: [LIST SPECIFIC FIELDS FOR THIS DOMAIN]
Advanced filtering and search functionality
Directory listings and detail pages
STAGE 3 - Lead Generation:

Custom forms designed for [INDUSTRY] pain points
User profiling and qualification system
Lead scoring and premium lead optimization
Custom form flow: [DESCRIBE SPECIFIC FUNNEL]
SAAS INFRASTRUCTURE:

Supabase authentication and user management
Stripe payment integration
Admin dashboard for content and lead management
Analytics and reporting features
Please provide complete implementation plan following our AlphaDev2 patterns.


## 📋 **INDUSTRY-SPECIFIC CUSTOMIZATION PROMPTS**

### **For Business Directory Sites**
DIRECTORY TYPE: Business Directory CUSTOM FIELDS: Business name, category, location, contact info, hours, services, ratings LEAD GENERATION: Business inquiry forms, quote requests, consultation booking PAIN POINTS: Finding local services, comparing providers, getting quotes


### **For Product Directory Sites**  
DIRECTORY TYPE: Product Catalog CUSTOM FIELDS: Product name, category, price, specifications, availability, reviews LEAD GENERATION: Product inquiries, demo requests, purchase funnels PAIN POINTS: Product comparison, pricing information, feature evaluation

'@ | Out-File -FilePath "_prompts\project-types\saas-template.md" -Encoding UTF8