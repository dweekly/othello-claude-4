#!/bin/bash

# Strict CI Test Script
# Runs tests in a clean environment mimicking GitHub Actions exactly

set -e  # Exit on any error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Strict CI Environment Test${NC}"
echo "=============================="
echo "This script mimics GitHub Actions environment exactly"
echo ""

# Check and switch to CI Xcode version if available
CI_XCODE_VERSION="16.2"
ORIGINAL_XCODE=$(xcode-select -p)
ORIGINAL_DIR=$(pwd)
SWITCHED_XCODE=false

echo -e "${BLUE}🔄 Xcode Version Check${NC}"
echo "----------------------"
CURRENT_XCODE=$(xcodebuild -version | head -1)
echo "Current Xcode: $CURRENT_XCODE"
echo "GitHub Actions uses: Xcode $CI_XCODE_VERSION"

# Check if we have the CI version installed
if [ -d "/Applications/Xcode-${CI_XCODE_VERSION}.app" ]; then
    echo -e "${YELLOW}Found Xcode $CI_XCODE_VERSION - switching to match CI environment${NC}"
    sudo xcode-select -s "/Applications/Xcode-${CI_XCODE_VERSION}.app" 2>/dev/null || {
        echo -e "${YELLOW}Note: Need sudo permission to switch Xcode versions${NC}"
    }
    if xcodebuild -version | grep -q "$CI_XCODE_VERSION"; then
        echo -e "${GREEN}✅ Switched to Xcode $CI_XCODE_VERSION${NC}"
        SWITCHED_XCODE=true
        export DEVELOPER_DIR="/Applications/Xcode-${CI_XCODE_VERSION}.app/Contents/Developer"
    fi
else
    echo -e "${YELLOW}⚠️  Xcode $CI_XCODE_VERSION not found${NC}"
    echo "To install it for exact CI matching:"
    echo "  ./scripts/xcode-ci-setup.sh"
    echo ""
    echo "This will guide you through manual installation (xcodes doesn't work with hardware keys)"
    echo ""
    echo -n "Continue with current Xcode version? (y/N) "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo ""
        echo "Run ./scripts/xcode-ci-setup.sh for installation instructions"
        exit 1
    fi
    echo -e "${YELLOW}⚠️  Using different Xcode version than CI${NC}"
    echo "Results may differ from GitHub Actions"
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi
echo ""

# 1. Create clean temporary workspace
WORKSPACE=$(mktemp -d)
echo -e "${BLUE}📁 Creating clean workspace: $WORKSPACE${NC}"

# Copy project to clean workspace
cp -R . "$WORKSPACE/" 2>/dev/null || true
cd "$WORKSPACE"

# Remove any existing build artifacts
echo -e "${BLUE}🧹 Cleaning build artifacts...${NC}"
rm -rf Othello.xcodeproj build/ DerivedData/ TestResults.xcresult *.json .build/ 2>/dev/null || true

# 2. Set GitHub Actions environment variables
echo -e "${BLUE}🌍 Setting CI environment variables...${NC}"
export CI=true
export GITHUB_ACTIONS=true
export RUNNER_OS=macOS

# 3. Validate environment
echo -e "${BLUE}🔍 Environment validation...${NC}"
echo "CI=$CI"
echo "GITHUB_ACTIONS=$GITHUB_ACTIONS"
echo "RUNNER_OS=$RUNNER_OS"
echo "DEVELOPER_DIR=$DEVELOPER_DIR"
echo "Xcode: $(xcodebuild -version | head -1)"
echo "Swift: $(swift --version | head -1)"
echo ""

# 4. Install dependencies check
echo -e "${BLUE}📦 Checking dependencies...${NC}"
MISSING_DEPS=0
for dep in xcodegen swiftlint; do
    if ! command -v $dep &> /dev/null; then
        echo -e "${RED}❌ Missing: $dep${NC}"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    else
        echo -e "${GREEN}✅ Found: $dep${NC}"
    fi
done

if [ $MISSING_DEPS -gt 0 ]; then
    echo -e "${RED}Please install missing dependencies with brew${NC}"
    exit 1
fi
echo ""

# 5. Generate Xcode Project (exactly like CI)
echo -e "${BLUE}🔧 Step 1: Generate Xcode Project${NC}"
echo "Running: xcodegen generate"
if xcodegen generate; then
    echo -e "${GREEN}✅ Project generated successfully${NC}"
else
    echo -e "${RED}❌ Project generation failed${NC}"
    exit 1
fi
echo ""

# 6. Validate Project (exactly like CI)
echo -e "${BLUE}🔍 Step 2: Validate Project Configuration${NC}"
if [ -f "Othello.xcodeproj/project.pbxproj" ]; then
    if grep -q "Othello" Othello.xcodeproj/project.pbxproj && grep -q "OthelloTests" Othello.xcodeproj/project.pbxproj; then
        echo -e "${GREEN}✅ Expected targets found${NC}"
    else
        echo -e "${RED}❌ Expected targets not found${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Project file not generated${NC}"
    exit 1
fi
echo ""

# 7. Build with strict concurrency (exactly like CI)
echo -e "${BLUE}🔨 Step 3: Build with Strict Concurrency${NC}"
echo "Running: xcodebuild build -scheme Othello -destination 'platform=macOS' SWIFT_STRICT_CONCURRENCY=complete"
if xcodebuild build -scheme Othello -destination 'platform=macOS' SWIFT_STRICT_CONCURRENCY=complete 2>&1 | tee build.log | xcbeautify; then
    echo -e "${GREEN}✅ Build successful with strict concurrency${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    echo "Check build.log for details"
    exit 1
