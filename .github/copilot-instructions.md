# copilot-instructions.md

## Purpose

This file provides clear guidance to GitHub Copilot (and Copilot Chat) contributors on how to assist with the minimal, macOS-native port of dzen2. The goal is to keep the codebase simple, focused, and maintainable, without legacy X11/Linux-specific features.

---

## General Philosophy

- **Simplicity First:** Implement only the core functionality needed for a basic status bar/notification tool.
- **macOS Native:** Use only macOS-native APIs (CoreGraphics, Cocoa, CoreText) for display, drawing, and event handling.
- **No X11 Baggage:** Do not attempt to preserve or emulate advanced X11 features (Xinerama, Xft, Xcursor, XPM, X resources, EWMH hints, etc.).
- **Minimal Dependencies:** Avoid bringing in unnecessary libraries or frameworks.
- **Easy to Read:** Prioritize clear, idiomatic C or Objective-C code that is easy for new contributors to understand.

---

## What To Implement

- Create a basic, borderless window at a specified position and size.
- Fill the window with a solid background color.
- Render a single line of text in a single font and color.
- Allow text/content to be updated dynamically (e.g., from stdin).
- Handle basic mouse clicks and basic window events (close, redraw).
- Parse minimal configuration from command-line arguments or environment variables.

---

## What To Avoid

- Do NOT include code for:
  - Xinerama or any multi-monitor logic.
  - Xft, Xcursor, XPM, or any advanced X11 drawing/image/font features.
  - X11 event handling, properties, or resource management.
  - EWMH window manager hints or Linux-specific windowing conventions.
  - X resources or complex style inheritance.
  - Icon/image support.
  - Advanced font handling (stick to system/default fonts).

---

## Coding Style

- Use descriptive names for all variables and functions.
- Comment all non-trivial logic.
- Keep functions small and focused.
- Remove or clearly mark any legacy X11 or Linux-specific code for deletion.
- Prefer C for portability, but Objective-C is acceptable where needed for Cocoa.

---

## Example Tasks for Copilot

- Replace X11 window creation with CoreGraphics/Cocoa window creation.
- Substitute Xlib drawing with CoreGraphics/CoreText drawing.
- Remove or stub out all Xinerama/Xft/Xcursor/XPM/X resource/X11 event code.
- Replace X11 event loop with a native macOS event loop.
- Write helpers to parse basic command-line options for geometry/color/text.
- Implement minimal code for reading updates from stdin and refreshing the window.

---

## Additional Notes

- If in doubt, ask if a feature is truly necessary for a minimal, cross-platform status bar.
- Prioritize code that will work "out of the box" on a standard macOS install.
- Keep all documentation and comments up to date as code is refactored.

---
