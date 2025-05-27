#!/bin/bash

# Xcode CI Version Setup Helper
# Helps set up Xcode 16.2 for CI testing without xcodes

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CI_XCODE_VERSION="16.2"
CI_XCODE_PATH="/Applications/Xcode-${CI_XCODE_VERSION}.app"

echo -e "${BLUE}🔧 Xcode CI Version Setup${NC}"
echo "========================="
echo ""

# Check current status
if [ -d "$CI_XCODE_PATH" ]; then
    echo -e "${GREEN}✅ Xcode $CI_XCODE_VERSION is already installed at:${NC}"
    echo "   $CI_XCODE_PATH"
    echo ""
    echo "You're all set for CI testing!"
    exit 0
fi

echo -e "${YELLOW}⚠️  Xcode $CI_XCODE_VERSION not found${NC}"
echo ""
echo "To match GitHub Actions CI environment, you need Xcode $CI_XCODE_VERSION"
echo ""
echo -e "${BLUE}📥 Manual Installation Steps:${NC}"
echo ""
echo "1. Go to: https://developer.apple.com/download/all/"
echo "   (You'll need to sign in with your Apple ID)"
echo ""
echo "2. Search for: Xcode 16.2"
echo ""
echo "3. Download: Xcode 16.2 (not beta)"
echo "   File: Xcode_16.2.xip (~7-8 GB)"
echo ""
echo "4. After download completes:"
echo "   a) Double-click the .xip file to extract"
echo "   b) This will create 'Xcode.app' in your Downloads"
echo "   c) Rename and move it:"
echo ""
echo -e "${GREEN}   sudo mv ~/Downloads/Xcode.app $CI_XCODE_PATH${NC}"
echo ""
echo "5. Launch it once to complete setup:"
echo -e "${GREEN}   open $CI_XCODE_PATH${NC}"
echo ""
echo "6. Agree to license:"
echo -e "${GREEN}   sudo xcodebuild -license accept${NC}"
echo ""
echo -e "${BLUE}💡 Alternative: Direct Download Link${NC}"
echo "If you know the direct URL, you can use:"
echo "   curl -O [URL_TO_XCODE_16.2.xip]"
echo ""
echo -e "${YELLOW}📝 Note about xcodes:${NC}"
echo "The 'xcodes' tool doesn't work with hardware security keys."
echo "Manual download from Apple Developer portal is the most reliable method."
echo ""
echo -e "${BLUE}🚀 After Installation:${NC}"
echo "The CI scripts will automatically detect and use Xcode $CI_XCODE_VERSION"
echo "No additional configuration needed!"

# Check if user has a different Xcode 16.2 installation
echo ""
echo -e "${BLUE}🔍 Checking for alternative installations...${NC}"
FOUND_XCODE=false

# Check common alternative locations
for path in "/Applications/Xcode_16.2.app" "/Applications/Xcode16.2.app" "/Applications/Xcode-16.2.0.app"; do
    if [ -d "$path" ]; then
        echo -e "${YELLOW}Found Xcode at: $path${NC}"
        echo "You can create a symlink to use it with CI scripts:"
        echo -e "${GREEN}   sudo ln -s '$path' '$CI_XCODE_PATH'${NC}"
        FOUND_XCODE=true
    fi
done

if [ "$FOUND_XCODE" = false ]; then
    # Check if any Xcode 16.2 exists with different naming
    if ls /Applications/ | grep -i "xcode.*16\.2" > /dev/null 2>&1; then
        echo -e "${YELLOW}Found possible Xcode 16.2 installations:${NC}"
        ls /Applications/ | grep -i "xcode.*16\.2"
        echo ""
        echo "Rename or symlink to: $CI_XCODE_PATH"
    fi
fi

echo ""
echo "Press Enter to open Apple Developer downloads page..."
read -r
open "https://developer.apple.com/download/all/?q=xcode%2016.2"