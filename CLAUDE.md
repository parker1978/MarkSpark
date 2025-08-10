# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MarkSpark is a macOS menu bar application that converts Markdown text in the clipboard to rich text (RTF/HTML) or plain text. The app provides sophisticated pasteboard management with multiple output formats and app-specific optimizations.

## Build Commands

```bash
# Build the project
xcodebuild -scheme MarkSpark -configuration Debug build

# Build for release
xcodebuild -scheme MarkSpark -configuration Release build

# Clean build
xcodebuild -scheme MarkSpark clean

# Build and run (for testing)
xcodebuild -scheme MarkSpark -configuration Debug build && open build/Debug/MarkSpark.app
```

## Architecture

### Core Components

- **MarkSparkApp.swift**: Main app entry point with MenuBarExtra configuration
- **MenuBarView.swift**: SwiftUI interface for the menu bar dropdown with user controls
- **ClipboardService**: Core service handling all clipboard operations and Markdown conversion

### Key Features

1. **Markdown Detection**: Uses heuristics to identify Markdown content in clipboard
2. **Multiple Output Formats**: 
   - AttributedString (NSAttributedString)
   - RTF-only mode
   - HTML-only mode  
   - RTF+HTML combined
   - RTF+HTML+Plain fallback
3. **App-Specific Optimization**: Special handling for Notes.app and Messages.app
4. **WebArchive Support**: Creates WebArchive format for better compatibility
5. **Privacy-Aware**: Handles macOS Sequoia clipboard privacy restrictions

### User Settings (UserDefaults)

- `debugEnabled`: Enable debug logging via OSLog
- `pasteMode`: Rich paste mode selection (0-4)
- `sanitizeSource`: Strip existing formatting before conversion
- `preferAppSpecific`: Enable app-specific paste optimizations

### Pasteboard Type Handling

The app handles multiple pasteboard types for maximum compatibility:
- `.rtf` / `.rtfd`: Rich Text Format
- `.html`: HTML format
- `.string`: Plain text fallback
- Legacy Apple types (NeXT RTF, Apple HTML)
- `com.apple.notes.richtext`: Notes.app specific
- `Apple Web Archive pasteboard type`: WebArchive format

## Development Notes

### Menu Bar App Pattern
The app uses `MenuBarExtra` with `.window` style for a persistent menu bar presence.

### Clipboard Privacy
Includes macOS 15+ privacy checks using `pb.accessBehavior` to handle clipboard access restrictions.

### Debug Logging
Uses OSLog subsystem "com.markspark.app" category "Pasteboard" for structured logging when debug mode is enabled.

### Target Applications
Special handling for:
- `com.apple.Notes`
- `com.apple.iChat` (Messages)
- `com.apple.MobileSMS`

## File Structure

```
MarkSpark/
├── MarkSparkApp.swift          # App entry point and ClipboardService
├── MenuBarView.swift           # SwiftUI menu interface
└── Assets.xcassets/           # App icons and resources
```