//
//  StringExtensions.swift
//  DonkeyUI
//
//  Created by Paco Sainz on 3/19/26.
//

import Foundation

@available(iOS 17.0, macOS 14.0, *)
public extension String {

    /// Truncate with suffix: "Hello World".truncated(8) -> "Hello..."
    func truncated(_ maxLength: Int, suffix: String = "...") -> String {
        guard count > maxLength else { return self }
        let endIndex = index(startIndex, offsetBy: max(0, maxLength - suffix.count))
        return String(self[startIndex..<endIndex]) + suffix
    }

    /// Get initials: "John Doe" -> "JD", "jane" -> "J"
    var initials: String {
        let components = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .prefix(2)
        return components
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()
    }

    /// Case-insensitive contains
    func containsIgnoringCase(_ other: String) -> Bool {
        localizedCaseInsensitiveContains(other)
    }

    /// Check if string is blank (empty or whitespace only)
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Remove extra whitespace: "hello   world" -> "hello world"
    var condensedWhitespace: String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    /// URL-safe encoding
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
