#!/bin/bash
# test-template-only.sh - Quick test of just the template customization
# Usage: ./test-template-only.sh

echo "🧪 Quick Template Customization Test"
echo "====================================="

# Create a mock StockTiming template for testing
mkdir -p mock-stocktiming-template/src/app
mkdir -p mock-stocktiming-template/src/components

# Create test files with StockTiming references
cat > mock-stocktiming-template/src/app/page.tsx << 'EOF'
export default function Home() {
  return (
    <div>
      <h1>StockTiming.com</h1>
      <p>Professional Trading Strategies & Market Analysis</p>
      <span>By StockTiming Team</span>
    </div>
  );
}
EOF

cat > mock-stocktiming-template/src/components/Header.tsx << 'EOF'
export default function Header() {
  return (
    <header>
      <a href="https://stocktiming.com">StockTiming</a>
      <p>Visit staging.stocktiming.com for updates</p>
      <token>stocktiming-revalidate-2025</token>
    </header>
  );
}
EOF

echo "Created mock template with StockTiming references"

# Create a modified version of customize-template.sh for testing
sed 's|"C:\\Users\\user\\alphadev2\\migration\\projects\\stocktiming-headless"|mock-stocktiming-template|g' customize-template.sh > test-customize-template.sh
chmod +x test-customize-template.sh

# Test the customization
echo "Running template customization..."
if ./test-customize-template.sh "example.com" "Example Site" "Example site description"; then
    echo "✅ Template customization completed"
    
    # Check results
    echo ""
    echo "📋 Checking results in example.com-headless/"
    
    if [ -d "example.com-headless" ]; then
        echo "✅ Directory created successfully"
        
        # Check for remaining StockTiming references
        STOCKTIMING_COUNT=$(find example.com-headless -name "*.tsx" | xargs grep -c "StockTiming\|stocktiming\.com" 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
        
        if [ "$STOCKTIMING_COUNT" -eq 0 ]; then
            echo "✅ All StockTiming references removed successfully"
        else
            echo "❌ Found $STOCKTIMING_COUNT remaining StockTiming references:"
            find example.com-headless -name "*.tsx" | xargs grep -n "StockTiming\|stocktiming\.com" 2>/dev/null
        fi
        
        # Show what the files look like now
        echo ""
        echo "📄 Contents of customized page.tsx:"
        echo "-----------------------------------"
        cat example.com-headless/src/app/page.tsx
        
        echo ""
        echo "📄 Contents of customized Header.tsx:"
        echo "-------------------------------------"
        cat example.com-headless/src/components/Header.tsx
        
    else
        echo "❌ Directory was not created"
    fi
else
    echo "❌ Template customization failed"
fi

# Cleanup
echo ""
echo "🧹 Cleaning up test files..."
rm -rf mock-stocktiming-template example.com-headless test-customize-template.sh

echo "Test complete!"