fi
echo ""

# 8. Run SwiftLint (exactly like CI)
echo -e "${BLUE}🎨 Step 4: Run SwiftLint${NC}"
LINT_OUTPUT=$(swiftlint lint --reporter json 2>/dev/null || true)
VIOLATIONS=$(echo "$LINT_OUTPUT" | jq '. | length' 2>/dev/null || echo "0")
echo "Found $VIOLATIONS violations"

if swiftlint lint --reporter github-actions-logging; then
    echo -e "${GREEN}✅ SwiftLint passed${NC}"
else
    echo -e "${YELLOW}⚠️  SwiftLint found issues (non-blocking in CI)${NC}"
fi
echo ""

# 9. Run Tests with strict concurrency (exactly like CI)
echo -e "${BLUE}🧪 Step 5: Run Tests${NC}"
echo "Running: xcodebuild test with coverage and strict concurrency"
if xcodebuild test \
    -scheme Othello \
    -destination 'platform=macOS' \
    -enableCodeCoverage YES \
    -resultBundlePath TestResults.xcresult \
    SWIFT_STRICT_CONCURRENCY=complete 2>&1 | tee test.log | xcbeautify; then
    echo -e "${GREEN}✅ Tests passed${NC}"
else
    echo -e "${RED}❌ Tests failed${NC}"
    echo "Check test.log for details"
    exit 1
fi
echo ""

# 10. Verify Swift Testing Results (exactly like CI)
echo -e "${BLUE}✅ Step 6: Verify Swift Testing Results${NC}"
if [ -d "TestResults.xcresult" ]; then
    echo -e "${GREEN}✅ Test results bundle created${NC}"
    
    # Extract results
    xcrun xcresulttool get --format json --path TestResults.xcresult > test_results.json 2>/dev/null || true
    
    # Check bundle size
    BUNDLE_SIZE=$(du -sh TestResults.xcresult | cut -f1)
    echo "Bundle size: $BUNDLE_SIZE"
    
    # Try to detect Swift Testing
    if grep -q "Swift Testing" test_results.json 2>/dev/null; then
        echo -e "${GREEN}✅ Swift Testing framework detected${NC}"
    else
        # Alternative detection
        if [ -f "test_results.json" ] && [ -s "test_results.json" ]; then
            echo -e "${YELLOW}⚠️  Swift Testing not explicitly detected, but tests ran${NC}"
        else
            echo -e "${RED}❌ No test results found${NC}"
            exit 1
        fi
    fi
else
    echo -e "${RED}❌ No test results bundle found${NC}"
    exit 1
fi
echo ""

# 11. Generate Code Coverage (exactly like CI)
echo -e "${BLUE}📊 Step 7: Generate Code Coverage${NC}"
if xcrun xccov view --report --json TestResults.xcresult > coverage.json 2>/dev/null; then
    COVERAGE_SIZE=$(wc -c < coverage.json)
    echo -e "${GREEN}✅ Coverage report generated ($COVERAGE_SIZE bytes)${NC}"
else
    echo -e "${YELLOW}⚠️  Coverage generation failed (non-critical)${NC}"
fi
echo ""

# 12. Performance Test (exactly like CI quality-gates job)
echo -e "${BLUE}⏱️  Step 8: Performance Benchmarks${NC}"
if xcodebuild test \
    -scheme Othello \
    -destination 'platform=macOS' \
    -only-testing:OthelloTests/FastGameTests/testGameEnginePerformance 2>&1 | xcbeautify; then
    echo -e "${GREEN}✅ Performance tests completed${NC}"
else
    echo -e "${YELLOW}⚠️  Performance tests completed with warnings${NC}"
fi
echo ""

# 13. Summary
echo -e "${BLUE}📊 Test Summary${NC}"
echo "=============="
echo -e "${GREEN}✅ All CI steps completed${NC}"
echo ""
echo "Artifacts generated:"
ls -la TestResults.xcresult test_results.json coverage.json 2>/dev/null || echo "Some artifacts may be missing"
echo ""

# 14. Cleanup instructions
echo -e "${YELLOW}🧹 Cleanup${NC}"
echo "This test ran in: $WORKSPACE"
echo "To clean up, run:"
echo "  rm -rf $WORKSPACE"
echo ""

echo -e "${GREEN}🎉 Your code should pass GitHub Actions CI!${NC}"
echo ""
echo "💡 Tips:"
echo "  - If this passes but GitHub Actions fails, check Xcode version differences"
echo "  - Run './scripts/validate-ci-environment.sh' to check for mismatches"
echo "  - Consider installing Xcode 16.2 to match GitHub Actions exactly"

# Return to original directory
cd "$ORIGINAL_DIR" > /dev/null

# Restore original Xcode if we switched
if [ "$SWITCHED_XCODE" = true ]; then
    echo ""
    echo -e "${BLUE}🔄 Restoring original Xcode version${NC}"
    sudo xcode-select -s "$ORIGINAL_XCODE" 2>/dev/null || {
        echo -e "${YELLOW}Note: Need sudo permission to restore Xcode version${NC}"
    }
    echo -e "${GREEN}✅ Restored to: $(xcodebuild -version | head -1)${NC}"
fi

exit 0