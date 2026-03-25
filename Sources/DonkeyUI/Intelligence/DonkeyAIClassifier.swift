#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26, macOS 26, *)
@Generable
public struct DonkeyAIClassification: Sendable {
    @Guide(description: "The category that best matches the input")
    public var category: String

    @Guide(description: "Brief reasoning for the classification")
    public var reasoning: String
}

@available(iOS 26, macOS 26, *)
public enum DonkeyAIClassifier {

    /// Classify text into one of the provided categories.
    public static func classify(
        _ text: String,
        categories: [String],
        instructions: String? = nil
    ) async throws -> DonkeyAIClassification {
        let categoryList = categories.joined(separator: ", ")
        let systemInstructions = instructions ?? "Classify the following text into exactly one of these categories: \(categoryList). Return the category name exactly as provided."

        let session = LanguageModelSession(instructions: systemInstructions)
        let response = try await session.respond(to: text, generating: DonkeyAIClassification.self)
        return response.content
    }
}
#endif
