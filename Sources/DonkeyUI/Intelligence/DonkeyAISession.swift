#if canImport(FoundationModels)
import FoundationModels
import Foundation
import Observation
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "AI")

@available(iOS 26, macOS 26, *)
public enum DonkeyAIError: Error, LocalizedError {
    case modelUnavailable(String)
    case generationFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .modelUnavailable(let reason): return "AI unavailable: \(reason)"
        case .generationFailed(let error): return "Generation failed: \(error.localizedDescription)"
        }
    }
}

@available(iOS 26, macOS 26, *)
@Observable
@MainActor
public final class DonkeyAISession {
    public private(set) var isGenerating = false
    public private(set) var error: DonkeyAIError?

    private var session: LanguageModelSession
    private let instructions: String

    /// Checks if the on-device model is available.
    public static var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    public init(instructions: String = "") {
        self.instructions = instructions
        self.session = LanguageModelSession(instructions: instructions)
    }

    /// Send a prompt and get a text response.
    public func respond(to prompt: String) async throws -> String {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            logger.debug("Generating response for prompt")
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            logger.error("Generation failed: \(error.localizedDescription)")
            let aiError = DonkeyAIError.generationFailed(error)
            self.error = aiError
            throw aiError
        }
    }

    /// Send a prompt and get structured output conforming to Generable.
    public func respond<T: Generable>(to prompt: String, generating type: T.Type) async throws -> T {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            let response = try await session.respond(to: prompt, generating: type)
            return response.content
        } catch {
            logger.error("Structured generation failed: \(error.localizedDescription)")
            let aiError = DonkeyAIError.generationFailed(error)
            self.error = aiError
            throw aiError
        }
    }

    /// Stream a text response token by token.
    public func streamResponse(to prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let capturedSession = self.session
            Task {
                await MainActor.run { self.isGenerating = true; self.error = nil }
                do {
                    let stream = capturedSession.streamResponse(to: prompt)
                    for try await partial in stream {
                        continuation.yield(partial.content)
                    }
                    continuation.finish()
                } catch {
                    let aiError = DonkeyAIError.generationFailed(error)
                    await MainActor.run { self.error = aiError }
                    continuation.finish(throwing: aiError)
                }
                await MainActor.run { self.isGenerating = false }
            }
        }
    }

    /// Reset the session, clearing conversation history.
    public func reset() {
        session = LanguageModelSession(instructions: instructions)
        error = nil
    }
}
#endif
