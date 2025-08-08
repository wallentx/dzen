# copilot-instructions.md

## Purpose

This file provides clear guidance to GitHub Copilot (and Copilot Chat) contributors on how to maintain the dzen2 fork that features both X11/Linux and native macOS support. This fork exists as an independent project since the upstream robm/dzen repository is not actively maintained.

---

## Project Status

**✅ COMPLETED:** The macOS port is fully functional with native CoreGraphics and Cocoa implementation.

**Current State:**
- Cross-platform support: X11/Linux (original) + macOS (native)
- Conditional compilation using `#ifdef __APPLE__` throughout codebase
- Platform-specific implementations cleanly separated (main X11 code + `src/macos.m`)
- Comprehensive build system supporting both platforms
- Full test coverage and documentation

---

## General Philosophy

- **Cross-Platform Compatibility:** Maintain both X11/Linux and macOS implementations without breaking either.
- **Platform Native:** Use platform-appropriate APIs (X11 for Linux, CoreGraphics/Cocoa for macOS).
- **Clean Separation:** Keep platform-specific code clearly separated and well-documented.
- **Simplicity First:** Implement core functionality needed for a status bar/notification tool.
- **Minimal Dependencies:** Avoid unnecessary libraries; use system frameworks where appropriate.
- **Easy to Read:** Prioritize clear, maintainable code that new contributors can understand.

---

## Platform-Specific Code Organization

**X11/Linux Implementation:**
- Main codebase in `src/` (main.c, draw.c, font.c, etc.)
- Uses X11, Xft, XPM libraries as configured
- Traditional dzen2 functionality and features

**macOS Implementation:**  
- Located in `src/macos.m` (Objective-C)
- Uses CoreGraphics, Cocoa, CoreText frameworks
- DzenWindow (NSWindow subclass) and DzenView (NSView subclass)
- Native event loop with stdin integration

---

## Maintenance Guidelines

**When Making Changes:**
- Always test on both platforms when possible
- Use conditional compilation (`#ifdef __APPLE__`) appropriately
- Keep platform-specific code in designated areas
- Maintain feature parity where feasible
- Update documentation for cross-platform changes

**Build System:**
- `./configure` auto-detects platform and sets appropriate flags
- macOS: Links Cocoa, CoreGraphics, CoreText frameworks
- Linux: Uses existing X11 library detection
- `test_build.sh` script for automated testing

---

## Coding Style

- Use descriptive names for all variables and functions.
- Comment all non-trivial logic, especially platform-specific code.
- Keep functions small and focused.
- Use consistent formatting (run `clang-format` if available).
- For macOS: Use Objective-C for Cocoa integration, C for shared logic.
- For X11: Maintain existing C style and patterns.

---

## Common Tasks for Copilot

**Feature Development:**
- Implement new features in both platform codepaths when applicable
- Add appropriate conditional compilation for platform-specific features
- Update build system if new dependencies are needed
- Add tests for new functionality

**Bug Fixes:**
- Identify if issue affects one or both platforms
- Test fixes on appropriate platform(s)
- Consider if fix needs platform-specific handling

**Maintenance:**
- Keep documentation updated (README.md, README_MACOS.md)
- Update build and test scripts as needed
- Ensure clean compilation on both platforms

---

## Platform-Specific Implementation Details

**macOS (src/macos.m):**
- DzenWindow: Borderless NSWindow at status bar level
- DzenView: Custom NSView handling text rendering with CoreText
- Native color system supporting hex colors and named colors
- Font rendering with automatic system font fallbacks
- Stdin integration using file descriptor monitoring
- Native Cocoa event loop

**X11/Linux:**
- Traditional X11 window creation and management
- Xft for font rendering (when enabled)
- XPM for image support (when enabled)
- X11 event handling and property management
- Support for advanced features like Xinerama (when configured)

---

## Testing and Validation

**Build Testing:**
- Use `./test_build.sh` for automated cross-platform build verification
- Test configure script on both platforms
- Verify conditional compilation works correctly

**Functional Testing:**
- Basic text display: `echo "Hello World" | ./src/dzen2 -p`
- Positioning: `echo "Test" | ./src/dzen2 -x 100 -y 50 -w 200 -h 30 -p`
- Colors: `echo "^fg(red)Red Text^fg()" | ./src/dzen2 -p`
- Dynamic updates: Test stdin streaming functionality

**Integration Testing:**
- Run existing test suites in `integration-tests/`
- Test gadgets and advanced features on appropriate platforms
- Verify performance with `test_performance/`

---

## Important Files and Locations

- **Main Implementation:** `src/main.c`, `src/draw.c`, `src/font.c`
- **macOS Implementation:** `src/macos.m`
- **Build System:** `configure.ac`, `Makefile.am`, `config.mk`
- **Documentation:** `README.md`, `README_MACOS.md`, `TESTS.md`
- **Testing:** `test_build.sh`, `integration-tests/`, `test_e2e/`

---

## Additional Notes

- This fork maintains backward compatibility with existing dzen2 scripts and usage patterns.
- macOS implementation focuses on core text-based status bar functionality.
- Advanced X11 features (XPM, complex graphics) are intentionally not ported to macOS.
- When in doubt about feature requests, prioritize cross-platform compatibility and maintainability.
- Keep build artifacts out of the repository using `.gitignore`.

---
