#!/bin/bash

# Xcode Version Switcher for CI/CD Testing
# Makes it easy to switch between Xcode versions for testing

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Xcode Version Switcher${NC}"
echo "========================"

# Show current version
CURRENT=$(xcode-select -p | sed 's|/Contents/Developer||' | sed 's|/Applications/||')
echo -e "Current: ${GREEN}$CURRENT${NC}"
echo ""

# Show installed versions
echo "Installed Xcode versions:"
xcodes installed

echo ""
echo "Options:"
echo "  1) Use Xcode 16.2 (matches GitHub Actions)"
echo "  2) Use Xcode 16.3 (latest)"
echo "  3) Install Xcode 16.2 if missing"
echo "  4) Show current version details"
echo "  q) Quit"
echo ""
echo -n "Choice: "
read -r choice

case $choice in
    1)
        echo -e "${YELLOW}Switching to Xcode 16.2...${NC}"
        if [ -d "/Applications/Xcode-16.2.app" ]; then
            sudo xcode-select -s /Applications/Xcode-16.2.app
            echo -e "${GREEN}✅ Switched to Xcode 16.2${NC}"
        else
            echo "Xcode 16.2 not found. Install with: xcodes install 16.2"
        fi
        ;;
    2)
        echo -e "${YELLOW}Switching to Xcode 16.3...${NC}"
        sudo xcode-select -s /Applications/Xcode.app
        echo -e "${GREEN}✅ Switched to Xcode 16.3${NC}"
        ;;
    3)
        echo -e "${YELLOW}Installing Xcode 16.2...${NC}"
        xcodes install 16.2
        ;;
    4)
        xcodebuild -version
        swift --version
        ;;
    q)
        echo "Exiting..."
        ;;
    *)
        echo "Invalid choice"
        ;;
esac

echo ""
echo "Current Xcode: $(xcodebuild -version | head -1)"