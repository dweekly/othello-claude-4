#!/bin/bash

# Generate Xcode project using XcodeGen
# This script should be run whenever project.yml is updated

set -e

echo "🔧 Generating Xcode project..."

# Check if XcodeGen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "❌ XcodeGen is not installed. Install it with: brew install xcodegen"
    exit 1
fi

# Generate the project
xcodegen generate

echo "✅ Project generated successfully!"
echo "📂 Generated: Othello.xcodeproj"
echo ""
echo "Next steps:"
echo "1. Open Othello.xcodeproj in Xcode"
echo "2. Build and run to verify everything works"
echo "3. The project is now managed by XcodeGen - edit project.yml instead of .xcodeproj"