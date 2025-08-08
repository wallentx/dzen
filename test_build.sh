#!/bin/bash
# Test script for dzen2 macOS port
# This script tests basic functionality on both Linux (X11) and macOS

set -e

echo "=== dzen2 Cross-Platform Build Test ==="

# Detect platform
PLATFORM=$(uname -s)
echo "Platform: $PLATFORM"

# Clean previous build
echo "Cleaning previous build..."
make distclean 2>/dev/null || true
rm -f src/dzen2 gadgets/* dzen2-help

# Regenerate build files
echo "Generating build files..."
autoreconf -vfi

# Configure based on platform
echo "Configuring for $PLATFORM..."
if [[ "$PLATFORM" == "Darwin" ]]; then
    echo "Configuring for macOS build..."
    ./configure
else
    echo "Configuring for X11 build..."
    ./configure --enable-xft --enable-xpm --enable-xinerama --enable-xcursor 2>/dev/null || {
        echo "X11 libraries not available - trying basic configure..."
        ./configure
    }
fi

# Build
echo "Building..."
make

# Check if binary was created
if [[ -f "src/dzen2" ]]; then
    echo "✓ Binary created successfully: src/dzen2"
else
    echo "✗ Binary not found!"
    exit 1
fi

# Test basic execution (without display)
echo "Testing basic execution..."
if [[ "$PLATFORM" == "Darwin" ]]; then
    echo "macOS: Testing would require GUI - skipping runtime test"
    echo "✓ macOS build completed - manual testing required"
else
    echo "Linux: Testing basic execution (expect display error without X11)..."
    echo "Test Message" | timeout 1s ./src/dzen2 -p 2>&1 || echo "Expected failure without display"
    echo "✓ X11 build completed"
fi

# Test gadgets if they were built
if [[ -f "gadgets/textwidth" ]]; then
    echo "✓ Gadgets built successfully"
else
    echo "⚠ Gadgets not built (may be expected on macOS)"
fi

echo ""
echo "=== Build Test Complete ==="
echo "Platform: $PLATFORM"
echo "Binary: src/dzen2"
if [[ "$PLATFORM" == "Darwin" ]]; then
    echo "Next steps: Test manually on macOS with GUI"
    echo "Example: echo 'Hello macOS' | ./src/dzen2 -p"
else
    echo "Next steps: Test with X11 display"
    echo "Example: echo 'Hello X11' | ./src/dzen2 -p"
fi