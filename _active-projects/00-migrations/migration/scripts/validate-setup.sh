#!/bin/bash
# validate-setup.sh - Check if everything is ready for migration
# Usage: ./validate-setup.sh <domain>

DOMAIN=$1

if [ $# -ne 1 ]; then
    echo "Usage: ./validate-setup.sh <domain>"
    echo "Example: ./validate-setup.sh the-weddingplanner.com"
    exit 1
fi

echo "🔍 Validating Migration Setup for $DOMAIN"
echo "==========================================="

CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to check something
check() {
    local description="$1"
    local test_command="$2"
    
    echo -n "Checking $description... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ OK"
        ((CHECKS_PASSED++))
    else
        echo "❌ FAIL"
        ((CHECKS_FAILED++))
    fi
}

echo ""
echo "📋 Prerequisites"
echo "----------------"
check "SSH key exists" "[ -f 'C:\Users\user\.ssh\gridpane_rsa' ]"
check "Vercel token exists" "[ -f 'C:\Users\user\alphadev2\devops\secrets\credentials\vercel.token' ]"
check "StockTiming template exists" "[ -d 'C:\Users\user\alphadev2\migration\projects\stocktiming-headless' ]"

echo ""
echo "🌐 Network Tests"
echo "----------------"
check "Staging site accessible" "curl -s -o /dev/null -w '%{http_code}' 'https://staging.$DOMAIN' | grep -q '200'"
check "GridPane server reachable" "ping -c 1 162.243.15.7"

echo ""
echo "📜 Scripts"
echo "----------"
check "migrate-site.sh exists and executable" "[ -x './migrate-site.sh' ]"
check "setup-wordpress.sh exists and executable" "[ -x './setup-wordpress.sh' ]"
check "customize-template.sh exists and executable" "[ -x './customize-template.sh' ]"
check "setup-environment.sh exists and executable" "[ -x './setup-environment.sh' ]"

echo ""
echo "🔧 Tools"
echo "--------"
check "curl available" "command -v curl"
check "ssh available" "command -v ssh"
check "vercel available" "command -v vercel"
check "sed available" "command -v sed"

echo ""
echo "📊 Results"
echo "=========="
echo "Checks passed: $CHECKS_PASSED"
echo "Checks failed: $CHECKS_FAILED"

if [ $CHECKS_FAILED -eq 0 ]; then
    echo ""
    echo "✅ Everything looks good! You can run the migration:"
    echo "./migrate-site.sh $DOMAIN \"Site Name\" \"Site Description\""
    exit 0
else
    echo ""
    echo "❌ Please fix the failed checks before running migration"
    exit 1
fi