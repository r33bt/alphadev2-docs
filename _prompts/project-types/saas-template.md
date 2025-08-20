@'
# SaaS Template - Automated Domain Analysis + Three-Tier Architecture

## 🔍 **PHASE 1: COMPREHENSIVE DOMAIN ANALYSIS**

Please perform complete analysis for: **[DOMAIN_NAME]** [ADDITIONAL_KEYWORDS_OR_CONTEXT]

### **Domain & Market Research**
1. **Domain Analysis**: Analyze domain name meaning, keywords, and implied business focus
2. **Industry Identification**: Determine primary industry, market sector, and business category  
3. **Niche Analysis**: Identify specific sub-niche, target market, and positioning opportunities
4. **Market Size**: Assess market opportunity, growth potential, and monetization models

### **Competitive Intelligence**  
5. **Direct Competitors**: Identify 3-5 main competitors and their approaches
6. **Competitive Gaps**: Analyze what competitors are missing or doing poorly
7. **Differentiation Opportunities**: Suggest unique positioning and value propositions
8. **Pricing Models**: Research typical pricing in this industry

### **Target Audience & Pain Points**
9. **Primary Audience**: Demographics, psychographics, and behavior patterns
10. **Secondary Audiences**: Additional user segments and stakeholders  
11. **Core Pain Points**: Top 3-5 problems your target audience faces
12. **User Journey**: Typical customer journey from awareness to purchase
13. **Decision Factors**: What influences purchasing decisions in this niche

### **Business Model & Monetization**
14. **Revenue Streams**: Optimal monetization strategies for this industry
15. **Lead Generation**: Industry-specific lead capture and qualification methods
16. **Premium Features**: What users would pay extra for
17. **Conversion Funnels**: Industry-specific sales processes

### **Technical & Integration Opportunities**
18. **Relevant APIs**: Industry-specific APIs, services, and integrations
19. **Data Sources**: Public databases, feeds, or information sources to leverage
20. **Automation Opportunities**: Processes that can be automated for efficiency
21. **Third-party Tools**: Essential tools and services for this industry

---

## 🏗️ **PHASE 2: CUSTOM SAAS ARCHITECTURE DESIGN**

Using the research insights above, design a complete SaaS application following our AlphaDev2 three-tier architecture:

### **STAGE 1 - Content Foundation**
- **Content Strategy**: Industry-specific page types and blog content categories
- **SEO Focus**: Target keywords and content themes based on niche analysis
- **Taxonomy Design**: Custom categories and tags relevant to the industry
- **Content Templates**: Page layouts optimized for this audience

### **STAGE 2 - Directory System**  
- **Directory Type**: [Determined from analysis - Product/Business/Service/etc.]
- **Custom Fields**: Industry-specific fields based on user needs and competitive analysis
- **Search & Filtering**: Features most valuable to this target audience
- **Data Integration**: Relevant APIs and data sources to populate directory

### **STAGE 3 - Lead Generation Engine**
- **Custom Forms**: Designed around identified pain points and user journey
- **Lead Qualification**: Industry-specific qualification criteria  
- **Conversion Funnels**: Multi-step forms optimized for this audience
- **Premium Lead Features**: Advanced profiling based on revenue potential

### **SAAS INFRASTRUCTURE**
- **Authentication**: User types and permission levels for this industry
- **Payment Integration**: Pricing model and Stripe configuration
- **Admin Dashboard**: Management features specific to this business model
- **Analytics**: KPIs and metrics most important for this industry
- **Integrations**: Essential third-party services identified in research

---

## 📋 **PHASE 3: IMPLEMENTATION ROADMAP**

Provide detailed implementation plan including:

### **Technical Setup**
- Next.js project structure optimized for this use case
- Supabase database schema for industry-specific data
- Environment variables and API configurations
- Deployment strategy and domain setup

### **Development Priorities**
- **Week 1-2**: Content foundation and basic functionality
- **Week 3-4**: Directory system and data integration  
- **Week 5-6**: Lead generation forms and user management
- **Week 7-8**: Payment integration and admin features

### **Content Strategy**
- **Initial Content**: 10-15 strategic pages/posts to launch with
- **SEO Roadmap**: Target keywords and content calendar
- **Directory Seeding**: Initial data sources and population strategy

### **Launch Strategy**  
- **Soft Launch**: Beta testing with target audience subset
- **Marketing Channels**: Industry-specific promotion strategies
- **Success Metrics**: KPIs to track based on business model

---

## 🎯 **USAGE INSTRUCTIONS**

1. Replace **[DOMAIN_NAME]** with actual domain
2. Add any **[ADDITIONAL_KEYWORDS_OR_CONTEXT]** if needed
3. Upload this template along with MASTER_REFERENCE.md and claude.md
4. Get complete industry analysis + technical implementation plan

**Example Usage:**
Please analyze: climatetech-summit.com [focus on B2B climate technology events]


This will trigger comprehensive analysis and custom SaaS design in a single request.
'@ | Out-File -FilePath "saas-template.md" -Encoding UTF8