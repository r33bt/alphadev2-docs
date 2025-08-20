# Detailed Migration Steps

## Phase 1: Source Setup

### GridPane Setup
1. Access GridPane dashboard
2. Create new site:
   - Domain: hostdomain.com
   - Server: Select existing or create new
   - Stack: Default NGINX
   - PHP: 8.1 recommended

3. Enable Multisite:
   - Open site settings
   - Go to "Multisite Settings" tab
   - Select "Sub-directory Multisite"
   - Toggle ON
   - Wait for completion

4. Verify Setup:
   - Access hostdomain.com/wp-admin
   - Verify Network Admin menu exists
   - Check phpMyAdmin access
   - Test file permissions

### WordPress Configuration
1. Install Required Plugin:
   - Network Admin → Plugins
   - Add New → Search "Simply Static"
   - Install & Network Activate
   - No additional plugins needed initially

2. WordPress Settings:
   - Network Admin → Settings
   - Set upload limits if needed
   - Configure network settings
   - Test subsite creation

## Phase 2: Test Migration (Single Site)

### Subsite Creation
1. Network Admin → Sites → Add New
   - Path: domain1.com
   - Title: Site 1
   - Admin email: your@email.com

### Content Migration
1. Source Site Export:
   ```bash
   # On source server
   wp db export domain1-db.sql
   tar -czf domain1-uploads.tar.gz wp-content/uploads/
   ```

2. Import to Multisite:
   ```bash
   # On destination server
   wp db import domain1-db.sql
   # Extract uploads to wp-content/uploads/sites/2/
   # Site ID will vary - check in Network Admin
   ```

3. URL Updates:
   ```bash
   wp search-replace 'domain1.com' 'hostdomain.com/domain1.com'
   wp search-replace 'wp-content/uploads' 'wp-content/uploads/sites/2'
   ```

### GA4 Setup
1. API Configuration:
   ```python
   # Store in secure environment variables
   GA_CLIENT_ID="your-client-id"
   GA_CLIENT_SECRET="your-secret"
   ```

2. Per-Site GA4 Creation:
   - Create property via API
   - Generate measurement ID
   - Store mapping (domain → GA4 ID)
   - Add to site inventory CSV:
   ```csv
   source_domain,new_path,site_id,ga4_id
   domain1.com,domain1.com,2,G-XXXXXXXXXX
   ```

3. Code Implementation:
   - Network Admin → Themes → Theme Editor
   - Add to header.php:
   ```php
   <?php
   // Get GA4 ID from site options
   $ga4_id = get_option('site_ga4_id');
   if ($ga4_id) {
     echo "<!-- Google tag (gtag.js) -->
     <script async src='https://www.googletagmanager.com/gtag/js?id=" . esc_attr($ga4_id) . "'></script>
     <script>
       window.dataLayer = window.dataLayer || [];
       function gtag(){dataLayer.push(arguments);}
       gtag('js', new Date());
       gtag('config', '" . esc_attr($ga4_id) . "');
     </script>";
   }
   ?>
   ```

## Phase 3: Static Generation

### Simply Static Configuration
1. Network Admin → Simply Static
   - Setup Basic Options:
        - Build Time: 600 seconds
        - File Delivery: ZIP Archive
        - Clear Temp Files: Yes
   
2. Generate Test:
   - Select test site
   - Start first generation
   - Monitor for errors
   - Check output files

### Cloudflare Setup
1. Create Pages Project:
   - Connect to Git repository
   - Set build settings:
     - Build command: none (initially)
     - Output directory: /
   - Save and deploy

2. Domain Configuration:
   - Add custom domain
   - Configure DNS
   - Verify SSL

## Phase 4: Scale Up

### Automation Prep
1. Create site inventory:
   ```csv
   source_domain,new_path,site_id
   domain1.com,domain1.com,2
   domain2.com,domain2.com,3
   ```

2. Quality Checklist:
   - Homepage loads
   - Internal links work
   - Images display
   - Forms function (if static forms used)
   - No 404 errors
   - SSL valid

### Batch Processing
1. Create subsites in batches of 10
2. Monitor server resources
3. Run static generation in groups
4. Verify each batch before proceeding

## Important Notes
- Keep source sites live until migration complete
- Document each site's specific requirements
- Maintain backup at each step
- Test thoroughly before DNS changes 