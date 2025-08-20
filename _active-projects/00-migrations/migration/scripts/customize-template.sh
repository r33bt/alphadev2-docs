#!/bin/bash
# customize-template.sh - Fix hardcoded StockTiming references
# Usage: ./customize-template.sh <target-domain> <site-name> <site-description>

DOMAIN=$1
SITE_NAME=$2
SITE_DESCRIPTION=$3

if [ $# -ne 3 ]; then
    echo "Usage: ./customize-template.sh <domain> <site-name> <site-description>"
    echo "Example: ./customize-template.sh the-weddingplanner.com 'The Wedding Planner' 'Expert Wedding Planning & Celebration Ideas'"
    exit 1
fi

echo "Customizing template for $SITE_NAME..."

# Copy stocktiming template (create minimal copy for faster processing)
echo "Creating project template..."
mkdir -p "${DOMAIN}-headless/src/app" "${DOMAIN}-headless/src/components"
cp -r "C:\Users\user\alphadev2\migration\projects\stocktiming-headless/stocktiming-headless/src" "${DOMAIN}-headless/" 2>/dev/null || true
cp "C:\Users\user\alphadev2\migration\projects\stocktiming-headless/stocktiming-headless/package.json" "${DOMAIN}-headless/" 2>/dev/null || true
cd "${DOMAIN}-headless"

# Replace hardcoded references
find . -name "*.tsx" -o -name "*.ts" -o -name "*.js" | xargs sed -i "
s/StockTiming\.com/$SITE_NAME/g
s/StockTiming/$SITE_NAME/g
s/stocktiming\.com/$DOMAIN/g
s/staging\.stocktiming\.com/staging.$DOMAIN/g
s/Professional Trading Strategies & Market Analysis/$SITE_DESCRIPTION/g
s/stocktiming-revalidate-2025/${DOMAIN//\./-}-revalidate-2025/g
s/StockTiming Team/${SITE_NAME} Team/g
"

# Check if any StockTiming references remain
REMAINING=$(find . -name "*.tsx" -o -name "*.ts" | xargs grep -l "StockTiming\|stocktiming\.com" | wc -l)
if [ $REMAINING -gt 0 ]; then
    echo "ERROR: StockTiming references still found in:"
    find . -name "*.tsx" -o -name "*.ts" | xargs grep -l "StockTiming\|stocktiming\.com"
    exit 1
fi

echo "Template customized successfully for $SITE_NAME"