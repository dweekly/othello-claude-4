#!/bin/bash

# Validate CI Environment Parity
# Checks for differences between local and GitHub Actions environments

set -e

echo "🔍 CI Environment Validation"
echo "============================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track warnings
WARNINGS=0

# 1. Check Xcode Version
echo "📱 Xcode Version Check"
echo "---------------------"
LOCAL_XCODE=$(xcodebuild -version | head -1)
LOCAL_XCODE_BUILD=$(xcodebuild -version | tail -1)
echo "Local: $LOCAL_XCODE ($LOCAL_XCODE_BUILD)"
echo "GitHub Actions: Xcode 16.2.0 (latest macos-latest)"

if [[ "$LOCAL_XCODE" =~ "16.3" ]]; then
    echo -e "${YELLOW}⚠️  Version mismatch detected${NC}"
    echo "   Your Xcode (16.3) is newer than GitHub Actions (16.2)"
    echo "   This may cause Swift Testing framework differences"
    WARNINGS=$((WARNINGS + 1))
elif [[ "$LOCAL_XCODE" =~ "16.2" ]]; then
    echo -e "${GREEN}✅ Version matches GitHub Actions${NC}"
else
    echo -e "${RED}❌ Unexpected Xcode version${NC}"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# 2. Check Swift Version
echo "🦉 Swift Version Check"
echo "--------------------"
SWIFT_VERSION=$(swift --version | head -1)
echo "Local: $SWIFT_VERSION"
echo ""

# 3. Check Swift Testing Support
echo "🧪 Swift Testing Framework Check"
echo "-------------------------------"
if swift test list 2>&1 | grep -q "OthelloTests"; then
    echo -e "${GREEN}✅ Swift Testing framework detected${NC}"
else
    echo -e "${YELLOW}⚠️  Swift Testing framework not detected in list${NC}"
    echo "   Trying alternative detection..."
    if xcodebuild -list -project Othello.xcodeproj 2>/dev/null | grep -q "OthelloTests"; then
        echo -e "${GREEN}✅ Test target found in project${NC}"
    else
        echo -e "${RED}❌ Test target not found${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
fi
echo ""

# 4. Check Required Tools
echo "🔧 Required Tools Check"
echo "---------------------"
REQUIRED_TOOLS=(xcodegen swiftlint git)
for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v $tool &> /dev/null; then
        VERSION=$($tool --version 2>&1 | head -1 || echo "installed")
        echo -e "${GREEN}✅ $tool: $VERSION${NC}"
    else
        echo -e "${RED}❌ $tool: NOT FOUND${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
done
echo ""

# 5. Check Environment Variables
echo "🌍 Environment Variables"
echo "----------------------"
echo "DEVELOPER_DIR: ${DEVELOPER_DIR:-not set}"
echo "CI: ${CI:-not set (local)}"
echo "GITHUB_ACTIONS: ${GITHUB_ACTIONS:-not set (local)}"
echo ""

# 6. Check Strict Concurrency Support
echo "🔒 Swift Strict Concurrency Check"
echo "--------------------------------"
echo "Testing SWIFT_STRICT_CONCURRENCY=complete flag..."
# Create a simple test
TEMP_FILE=$(mktemp).swift
cat > "$TEMP_FILE" << 'EOF'
@MainActor
class Test {
    var value = 0
}
EOF

if swiftc -parse -strict-concurrency=complete "$TEMP_FILE" 2>&1 | grep -q "error"; then
    echo -e "${RED}❌ Strict concurrency check failed${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Strict concurrency supported${NC}"
fi
rm -f "$TEMP_FILE"
echo ""

# 7. Check for CI-specific flags
echo "🚩 CI Build Flags"
echo "----------------"
echo "GitHub Actions uses:"
echo "  - SWIFT_STRICT_CONCURRENCY=complete"
echo "  - -enableCodeCoverage YES"
echo "  - -resultBundlePath TestResults.xcresult"
echo "  - Platform: macOS (not iOS Simulator)"
echo ""

# 8. Summary and Recommendations
echo "📊 Summary"
echo "========="
if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Environment is well-aligned with CI${NC}"
    echo ""
    echo "🚀 You can confidently run:"
    echo "   ./scripts/test-ci-locally.sh"
else
    echo -e "${YELLOW}⚠️  Found $WARNINGS potential issues${NC}"
    echo ""
    echo "📋 Recommendations:"
    
    if [[ "$LOCAL_XCODE" =~ "16.3" ]]; then
        echo "  1. Consider installing Xcode 16.2 for exact CI matching:"
        echo "     - Download from https://developer.apple.com/download/more/"
        echo "     - Install as /Applications/Xcode_16.2.app"
        echo "     - Switch with: sudo xcode-select -s /Applications/Xcode_16.2.app"
    fi
    
    echo "  2. Always test with CI flags before pushing:"
    echo "     ./scripts/test-ci-locally.sh"
    
    echo "  3. For quick validation:"
    echo "     ./scripts/quick-ci-check.sh"
fi

echo ""
echo "💡 To simulate GitHub Actions environment:"
echo "   export CI=true"
echo "   export GITHUB_ACTIONS=true"
echo "   export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer"

exit 0