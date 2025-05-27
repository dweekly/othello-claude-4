#!/bin/bash

# Quick CI Pipeline Health Check
# Runs essential CI steps in ~30 seconds

# Color codes
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "⚡ Quick CI Pipeline Health Check"
echo "================================"

# Check Xcode version
CURRENT_XCODE=$(xcodebuild -version | head -1)
CI_XCODE="16.2"
if [[ "$CURRENT_XCODE" =~ "$CI_XCODE" ]]; then
    echo -e "${GREEN}✅ Using CI-matching Xcode $CI_XCODE${NC}"
else
    echo -e "${YELLOW}⚠️  Using $CURRENT_XCODE (CI uses $CI_XCODE)${NC}"
fi
echo ""

# 1. Project Generation Check (5 seconds)
echo "🔧 Testing XcodeGen..."
rm -rf Othello.xcodeproj > /dev/null 2>&1
if xcodegen generate > /dev/null 2>&1; then
    echo "✅ XcodeGen: Working"
else
    echo "❌ XcodeGen: Failed"
    exit 1
fi

# 2. Build Check (10 seconds)
echo "🔨 Testing Build..."
if xcodebuild build -scheme Othello -destination 'platform=macOS' SWIFT_STRICT_CONCURRENCY=complete > /dev/null 2>&1; then
    echo "✅ Build: Working (with strict concurrency)"
else
    echo "❌ Build: Failed (try without strict concurrency)"
    if xcodebuild build -scheme Othello -destination 'platform=macOS' > /dev/null 2>&1; then
        echo "⚠️  Build works locally but will fail in CI (concurrency issues)"
        exit 1
    else
        echo "❌ Build: Failed completely"
        exit 1
    fi
fi

# 3. SwiftLint Check (5 seconds)
echo "🎨 Testing SwiftLint..."
VIOLATIONS=$(swiftlint lint --quiet | wc -l)
if [ "$VIOLATIONS" -lt 10 ]; then
    echo "✅ SwiftLint: $VIOLATIONS violations (acceptable)"
else
    echo "⚠️  SwiftLint: $VIOLATIONS violations (review needed)"
fi

# 4. Quick Test Check (10 seconds)
echo "🧪 Testing Basic Tests..."
if xcodebuild test -scheme Othello -destination 'platform=macOS' -only-testing:OthelloTests/ModelTests > /dev/null 2>&1; then
    echo "✅ Tests: Model tests passing"
else
    echo "❌ Tests: Model tests failing"
    exit 1
fi

echo ""
echo "🎉 Quick CI Check Complete!"
echo "💡 Your pipeline should work on GitHub Actions"
echo ""
echo "🚀 Next steps:"
echo "   1. git add -A && git commit -m 'your message'"
echo "   2. git push origin main"
echo "   3. Monitor: https://github.com/dweekly/othello-claude-4/actions"