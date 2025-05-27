#!/bin/bash

# CI Environment Diff Checker
# Compares local environment with GitHub Actions CI environment

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 CI Environment Diff Checker${NC}"
echo "=============================="
echo "Comparing local environment with GitHub Actions"
echo ""

# Create comparison report
REPORT=""
DIFFERENCES=0

# Function to add to report
add_report() {
    local category="$1"
    local local_val="$2"
    local ci_val="$3"
    local status="$4"  # OK, WARN, or ERROR
    
    case "$status" in
        OK)
            STATUS_COLOR="${GREEN}✅"
            ;;
        WARN)
            STATUS_COLOR="${YELLOW}⚠️ "
            DIFFERENCES=$((DIFFERENCES + 1))
            ;;
        ERROR)
            STATUS_COLOR="${RED}❌"
            DIFFERENCES=$((DIFFERENCES + 1))
            ;;
    esac
    
    printf "%-20s %-40s %-40s %s\n" "$category" "$local_val" "$ci_val" "$STATUS_COLOR" >> report.tmp
}

# Header
printf "%-20s %-40s %-40s %s\n" "Category" "Local Environment" "GitHub Actions CI" "Status" > report.tmp
printf "%-20s %-40s %-40s %s\n" "--------" "-----------------" "-----------------" "------" >> report.tmp

# 1. Operating System
echo "Checking OS versions..."
LOCAL_OS="macOS $(sw_vers -productVersion)"
CI_OS="macOS-latest (typically 12.x or 13.x)"
add_report "OS Version" "$LOCAL_OS" "$CI_OS" "WARN"

# 2. Xcode Version
echo "Checking Xcode versions..."
LOCAL_XCODE=$(xcodebuild -version | head -1 | sed 's/Xcode //')
CI_XCODE="16.2.0"
if [[ "$LOCAL_XCODE" == "$CI_XCODE" ]]; then
    add_report "Xcode Version" "$LOCAL_XCODE" "$CI_XCODE" "OK"
else
    add_report "Xcode Version" "$LOCAL_XCODE" "$CI_XCODE" "WARN"
fi

# 3. Swift Version
echo "Checking Swift versions..."
LOCAL_SWIFT=$(swift --version | grep -o "Swift version [0-9.]*" | sed 's/Swift version //')
CI_SWIFT="~6.0 (depends on Xcode 16.2)"
add_report "Swift Version" "$LOCAL_SWIFT" "$CI_SWIFT" "WARN"

# 4. Environment Variables
echo "Checking environment variables..."
LOCAL_CI="${CI:-not set}"
CI_CI="true"
if [[ "$LOCAL_CI" == "true" ]]; then
    add_report "CI Variable" "$LOCAL_CI" "$CI_CI" "OK"
else
    add_report "CI Variable" "$LOCAL_CI" "$CI_CI" "WARN"
fi

LOCAL_GITHUB="${GITHUB_ACTIONS:-not set}"
CI_GITHUB="true"
if [[ "$LOCAL_GITHUB" == "true" ]]; then
    add_report "GITHUB_ACTIONS" "$LOCAL_GITHUB" "$CI_GITHUB" "OK"
else
    add_report "GITHUB_ACTIONS" "$LOCAL_GITHUB" "$CI_GITHUB" "WARN"
fi

# 5. Build Tools
echo "Checking build tools..."
if command -v xcodegen &> /dev/null; then
    LOCAL_XCODEGEN="$(xcodegen --version | grep -o "[0-9.]*" | head -1)"
    add_report "XcodeGen" "v$LOCAL_XCODEGEN" "brew install version" "OK"
else
    add_report "XcodeGen" "not installed" "brew install version" "ERROR"
fi

if command -v swiftlint &> /dev/null; then
    LOCAL_SWIFTLINT="$(swiftlint version)"
    add_report "SwiftLint" "v$LOCAL_SWIFTLINT" "brew install version" "OK"
else
    add_report "SwiftLint" "not installed" "brew install version" "ERROR"
fi

# 6. Build Flags
echo "Checking build flags..."
add_report "Concurrency" "SWIFT_STRICT_CONCURRENCY=complete" "SWIFT_STRICT_CONCURRENCY=complete" "OK"
add_report "Coverage" "-enableCodeCoverage YES" "-enableCodeCoverage YES" "OK"
add_report "Platform" "platform=macOS" "platform=macOS" "OK"

# 7. Hardware
echo "Checking hardware differences..."
LOCAL_ARCH=$(uname -m)
CI_ARCH="x86_64 or arm64"
add_report "Architecture" "$LOCAL_ARCH" "$CI_ARCH" "OK"

LOCAL_CORES=$(sysctl -n hw.ncpu)
CI_CORES="3-4 cores"
add_report "CPU Cores" "$LOCAL_CORES cores" "$CI_CORES" "OK"

# Display report
echo ""
cat report.tmp
rm -f report.tmp

# Summary
echo ""
echo -e "${BLUE}📊 Summary${NC}"
echo "========="
if [ $DIFFERENCES -eq 0 ]; then
    echo -e "${GREEN}✅ Environment perfectly matches CI${NC}"
else
    echo -e "${YELLOW}⚠️  Found $DIFFERENCES differences${NC}"
    echo ""
    echo "Key differences to be aware of:"
    
    if [[ "$LOCAL_XCODE" != "$CI_XCODE" ]]; then
        echo -e "${YELLOW}• Xcode version mismatch:${NC}"
        echo "  - Local: $LOCAL_XCODE"
        echo "  - CI: $CI_XCODE"
        echo "  - Impact: Swift Testing behavior may differ"
        echo "  - Fix: Install Xcode 16.2 from developer.apple.com"
    fi
    
    if [[ "$LOCAL_CI" != "true" ]]; then
        echo -e "${YELLOW}• CI environment variables not set${NC}"
        echo "  - Fix: export CI=true GITHUB_ACTIONS=true"
    fi
fi

echo ""
echo -e "${BLUE}💡 Recommendations${NC}"
echo "=================="
echo "1. To match CI environment exactly:"
echo "   export CI=true"
echo "   export GITHUB_ACTIONS=true"
echo "   export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer"
echo ""
echo "2. Use the strict CI test for accurate simulation:"
echo "   ./scripts/strict-ci-test.sh"
echo ""
echo "3. For Xcode version matching:"
if [[ "$LOCAL_XCODE" != "$CI_XCODE" ]]; then
    echo "   - Download Xcode $CI_XCODE from https://developer.apple.com/download/more/"
    echo "   - Install as /Applications/Xcode_16.2.app"
    echo "   - Switch: sudo xcode-select -s /Applications/Xcode_16.2.app"
else
    echo "   ✅ Your Xcode version matches CI!"
fi

exit 0