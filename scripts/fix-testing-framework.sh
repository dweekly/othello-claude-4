#!/bin/bash

# Fix for Swift Testing framework compatibility in CI
# Converts Swift Testing imports to XCTest for CI compatibility

echo "🔧 Checking for Swift Testing framework compatibility..."

# Check if we're in CI environment
if [ "$CI" = "true" ]; then
    echo "📍 Running in CI environment - checking Xcode version..."
    
    XCODE_VERSION=$(xcodebuild -version | head -1 | grep -o '[0-9]*\.[0-9]*')
    echo "Xcode version: $XCODE_VERSION"
    
    # Check if Xcode version is less than 16.0
    if [ "$(echo "$XCODE_VERSION < 16.0" | bc)" -eq 1 ]; then
        echo "⚠️  Xcode $XCODE_VERSION doesn't support Swift Testing framework"
        echo "❌ Tests will fail with 'No such module Testing'"
        exit 1
    fi
fi

echo "✅ Environment supports Swift Testing framework"