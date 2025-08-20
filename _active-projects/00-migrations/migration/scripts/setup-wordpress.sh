#!/bin/bash
# setup-wordpress.sh - Configure WordPress for headless setup
# Usage: ./setup-wordpress.sh <domain>

DOMAIN=$1

if [ $# -ne 1 ]; then
    echo "Usage: ./setup-wordpress.sh <domain>"
    exit 1
fi

STAGING_DOMAIN="staging.$DOMAIN"
echo "Setting up WordPress for $STAGING_DOMAIN..."

# SSH to server and configure WordPress
ssh -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7 << EOF
cd /var/www/$STAGING_DOMAIN/htdocs

# Get site user
SITE_USER=\$(stat -c '%U' wp-config.php)
echo "Site user: \$SITE_USER"

# Fix WordPress URLs
sudo -u \$SITE_USER wp option update home "https://$STAGING_DOMAIN"
sudo -u \$SITE_USER wp option update siteurl "https://$STAGING_DOMAIN"
sudo -u \$SITE_USER wp rewrite flush

# Deactivate Wordfence if active
sudo -u \$SITE_USER wp plugin deactivate wordfence 2>/dev/null || true

# Get WordPress username (first admin user)
WP_USERNAME=\$(sudo -u \$SITE_USER wp user list --role=administrator --format=csv --fields=user_login | tail -n +2 | head -n 1)
echo "WordPress username: \$WP_USERNAME"

# Create new application password
APP_PASSWORD=\$(sudo -u \$SITE_USER wp user application-password create "\$WP_USERNAME" "Headless API \$(date +%Y)" --porcelain)
echo "Generated password: \$APP_PASSWORD"

# Test API connection
HTTP_CODE=\$(curl -s -u "\$WP_USERNAME:\$APP_PASSWORD" "https://$STAGING_DOMAIN/wp-json/wp/v2/posts?per_page=1" -o /dev/null -w "%{http_code}")
if [ \$HTTP_CODE -ne 200 ]; then
    echo "ERROR: API test failed (HTTP \$HTTP_CODE)"
    exit 1
fi

# Save credentials for next step
echo "WP_USERNAME=\$WP_USERNAME" > /tmp/wp-creds-$DOMAIN
echo "APP_PASSWORD=\$APP_PASSWORD" >> /tmp/wp-creds-$DOMAIN
echo "WordPress API test successful"
EOF

# Copy credentials back
scp -i "C:\Users\user\.ssh\gridpane_rsa" root@162.243.15.7:/tmp/wp-creds-$DOMAIN ./wp-creds-$DOMAIN

echo "WordPress setup complete for $STAGING_DOMAIN"