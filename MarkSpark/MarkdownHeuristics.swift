import Foundation

enum MarkdownHeuristics {
    static func looksLikeMarkdown(_ s: String) -> Bool {
        if s.contains("```") || s.contains("**") || s.contains("_ ") || s.contains("# ") { return true }
        if (s.contains("[") && s.contains("](")) || s.contains("> ") { return true }
        if s.contains("- ") || s.contains("* ") || s.contains("+ ") { return true } // lists
        if s.contains("|") && s.contains("---") { return true } // tables
        let pats = [
            #"(?m)^\s{0,3}#{1,6}\s"#,   // headings
            #"(?m)^\s{0,3}\d+\.\s"#,    // ordered list
            #"`{1,3}[^`]+`{1,3}"#       // code ticks
        ]
        return pats.contains { s.range(of: $0, options: .regularExpression) != nil }
    }
}
