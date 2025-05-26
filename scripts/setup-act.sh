#!/bin/bash

# Setup script for running GitHub Actions locally with 'act'
# This tool runs your actual .github/workflows/ci.yml locally

echo "🎭 Setting up 'act' for local GitHub Actions testing..."
echo "======================================================"

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "📦 Installing 'act' (GitHub Actions local runner)..."
    
    # Install via Homebrew
    if command -v brew &> /dev/null; then
        brew install act
    else
        echo "❌ Homebrew not found. Please install 'act' manually:"
        echo "   https://github.com/nektos/act#installation"
        exit 1
    fi
else
    echo "✅ 'act' is already installed"
fi

# Create act configuration
echo ""
echo "⚙️  Creating act configuration..."
cat > .actrc << 'EOF'
# Use larger runner image for macOS compatibility
-P macos-latest=catthehacker/ubuntu:act-latest
# Bind local Docker socket
--bind

# Set environment variables
--env DEVELOPER_DIR=/usr/lib/xcode
EOF

# Create a minimal workflow for testing
echo ""
echo "📝 Creating test workflow..."
mkdir -p .github/workflows-test
cat > .github/workflows-test/test-local.yml << 'EOF'
name: Local Test

on: [push]

jobs:
  quick-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: List files
      run: ls -la
    - name: Check project.yml
      run: cat project.yml
EOF

echo ""
echo "✅ 'act' setup complete!"
echo ""
echo "🚀 Usage:"
echo "  # Test the full CI pipeline:"
echo "  act -W .github/workflows/ci.yml"
echo ""
echo "  # Test just the test job:"
echo "  act -W .github/workflows/ci.yml -j test"
echo ""
echo "  # Test with the simple workflow:"
echo "  act -W .github/workflows-test/test-local.yml"
echo ""
echo "⚠️  Note: macOS-specific commands may not work in Linux containers"
echo "    Use the manual simulation script for full macOS compatibility"