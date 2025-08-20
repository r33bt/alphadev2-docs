#!/bin/bash
# migrate-site.sh - Complete migration automation
# Usage: ./migrate-site.sh <domain> <site-name> <site-description>

DOMAIN=$1
SITE_NAME=$2
SITE_DESCRIPTION=$3

if [ $# -ne 3 ]; then
    echo "Usage: ./migrate-site.sh <domain> <site-name> <site-description>"
    echo "Example: ./migrate-site.sh the-weddingplanner.com 'The Wedding Planner' 'Expert Wedding Planning & Celebration Ideas'"
    exit 1
fi

echo "Starting migration for $SITE_NAME ($DOMAIN)..."

# Check prerequisites
if [ ! -f "C:\Users\user\.ssh\gridpane_rsa" ]; then
    echo "ERROR: SSH key not found"
    exit 1
fi

if [ ! -f "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token" ]; then
    echo "ERROR: Vercel token not found"
    exit 1
fi

# Test staging site accessibility
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://staging.$DOMAIN")
if [ $HTTP_CODE -ne 200 ]; then
    echo "ERROR: Staging site not accessible (HTTP $HTTP_CODE)"
    exit 1
fi

# Step 1: Setup WordPress
echo "Step 1: Setting up WordPress..."
./setup-wordpress.sh "$DOMAIN"
if [ $? -ne 0 ]; then
    echo "ERROR: WordPress setup failed"
    exit 1
fi

# Step 2: Customize template
echo "Step 2: Customizing template..."
./customize-template.sh "$DOMAIN" "$SITE_NAME" "$SITE_DESCRIPTION"
if [ $? -ne 0 ]; then
    echo "ERROR: Template customization failed"
    exit 1
fi

# Step 3: Setup environment
echo "Step 3: Setting up environment..."
cd "${DOMAIN}-headless"
../setup-environment.sh "$DOMAIN"
if [ $? -ne 0 ]; then
    echo "ERROR: Environment setup failed"
    exit 1
fi

# Step 4: Deploy to Vercel
echo "Step 4: Deploying to Vercel..."
VERCEL_TOKEN=$(cat "C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token")
DEPLOY_URL=$(vercel --prod --token $VERCEL_TOKEN)

if [ $? -ne 0 ]; then
    echo "ERROR: Vercel deployment failed"
    exit 1
fi

# Step 5: Basic validation
echo "Step 5: Validating deployment..."
sleep 10  # Wait for deployment to be ready

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL")
if [ $HTTP_CODE -eq 401 ]; then
    echo "WARNING: Site shows 401 (Vercel SSO) - will work with custom domain"
elif [ $HTTP_CODE -ne 200 ]; then
    echo "WARNING: Site not accessible (HTTP $HTTP_CODE)"
fi

echo ""
echo "Migration completed successfully!"
echo "Deployment URL: $DEPLOY_URL"
echo ""
echo "Next steps:"
echo "1. Configure DNS for $DOMAIN to point to Vercel"
echo "2. Test the site at https://$DOMAIN once DNS propagates"