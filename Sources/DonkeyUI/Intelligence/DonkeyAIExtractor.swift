#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26, macOS 26, *)
public enum DonkeyAIExtractor {

    /// Extract structured data from text into a Generable type.
    public static func extract<T: Generable>(
        from text: String,
        as type: T.Type,
        instructions: String? = nil
    ) async throws -> T {
        let systemInstructions = instructions ?? "Extract structured information from the following text. Return only the requested fields."
        let session = LanguageModelSession(instructions: systemInstructions)
        let response = try await session.respond(to: text, generating: type)
        return response.content
    }
}
#endif
