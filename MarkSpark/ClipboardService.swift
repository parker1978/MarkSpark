import AppKit
import Foundation

enum ClipboardService {
    enum ClipboardResult {
        case success(String)
        case failure(String)
    }

    @MainActor
    static func convertMarkdownToRichText() -> ClipboardResult {
        guard let original = preflightAndReadPlainText() else {
            return .failure("Clipboard has no text")
        }
        guard MarkdownHeuristics.looksLikeMarkdown(original) else {
            return .failure("No Markdown detected on clipboard")
        }

        let preprocessed = original.replacingOccurrences(
            of: #"!\[([^\]]*)\]\(([^)]*)\)"#,
            with: "[$1]($2)",
            options: .regularExpression
        )

        let nsAttr = MarkdownFormatter.formatRichText(from: preprocessed)
        writeAttributedStringToPasteboard(nsAttr)
        return .success("Rich text copied to clipboard")
    }

    @MainActor
    static func convertMarkdownToPlainText() -> ClipboardResult {
        guard let original = preflightAndReadPlainText() else {
            return .failure("Clipboard has no text")
        }
        guard MarkdownHeuristics.looksLikeMarkdown(original) else {
            return .failure("No Markdown detected on clipboard")
        }

        let preprocessed = original.replacingOccurrences(
            of: #"!\[([^\]]*)\]\(([^)]*)\)"#,
            with: "[$1]($2)",
            options: .regularExpression
        )
        let plain = MarkdownFormatter.formatRichText(from: preprocessed).string
        writePlainTextToPasteboard(plain)
        return .success("Plain text copied to clipboard")
    }

    // MARK: - Pasteboard helpers
    @MainActor
    private static func preflightAndReadPlainText() -> String? {
        let pb = NSPasteboard.general
        if #available(macOS 15, *) {
            if pb.accessBehavior == .alwaysDeny { return nil }
        }
        guard let types = pb.types, types.contains(.string) else { return nil }
        guard let s = pb.string(forType: .string), !s.isEmpty else { return nil }
        return s
    }

    @MainActor
    private static func writePlainTextToPasteboard(_ s: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(s, forType: .string)
    }

    @MainActor
    private static func writeAttributedStringToPasteboard(_ nsAttr: NSAttributedString) {
        let pb = NSPasteboard.general
        pb.clearContents()
        let fullRange = NSRange(location: 0, length: nsAttr.length)
        if let rtfData = try? nsAttr.data(from: fullRange, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
            pb.setData(rtfData, forType: .rtf)
        }
        pb.setString(nsAttr.string, forType: .string)
    }

    @MainActor
    private static func restore(_ original: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(original, forType: .string)
    }
}
