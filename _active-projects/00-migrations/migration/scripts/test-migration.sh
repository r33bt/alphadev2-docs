#!/bin/bash
# test-migration.sh - Test migration automation scripts
# Usage: ./test-migration.sh

echo "🧪 Testing Migration Automation Scripts"
echo "======================================"

# Test domain (use a fake domain for testing)
TEST_DOMAIN="test-site.com"
TEST_SITE_NAME="Test Site"
TEST_DESCRIPTION="Test Site Description"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command"; then
        if [ "$expected_result" = "pass" ]; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC} (expected to fail but passed)"
            ((TESTS_FAILED++))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo -e "${YELLOW}PASS${NC} (correctly failed)"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC}"
            ((TESTS_FAILED++))
        fi
    fi
}

echo ""
echo "1. Testing Prerequisites"
echo "------------------------"

# Test if scripts exist
run_test "migrate-site.sh exists" "[ -f './migrate-site.sh' ]" "pass"
run_test "setup-wordpress.sh exists" "[ -f './setup-wordpress.sh' ]" "pass"
run_test "customize-template.sh exists" "[ -f './customize-template.sh' ]" "pass"
run_test "setup-environment.sh exists" "[ -f './setup-environment.sh' ]" "pass"

# Test if scripts are executable
run_test "migrate-site.sh is executable" "[ -x './migrate-site.sh' ]" "pass"
run_test "setup-wordpress.sh is executable" "[ -x './setup-wordpress.sh' ]" "pass"
run_test "customize-template.sh is executable" "[ -x './customize-template.sh' ]" "pass"
run_test "setup-environment.sh is executable" "[ -x './setup-environment.sh' ]" "pass"

echo ""
echo "2. Testing Script Argument Validation"
echo "--------------------------------------"

# Test argument validation
run_test "migrate-site.sh without args fails" "./migrate-site.sh 2>/dev/null" "fail"
run_test "migrate-site.sh with 1 arg fails" "./migrate-site.sh test.com 2>/dev/null" "fail"
run_test "migrate-site.sh with 2 args fails" "./migrate-site.sh test.com 'Test' 2>/dev/null" "fail"

run_test "customize-template.sh without args fails" "./customize-template.sh 2>/dev/null" "fail"
run_test "setup-wordpress.sh without args fails" "./setup-wordpress.sh 2>/dev/null" "fail"
run_test "setup-environment.sh without args fails" "./setup-environment.sh 2>/dev/null" "fail"

echo ""
echo "3. Testing Template Customization (Dry Run)"
echo "--------------------------------------------"

# Create a test template directory
mkdir -p test-stocktiming-template
cat > test-stocktiming-template/test.tsx << 'EOF'
export default function Test() {
  return (
    <div>
      <h1>StockTiming.com</h1>
      <p>Professional Trading Strategies & Market Analysis</p>
      <span>StockTiming Team</span>
      <a href="https://stocktiming.com">stocktiming.com</a>
      <url>https://staging.stocktiming.com</url>
      <token>stocktiming-revalidate-2025</token>
    </div>
  );
}
EOF

# Test template customization logic (modify the script temporarily for testing)
sed 's|"C:\\Users\\user\\alphadev2\\migration\\projects\\stocktiming-headless"|test-stocktiming-template|g' customize-template.sh > test-customize.sh
chmod +x test-customize.sh

echo -n "Testing template customization logic... "
if ./test-customize.sh "$TEST_DOMAIN" "$TEST_SITE_NAME" "$TEST_DESCRIPTION" >/dev/null 2>&1; then
    # Check if the customization worked
    if [ -d "${TEST_DOMAIN}-headless" ]; then
        STOCKTIMING_FILES=$(find "${TEST_DOMAIN}-headless" -name "*.tsx" | xargs grep -l "StockTiming\|stocktiming\.com" 2>/dev/null | wc -l)
        if [ "$STOCKTIMING_FILES" -eq 0 ]; then
            echo -e "${GREEN}PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}FAIL${NC} (StockTiming references still found)"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}FAIL${NC} (directory not created)"
        ((TESTS_FAILED++))
    fi
else
    echo -e "${RED}FAIL${NC} (script execution failed)"
    ((TESTS_FAILED++))
fi

echo ""
echo "4. Testing Credential File Validation"
echo "--------------------------------------"

# Test that migrate-site.sh properly checks for staging site (this will fail due to network)
run_test "Staging site check works" "./migrate-site.sh test.com 'Test' 'Test' 2>&1 | grep -q 'Staging site not accessible'" "pass"

echo ""
echo "5. Testing Error Handling"
echo "-------------------------"

# Test that scripts fail properly with invalid staging sites
run_test "Invalid staging site fails" "timeout 10s ./migrate-site.sh nonexistent-domain.com 'Test' 'Test' 2>/dev/null" "fail"

echo ""
echo "📊 Test Results"
echo "==============="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

# Cleanup
rm -rf test-stocktiming-template "${TEST_DOMAIN}-headless" test-customize.sh 2>/dev/null

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed! Scripts are ready for use.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Check the scripts before using.${NC}"
    exit 1
fi