import AppKit
import Foundation

enum MarkdownFormatter {
    static func formatRichText(from markdown: String) -> NSAttributedString {
        return processMarkdownLineByLine(markdown)
    }

    // MARK: - Line-by-line formatter
    private static func processMarkdownLineByLine(_ text: String) -> NSAttributedString {
        let output = NSMutableAttributedString()
        let lines = text.components(separatedBy: .newlines)

        var inFencedCode = false
        var codeBuffer: [String] = []

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if inFencedCode {
                if trimmed.hasPrefix("```") {
                    // Close code block
                    let codeText = codeBuffer.joined(separator: "\n")
                    let codeAttr = makeCodeBlockAttributed(codeText)
                    output.append(codeAttr)
                    codeBuffer.removeAll(keepingCapacity: true)
                    inFencedCode = false
                    if index < lines.count - 1 { output.append(NSAttributedString(string: "\n")) }
                } else {
                    codeBuffer.append(line)
                }
                continue
            }

            // Not in code block
            if trimmed.hasPrefix("```") {
                // Start code block (language ignored for now)
                inFencedCode = true
                codeBuffer.removeAll(keepingCapacity: true)
                continue
            }

            let processedLine = processLine(line)
            output.append(processedLine)

            if index < lines.count - 1 {
                output.append(NSAttributedString(string: "\n"))
            }
        }

        // Flush unterminated code block
        if inFencedCode {
            let codeText = codeBuffer.joined(separator: "\n")
            output.append(makeCodeBlockAttributed(codeText))
        }

        return output
    }

    private static func processLine(_ line: String) -> NSAttributedString {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Empty line
        if trimmed.isEmpty { return NSAttributedString(string: line) }

        // Headers
        if trimmed.hasPrefix("#") { return processHeader(line) }

        // Block quotes
        if trimmed.hasPrefix(">") { return processBlockQuote(line) }

        // Lists
        if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") || trimmed.hasPrefix("+ ") ||
            trimmed.range(of: #"^\d+\.\s"#, options: .regularExpression) != nil {
            return processList(line)
        }

        // Regular line with inline formatting
        return processInlineFormatting(line)
    }

    private static func processHeader(_ line: String) -> NSAttributedString {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        // Count # characters
        var headerLevel = 0
        for ch in trimmed { if ch == "#" { headerLevel += 1 } else { break } }

        let headerText = String(trimmed.dropFirst(headerLevel)).trimmingCharacters(in: .whitespaces)

        // Exact sizes for H1..H6 (pt)
        let sizes: [CGFloat] = [28, 22, 18, 16, 14, 12]
        let idx = max(1, min(headerLevel, 6)) - 1
        let font = NSFont.boldSystemFont(ofSize: sizes[idx])
        let paragraph = NSMutableParagraphStyle()
        paragraph.paragraphSpacingBefore = 2
        paragraph.paragraphSpacing = 8

        let processed = processInlineFormatting(headerText)
        let result = NSMutableAttributedString(attributedString: processed)
        result.addAttributes([
            .font: font,
            .paragraphStyle: paragraph
        ], range: NSRange(location: 0, length: result.length))
        return result
    }

    private static func processBlockQuote(_ line: String) -> NSAttributedString {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let quoteText = String(trimmed.dropFirst(1)).trimmingCharacters(in: .whitespaces)

        let baseFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.italic)
        let font = NSFont(descriptor: descriptor, size: baseFont.pointSize) ?? baseFont

        let processed = processInlineFormatting(quoteText)
        let result = NSMutableAttributedString(attributedString: processed)
        result.addAttribute(.font, value: font, range: NSRange(location: 0, length: result.length))
        return result
    }

    private static func processList(_ line: String) -> NSAttributedString {
        return processInlineFormatting(line)
    }

    // MARK: - Code blocks
    private static func makeCodeBlockAttributed(_ text: String) -> NSAttributedString {
        let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.paragraphSpacing = 6
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .paragraphStyle: paragraph
        ])
    }

    // MARK: - Inline formatting
    private static func processInlineFormatting(_ text: String) -> NSAttributedString {
        let result = NSMutableAttributedString(string: text)
        let baseFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        result.addAttribute(.font, value: baseFont, range: NSRange(location: 0, length: result.length))

        processBoldFormatting(in: result)
        processItalicFormatting(in: result)
        processInlineCodeFormatting(in: result)
        processLinkFormatting(in: result)
        return result
    }

    private static func processBoldFormatting(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let regex = try! NSRegularExpression(pattern: #"\*\*([^*]+)\*\*"#, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        for m in matches.reversed() {
            let full = m.range
            let inner = m.range(at: 1)
            let content = (text as NSString).substring(with: inner)
            attributedString.replaceCharacters(in: full, with: content)
            let startFont = attributedString.attribute(.font, at: full.location, effectiveRange: nil) as? NSFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let bold = NSFont(descriptor: startFont.fontDescriptor.withSymbolicTraits(.bold), size: startFont.pointSize) ?? startFont
            attributedString.addAttribute(.font, value: bold, range: NSRange(location: full.location, length: content.count))
        }
    }

    private static func processItalicFormatting(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let regex = try! NSRegularExpression(pattern: #"\*([^*]+)\*"#, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        for m in matches.reversed() {
            let full = m.range
            let inner = m.range(at: 1)
            let content = (text as NSString).substring(with: inner)
            attributedString.replaceCharacters(in: full, with: content)
            let startFont = attributedString.attribute(.font, at: full.location, effectiveRange: nil) as? NSFont ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let italic = NSFont(descriptor: startFont.fontDescriptor.withSymbolicTraits(.italic), size: startFont.pointSize) ?? startFont
            attributedString.addAttribute(.font, value: italic, range: NSRange(location: full.location, length: content.count))
        }
    }

    private static func processInlineCodeFormatting(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let regex = try! NSRegularExpression(pattern: #"`([^`]+)`"#, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        for m in matches.reversed() {
            let full = m.range
            let inner = m.range(at: 1)
            let content = (text as NSString).substring(with: inner)
            attributedString.replaceCharacters(in: full, with: content)
            let codeFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize * 0.9, weight: .regular)
            attributedString.addAttribute(.font, value: codeFont, range: NSRange(location: full.location, length: content.count))
        }
    }

    private static func processLinkFormatting(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let regex = try! NSRegularExpression(pattern: #"\[([^\]]+)\]\(([^)]+)\)"#, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        for m in matches.reversed() {
            let full = m.range
            let textRange = m.range(at: 1)
            let label = (text as NSString).substring(with: textRange)
            attributedString.replaceCharacters(in: full, with: label)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: full.location, length: label.count))
        }
    }
}
