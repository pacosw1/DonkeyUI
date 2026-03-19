import Foundation

/// Simple email format validation without regex overhead.
///
/// Usage:
/// ```swift
/// let raw = "  User@Example.COM  "
/// let clean = EmailValidator.sanitize(raw)  // "user@example.com"
/// let valid = EmailValidator.isValid(clean)  // true
/// ```
public struct EmailValidator {

    private init() {}

    /// Checks whether the given string has a valid email structure.
    ///
    /// Validates:
    /// - Not empty
    /// - Exactly one `@` symbol
    /// - Non-empty local part (before `@`)
    /// - Domain contains at least one dot
    /// - No whitespace characters
    /// - Total length between 3 and 254 characters (RFC 5321)
    ///
    /// - Parameter email: The email string to validate.
    /// - Returns: `true` if the email has valid structure.
    public static func isValid(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Length bounds (RFC 5321: max 254, practical min is a@b.c = 5)
        guard trimmed.count >= 5, trimmed.count <= 254 else { return false }

        // No whitespace anywhere
        guard trimmed.rangeOfCharacter(from: .whitespaces) == nil else { return false }

        // Split on @
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return false }

        let local = parts[0]
        let domain = parts[1]

        // Local part must not be empty and max 64 chars (RFC 5321)
        guard !local.isEmpty, local.count <= 64 else { return false }

        // Domain must contain at least one dot
        guard domain.contains(".") else { return false }

        // Domain must not start or end with a dot or hyphen
        guard !domain.hasPrefix("."), !domain.hasSuffix("."),
              !domain.hasPrefix("-"), !domain.hasSuffix("-") else { return false }

        // TLD must be at least 2 characters
        let domainParts = domain.split(separator: ".")
        guard let tld = domainParts.last, tld.count >= 2 else { return false }

        // No consecutive dots in domain
        guard !domain.contains("..") else { return false }

        return true
    }

    /// Sanitizes an email by trimming whitespace and lowercasing.
    ///
    /// - Parameter email: The raw email input.
    /// - Returns: A cleaned email string suitable for storage or comparison.
    public static func sanitize(_ email: String) -> String {
        email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
