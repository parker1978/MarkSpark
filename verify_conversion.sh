#!/bin/bash

# MarkSpark Conversion Verification Script
echo "=== MarkSpark Conversion Test ==="
echo

# Check what types are available on clipboard
echo "Available clipboard types:"
osascript -e 'set the clipboard to (the clipboard as record)' 2>/dev/null | tr ',' '\n' | sort

echo
echo "=== Testing Instructions ==="
echo "1. Click MarkSpark menu bar icon"
echo "2. Click 'Convert Markdown to Rich Text'"
echo "3. Paste in TextEdit/Pages to verify formatting:"
echo "   - Headers should be larger/bold"
echo "   - **Bold** and *italic* should format correctly"
echo "   - Lists should have proper spacing" 
echo "   - Code should be monospace"
echo "   - Block quotes should be italicized"
echo "   - Images should appear as plain links"
echo

# Check if conversion created RTF data
if pbpaste -Prefer rtf >/dev/null 2>&1; then
    echo "✅ RTF data found on clipboard - conversion likely successful!"
else
    echo "❌ No RTF data found - conversion may have failed"
fi