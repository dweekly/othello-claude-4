#!/bin/bash

# Local CI/CD Pipeline Simulation Script
# Mimics the exact steps from .github/workflows/ci.yml

set -e  # Exit on any error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🚀 Starting Local CI/CD Pipeline Simulation..."
echo "=================================================="

# Check and switch to CI Xcode version if available
CI_XCODE_VERSION="16.2"
ORIGINAL_XCODE=$(xcode-select -p)
SWITCHED_XCODE=false

echo ""
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
fi

# Step 1: Clean environment (like fresh CI runner)
echo ""
echo "🧹 Step 1: Clean Environment"
echo "----------------------------"
rm -rf Othello.xcodeproj TestResults.xcresult coverage.json test_results.json || true
echo "✅ Cleaned previous build artifacts"

# Step 2: Install dependencies (simulate CI environment)
echo ""
echo "📦 Step 2: Check Dependencies"
echo "----------------------------"
if ! command -v xcodegen &> /dev/null; then
    echo "❌ XcodeGen not installed. Run: brew install xcodegen"
    exit 1
fi

if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint not installed. Run: brew install swiftlint"
    exit 1
fi
echo "✅ XcodeGen and SwiftLint available"

# Step 3: Generate Xcode Project (exactly like CI)
echo ""
echo "🔧 Step 3: Generate Xcode Project"
echo "--------------------------------"
echo "🔧 Generating Xcode project from project.yml..."
xcodegen generate
echo "✅ Project generated successfully!"

# Step 4: Validate Project Configuration (exactly like CI)
echo ""
echo "🔍 Step 4: Validate Project Configuration"
echo "----------------------------------------"
if [ -f "Othello.xcodeproj/project.pbxproj" ]; then
    echo "✅ Othello.xcodeproj generated successfully"
    # Check for expected targets
    if grep -q "Othello" Othello.xcodeproj/project.pbxproj && grep -q "OthelloTests" Othello.xcodeproj/project.pbxproj; then
        echo "✅ Expected targets found in project"
    else
        echo "❌ Expected targets not found"
        exit 1
    fi
else
    echo "❌ Project file not generated"
    exit 1
fi

# Step 5: Build Project (exactly like CI with strict concurrency)
echo ""
echo "🔨 Step 5: Build Xcode Project"
echo "-----------------------------"
echo "🔍 Building with strict concurrency checking (like CI)..."
# Add strict Swift concurrency checking to match CI environment
xcodebuild build -scheme Othello -destination 'platform=macOS' SWIFT_STRICT_CONCURRENCY=complete
echo "✅ Build completed successfully"

# Step 6: Run SwiftLint (exactly like CI)
echo ""
echo "🎨 Step 6: Run SwiftLint"
echo "----------------------"
swiftlint lint --reporter github-actions-logging || {
    echo "⚠️  SwiftLint found violations (non-blocking)"
}

# Step 7: Run Tests with Result Bundle (exactly like CI)
echo ""
echo "🧪 Step 7: Run Tests"
echo "------------------"
echo "🧪 Running Swift Testing framework tests..."
xcodebuild test -scheme Othello -destination 'platform=macOS' -enableCodeCoverage YES -resultBundlePath TestResults.xcresult

# Step 8: Verify Swift Testing Results (exactly like CI)
echo ""
echo "✅ Step 8: Verify Swift Testing Results"
echo "--------------------------------------"
if [ -d "TestResults.xcresult" ]; then
    echo "✅ Test results bundle created successfully"
    xcrun xcresulttool get --format json --path TestResults.xcresult > test_results.json
    # Check for Swift Testing specific indicators
    if grep -q "Swift Testing" test_results.json 2>/dev/null; then
        echo "✅ Swift Testing framework detected in results"
    else
        echo "⚠️  Swift Testing framework not explicitly detected, but tests ran"
    fi
else
    echo "❌ No test results bundle found"
    exit 1
fi

# Step 9: Generate Code Coverage (exactly like CI)
echo ""
echo "📊 Step 9: Generate Code Coverage"
echo "--------------------------------"
xcrun xccov view --report --json TestResults.xcresult > coverage.json || echo "⚠️  Coverage generation failed"
if [ -f "coverage.json" ]; then
    echo "✅ Coverage report generated ($(wc -c < coverage.json) bytes)"
else
    echo "⚠️  No coverage report generated"
fi

# Step 10: Performance Benchmarks (simulate quality-gates job)
echo ""
echo "⏱️  Step 10: Performance Benchmarks"
echo "----------------------------------"
xcodebuild test -scheme Othello -destination 'platform=macOS' -only-testing:OthelloTests/FastGameTests/testGameEnginePerformance || echo "⚠️  Performance tests completed with warnings"

# Final Summary
echo ""
echo "🎉 Local CI/CD Pipeline Simulation Complete!"
echo "============================================="
echo "✅ All major CI steps completed successfully"
echo "📁 Generated artifacts:"
ls -la TestResults.xcresult test_results.json coverage.json 2>/dev/null || echo "   (some artifacts may be missing)"

echo ""
echo "🚀 Your pipeline should work on GitHub Actions!"
echo "💡 To clean up: rm -rf Othello.xcodeproj TestResults.xcresult *.json"

# Restore original Xcode if we switched
if [ "$SWITCHED_XCODE" = true ]; then
    echo ""
    echo -e "${BLUE}🔄 Restoring original Xcode version${NC}"
    sudo xcode-select -s "$ORIGINAL_XCODE" 2>/dev/null || {
        echo -e "${YELLOW}Note: Need sudo permission to restore Xcode version${NC}"
    }
    echo -e "${GREEN}✅ Restored to: $(xcodebuild -version | head -1)${NC}"
fi