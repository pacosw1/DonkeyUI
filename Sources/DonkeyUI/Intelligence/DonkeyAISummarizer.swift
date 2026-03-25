#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26, macOS 26, *)
public enum DonkeySummaryStyle: String, Sendable {
    case concise = "Summarize concisely in 1-2 sentences"
    case detailed = "Provide a detailed summary covering all key points"
    case bullets = "Summarize as a bulleted list of key points"
    case oneLine = "Summarize in exactly one sentence"
}

@available(iOS 26, macOS 26, *)
public enum DonkeyAISummarizer {

    /// Summarize text using the on-device model.
    public static func summarize(
        _ text: String,
        style: DonkeySummaryStyle = .concise,
        maxSentences: Int = 3
    ) async throws -> String {
        let instructions = "\(style.rawValue). Use no more than \(maxSentences) sentences. Return only the summary, no preamble."
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: text)
        return response.content
    }
}
#endif
