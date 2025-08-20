#!/bin/bash
# setup-environment.sh - Configure environment variables
# Usage: ./setup-environment.sh <domain>

DOMAIN=$1

if [ $# -ne 1 ]; then
    echo "Usage: ./setup-environment.sh <domain>"
    exit 1
fi

echo "Setting up environment for $DOMAIN..."

# Load WordPress credentials
if [ ! -f "wp-creds-$DOMAIN" ]; then
    echo "ERROR: WordPress credentials not found. Run setup-wordpress.sh first."
    exit 1
fi

source ./wp-creds-$DOMAIN
VERCEL_TOKEN=$(cat "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token")

# Create .env.production
cat > .env.production << EOF
WORDPRESS_API_URL=https://staging.$DOMAIN/wp-json/wp/v2
WORDPRESS_USERNAME=$WP_USERNAME
WORDPRESS_APP_PASSWORD=$APP_PASSWORD
NEXT_PUBLIC_SITE_URL=https://$DOMAIN
EOF

# Clean up existing Vercel env vars
vercel env rm WORDPRESS_API_URL production --token $VERCEL_TOKEN --yes 2>/dev/null || true
vercel env rm WORDPRESS_USERNAME production --token $VERCEL_TOKEN --yes 2>/dev/null || true  
vercel env rm WORDPRESS_APP_PASSWORD production --token $VERCEL_TOKEN --yes 2>/dev/null || true

# Set new Vercel env vars
echo "https://staging.$DOMAIN/wp-json/wp/v2" | vercel env add WORDPRESS_API_URL production --token $VERCEL_TOKEN
echo "$WP_USERNAME" | vercel env add WORDPRESS_USERNAME production --token $VERCEL_TOKEN
echo "$APP_PASSWORD" | vercel env add WORDPRESS_APP_PASSWORD production --token $VERCEL_TOKEN

# Test API connection one more time
HTTP_CODE=$(curl -s -u "$WP_USERNAME:$APP_PASSWORD" "https://staging.$DOMAIN/wp-json/wp/v2/posts?per_page=1" -o /dev/null -w "%{http_code}")
if [ $HTTP_CODE -ne 200 ]; then
    echo "ERROR: WordPress API connection failed (HTTP $HTTP_CODE)"
    exit 1
fi

echo "Environment setup complete for $DOMAIN"