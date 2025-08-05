# dzen2 macOS Port

This is a minimal port of dzen2 to native macOS using CoreGraphics and Cocoa frameworks.

## Features

### Implemented (MVP)
- ✅ Simple borderless window creation (status bar style)
- ✅ Basic text rendering with CoreText
- ✅ Solid background colors
- ✅ Mouse click event detection
- ✅ Dynamic content updates via stdin
- ✅ Window positioning and sizing
- ✅ Font handling (simplified)

### Not Implemented (by design)
- ❌ Xinerama multi-monitor support
- ❌ XFT advanced font rendering
- ❌ XCursor custom cursors  
- ❌ XPM image support
- ❌ X resources configuration
- ❌ Complex graphics (circles, rectangles)
- ❌ Slave windows
- ❌ Complex markup parsing

## Building on macOS

### Prerequisites
- macOS 10.12 or later
- Xcode Command Line Tools
- autotools (install via Homebrew: `brew install autotools`)

### Build Steps

```bash
# Clone and enter the repository
git clone https://github.com/wallentx/dzen
cd dzen

# Generate build files
autoreconf -vfi

# Configure for macOS (automatically detected)
./configure

# Build
make

# The binary will be created at: src/dzen2
```

### macOS-specific Notes

1. **Platform Detection**: The build system automatically detects macOS and disables X11-specific features.

2. **Framework Dependencies**: Links against:
   - Cocoa.framework (window management)
   - CoreGraphics.framework (drawing)
   - CoreText.framework (text rendering)

3. **No X11 Required**: Unlike the Linux version, no X11 libraries are needed.

## Usage Examples

### Basic Usage
```bash
# Simple text display
echo "Hello macOS" | ./src/dzen2 -p

# With positioning
echo "Status Bar" | ./src/dzen2 -x 100 -y 50 -w 200 -h 30 -p

# Font specification (simplified)
echo "Monaco Font" | ./src/dzen2 -fn "Monaco-14" -p
```

### Continuous Updates
```bash
# Update from a script
while true; do
    echo "$(date)"
    sleep 1
done | ./src/dzen2 -p
```

## Font Handling

The macOS port uses a simplified font specification system:

- `Monaco` or `monaco` → Monaco font
- `Helvetica` or `helvetica` → Helvetica font
- Default → Monaco (monospace)
- Size extraction from `-NUMBER` suffix (e.g., `Monaco-14`)

## Limitations

This is a **minimal viable port** focusing on core functionality:

1. **Text Only**: Only basic text rendering, no graphics
2. **Single Window**: No slave windows or complex layouts
3. **Simplified Markup**: Limited markup parsing compared to X11 version
4. **Basic Fonts**: Simplified font handling vs. full X11 font system
5. **No Themes**: No X resources or complex theming

## Development

### Code Structure
- `src/dzen.h` - Platform-agnostic headers with macOS conditionals
- `src/macos.m` - macOS-specific implementation (Objective-C)
- `src/main.c` - Cross-platform main with macOS paths
- `src/draw.c` - Drawing functions with macOS support
- `src/caches.c` - Resource caching with macOS support

### Conditional Compilation
All macOS-specific code is wrapped in `#ifdef __APPLE__` blocks, allowing the same codebase to support both X11 and macOS platforms.

## Testing

To test the basic functionality:

```bash
# Build
make

# Test basic display
echo "Test Message" | timeout 5s ./src/dzen2 -p

# Test positioning
echo "Positioned" | timeout 5s ./src/dzen2 -x 200 -y 100 -w 300 -h 25 -p

# Test font
echo "Monaco Font" | timeout 5s ./src/dzen2 -fn "Monaco-16" -p
```

## Contributing

When contributing to the macOS port:

1. Maintain cross-platform compatibility
2. Use conditional compilation (`#ifdef __APPLE__`)
3. Follow existing code style
4. Test on both macOS and Linux when possible
5. Keep the implementation minimal and focused

## License

Same as original dzen2 - see LICENSE file.