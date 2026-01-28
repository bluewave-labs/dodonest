import Foundation

// MARK: - String Extensions

extension String {
    /// Truncate string with ellipsis
    func truncated(to length: Int) -> String {
        if self.count <= length {
            return self
        }
        return String(self.prefix(length - 3)) + "..."
    }

    /// Localized string from Localizable.strings
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Localized string with format arguments
    func localized(_ args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}

// MARK: - Date Extensions

extension Date {
    /// Format as relative time (e.g., "2 hours ago")
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
