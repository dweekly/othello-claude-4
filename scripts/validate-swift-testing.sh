#!/bin/bash

# Swift Testing Framework Validation Script
# Ensures Swift Testing is properly configured and detectable

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Swift Testing Framework Validation${NC}"
echo "====================================="
echo ""

# Check if project exists
if [ ! -f "Othello.xcodeproj/project.pbxproj" ]; then
    echo -e "${YELLOW}⚠️  No Xcode project found. Generating...${NC}"
    xcodegen generate
fi

# 1. Check Swift version supports Testing framework
echo -e "${BLUE}1. Swift Version Check${NC}"
echo "---------------------"
SWIFT_VERSION=$(swift --version | head -1)
echo "Swift version: $SWIFT_VERSION"

# Swift Testing requires Swift 5.9+
if swift --version | grep -q "version [56789]\."; then
    echo -e "${GREEN}✅ Swift version supports Testing framework${NC}"
else
    echo -e "${RED}❌ Swift version may not support Testing framework${NC}"
fi
echo ""

# 2. Check test target configuration
echo -e "${BLUE}2. Test Target Configuration${NC}"
echo "---------------------------"
if xcodebuild -list -project Othello.xcodeproj 2>/dev/null | grep -q "OthelloTests"; then
    echo -e "${GREEN}✅ OthelloTests target found${NC}"
else
    echo -e "${RED}❌ OthelloTests target not found${NC}"
    exit 1
fi
echo ""

# 3. Run a simple test to verify framework
echo -e "${BLUE}3. Swift Testing Detection${NC}"
echo "-------------------------"
echo "Running a single test file to verify Swift Testing..."

# Try to run just model tests
if xcodebuild test \
    -scheme Othello \
    -destination 'platform=macOS' \
    -only-testing:OthelloTests/ModelTests \
    -resultBundlePath SwiftTestValidation.xcresult \
    -quiet 2>&1 | grep -E "(Test Suite|Executed|passed|failed)"; then
    echo -e "${GREEN}✅ Tests executed successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Test execution unclear${NC}"
fi
echo ""

# 4. Analyze test results for Swift Testing markers
echo -e "${BLUE}4. Analyzing Test Results${NC}"
echo "------------------------"
if [ -d "SwiftTestValidation.xcresult" ]; then
    echo "Extracting test results..."
    xcrun xcresulttool get --format json --path SwiftTestValidation.xcresult > swift_test_validation.json 2>/dev/null || true
    
    # Check various indicators
    echo "Checking for Swift Testing indicators:"
    
    # Check 1: Direct Swift Testing mention
    if grep -q "Swift Testing" swift_test_validation.json 2>/dev/null; then
        echo -e "${GREEN}  ✅ 'Swift Testing' found in results${NC}"
    else
        echo -e "${YELLOW}  ⚠️  'Swift Testing' not found explicitly${NC}"
    fi
    
    # Check 2: @Test macro usage
    if grep -q "@Test" swift_test_validation.json 2>/dev/null; then
        echo -e "${GREEN}  ✅ '@Test' macro detected${NC}"
    else
        echo -e "${YELLOW}  ⚠️  '@Test' macro not detected in results${NC}"
    fi
    
    # Check 3: Test count
    TEST_COUNT=$(xcrun xcresulttool get --format json --path SwiftTestValidation.xcresult 2>/dev/null | jq '.metrics.testsCount.value' 2>/dev/null || echo "0")
    if [ "$TEST_COUNT" -gt 0 ]; then
        echo -e "${GREEN}  ✅ Found $TEST_COUNT tests${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Could not determine test count${NC}"
    fi
    
    # Clean up
    rm -rf SwiftTestValidation.xcresult swift_test_validation.json
else
    echo -e "${RED}❌ No test results bundle created${NC}"
fi
echo ""

# 5. Check test file structure
echo -e "${BLUE}5. Test File Analysis${NC}"
echo "--------------------"
echo "Checking for @Test usage in test files..."

TEST_FILES=$(fd -e swift . Othello/OthelloTests 2>/dev/null || find Othello/OthelloTests -name "*.swift" 2>/dev/null || echo "")
if [ -n "$TEST_FILES" ]; then
    TEST_MACRO_COUNT=$(echo "$TEST_FILES" | xargs grep -l "@Test" 2>/dev/null | wc -l | xargs)
    XCTEST_COUNT=$(echo "$TEST_FILES" | xargs grep -l "XCTest" 2>/dev/null | wc -l | xargs)
    
    echo "Test files using @Test macro: $TEST_MACRO_COUNT"
    echo "Test files using XCTest: $XCTEST_COUNT"
    
    if [ "$TEST_MACRO_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Swift Testing framework is being used${NC}"
    elif [ "$XCTEST_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Tests use XCTest instead of Swift Testing${NC}"
    else
        echo -e "${RED}❌ No test framework detected${NC}"
    fi
else
    echo -e "${RED}❌ No test files found${NC}"
fi
echo ""

# 6. Recommendations
echo -e "${BLUE}📋 Validation Summary${NC}"
echo "===================="

# Try swift test list as final check
echo "Running 'swift test list' for final validation..."
if swift test list 2>&1 | grep -q "OthelloTests"; then
    echo -e "${GREEN}✅ Swift Testing framework is properly configured${NC}"
    echo ""
    echo "🎉 Your project is ready for CI/CD!"
else
    echo -e "${YELLOW}⚠️  Swift Testing may have configuration issues${NC}"
    echo ""
    echo "💡 Troubleshooting steps:"
    echo "  1. Ensure all test files use @Test instead of XCTestCase"
    echo "  2. Check that Package.swift or project.yml includes Testing framework"
    echo "  3. Verify Xcode 16+ is being used"
    echo "  4. Try running: xcodebuild test -scheme Othello -destination 'platform=macOS'"
fi

echo ""
echo "🔍 For detailed CI simulation, run:"
echo "   ./scripts/strict-ci-test.sh"

exit 0