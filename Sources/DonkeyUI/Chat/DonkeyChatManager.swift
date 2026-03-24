//
//  DonkeyChatManager.swift
//  DonkeyUI
//
//  Observable chat manager with WebSocket real-time delivery,
//  auto-reconnect, typing indicators, and image support.
//
//  Usage:
//  let chat = DonkeyChatManager(config: .init(
//      websocketURL: { token in URL(string: "wss://api.example.com/chat/ws?token=\(token)")! },
//      getSessionToken: { UserDefaults.standard.string(forKey: "sessionToken") },
//      fetchMessages: { limit, offset in try await api.getChatHistory(limit: limit, offset: offset) },
//      sendMessage: { text, type in try await api.sendChatMessage(text, messageType: type) },
//      uploadImage: { data in try await api.uploadChatImage(data) }
//  ))
//

import SwiftUI
import Combine
import os.log

#if canImport(UIKit)
import UIKit
#endif

private let logger = Logger(subsystem: "DonkeyUI", category: "Chat")

// MARK: - Models

public struct DonkeyChatMessage: Identifiable, Equatable, Sendable {
    public let id: Int
    public let userId: String
    public let sender: String
    public let message: String
    public let messageType: String
    public let readAt: String?
    public let createdAt: String

    public var isUser: Bool { sender == "user" }
    public var isImage: Bool { messageType == "image" }

    public init(
        id: Int,
        userId: String,
        sender: String,
        message: String,
        messageType: String = "text",
        readAt: String? = nil,
        createdAt: String
    ) {
        self.id = id
        self.userId = userId
        self.sender = sender
        self.message = message
        self.messageType = messageType
        self.readAt = readAt
        self.createdAt = createdAt
    }
}

public struct DonkeyChatPage: Sendable {
    public let messages: [DonkeyChatMessage]
    public let hasMore: Bool

    public init(messages: [DonkeyChatMessage], hasMore: Bool) {
        self.messages = messages
        self.hasMore = hasMore
    }
}

public struct DonkeyChatSendResult: Sendable {
    public let id: Int?
    public let createdAt: String?

    public init(id: Int? = nil, createdAt: String? = nil) {
        self.id = id
        self.createdAt = createdAt
    }
}

// MARK: - Config

public struct DonkeyChatConfig: Sendable {
    /// Build the WebSocket URL given the session token.
    public let websocketURL: @Sendable (String) -> URL?
    /// Return the current session token, or nil if not authenticated.
    public let getSessionToken: @Sendable () -> String?
    /// Fetch paginated message history.
    public let fetchMessages: @Sendable (Int, Int) async throws -> DonkeyChatPage
    /// Send a text or image message. Returns optional server-assigned ID.
    public let sendMessage: @Sendable (String, String) async throws -> DonkeyChatSendResult
    /// Upload image data, return the URL string. Nil if image upload not supported.
    public let uploadImage: (@Sendable (Data) async throws -> String)?
    /// Called when a chat event occurs (for analytics). Optional.
    public let onEvent: (@Sendable (ChatEvent) -> Void)?
    /// Admin display name shown in typing indicator (default: "Developer").
    public let adminDisplayName: String
    /// Max image compression quality (default: 0.7).
    public let imageCompressionQuality: CGFloat
    /// Max reconnect delay in seconds (default: 30).
    public let maxReconnectDelay: TimeInterval

    public enum ChatEvent: Sendable {
        case opened
        case messageSent
        case imageSent
    }

    public init(
        websocketURL: @escaping @Sendable (String) -> URL?,
        getSessionToken: @escaping @Sendable () -> String?,
        fetchMessages: @escaping @Sendable (Int, Int) async throws -> DonkeyChatPage,
        sendMessage: @escaping @Sendable (String, String) async throws -> DonkeyChatSendResult,
        uploadImage: (@Sendable (Data) async throws -> String)? = nil,
        onEvent: (@Sendable (ChatEvent) -> Void)? = nil,
        adminDisplayName: String = "Developer",
        imageCompressionQuality: CGFloat = 0.7,
        maxReconnectDelay: TimeInterval = 30
    ) {
        self.websocketURL = websocketURL
        self.getSessionToken = getSessionToken
        self.fetchMessages = fetchMessages
        self.sendMessage = sendMessage
        self.uploadImage = uploadImage
        self.onEvent = onEvent
        self.adminDisplayName = adminDisplayName
        self.imageCompressionQuality = imageCompressionQuality
        self.maxReconnectDelay = maxReconnectDelay
    }
}

// MARK: - Manager

@Observable
@MainActor
public final class DonkeyChatManager {
    // MARK: - Public State

    public private(set) var messages: [DonkeyChatMessage] = []
    public private(set) var isLoading = false
    public private(set) var isSending = false
    public private(set) var isConnected = false
    public private(set) var isRemoteTyping = false
    public private(set) var hasMore = false
    public private(set) var isUploadingImage = false
    public private(set) var uploadError: String?
    public var supportsImages: Bool { config.uploadImage != nil }

    // MARK: - Private

    private let config: DonkeyChatConfig
    private let pageSize: Int
    private var offset = 0
    private var webSocketTask: URLSessionWebSocketTask?
    private var session = URLSession(configuration: .default)
    private var reconnectAttempts = 0
    private var reconnectTask: Task<Void, Never>?
    private var typingDebounceTask: Task<Void, Never>?
    private var typingClearTask: Task<Void, Never>?
    private var isIntentionalDisconnect = false

    // MARK: - Init

    public init(config: DonkeyChatConfig, pageSize: Int = 50) {
        self.config = config
        self.pageSize = pageSize
    }

    // MARK: - Lifecycle

    /// Load initial messages and connect WebSocket. Call from .task {} on the view.
    public func start() async {
        config.onEvent?(.opened)
        await loadMessages()
        connectWebSocket()
    }

    /// Disconnect WebSocket. Call from .onDisappear {}.
    public func stop() {
        disconnectWebSocket()
    }

    // MARK: - Messages

    public func loadMessages() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await config.fetchMessages(pageSize, 0)
            messages = page.messages.reversed()
            hasMore = page.hasMore
            offset = page.messages.count
        } catch {
            logger.error("Load messages failed: \(error.localizedDescription)")
        }
    }

    public func loadMore() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await config.fetchMessages(pageSize, offset)
            let older = page.messages.reversed()
            messages.insert(contentsOf: older, at: 0)
            hasMore = page.hasMore
            offset += page.messages.count
        } catch {
            logger.error("Load more failed: \(error.localizedDescription)")
        }
    }

    public func sendMessage(_ text: String) async -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return false }

        isSending = true
        defer { isSending = false }

        do {
            let result = try await config.sendMessage(trimmed, "text")
            config.onEvent?(.messageSent)

            // Optimistically add message if we got an ID back, otherwise reload
            if let id = result.id {
                let msg = DonkeyChatMessage(
                    id: id,
                    userId: "",
                    sender: "user",
                    message: trimmed,
                    messageType: "text",
                    createdAt: result.createdAt ?? ISO8601DateFormatter().string(from: Date())
                )
                if !messages.contains(where: { $0.id == id }) {
                    messages.append(msg)
                }
            } else {
                await loadMessages()
            }
            return true
        } catch {
            logger.error("Send failed: \(error.localizedDescription)")
            return false
        }
    }

    #if canImport(UIKit)
    public func sendImage(_ image: UIImage) async -> Bool {
        guard let uploadFn = config.uploadImage else { return false }
        guard let jpegData = image.jpegData(compressionQuality: config.imageCompressionQuality) else { return false }

        uploadError = nil
        isUploadingImage = true
        defer { isUploadingImage = false }

        do {
            let url = try await uploadFn(jpegData)
            _ = try await config.sendMessage(url, "image")
            config.onEvent?(.imageSent)
            await loadMessages()
            return true
        } catch {
            logger.error("Image upload failed: \(error.localizedDescription)")
            uploadError = "Failed to send"
            Task {
                try? await Task.sleep(for: .seconds(3))
                uploadError = nil
            }
            return false
        }
    }
    #endif

    // MARK: - Typing

    public func sendTyping(userId: String) {
        typingDebounceTask?.cancel()
        typingDebounceTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            let json = """
            {"type":"typing","payload":{"user_id":"\(userId)","sender":"user"}}
            """
            try? await webSocketTask?.send(.string(json))
        }
    }

    // MARK: - WebSocket

    private func connectWebSocket() {
        guard webSocketTask == nil || webSocketTask?.state != .running else { return }
        guard let token = config.getSessionToken(),
              let url = config.websocketURL(token) else {
            logger.info("No token or URL — skipping WebSocket connect")
            return
        }

        isIntentionalDisconnect = false
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        reconnectAttempts = 0
        logger.info("WebSocket connected")
        receiveLoop()
    }

    private func disconnectWebSocket() {
        isIntentionalDisconnect = true
        reconnectTask?.cancel()
        reconnectTask = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func receiveLoop() {
        webSocketTask?.receive { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        self.handleWSMessage(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            self.handleWSMessage(text)
                        }
                    @unknown default:
                        break
                    }
                    self.receiveLoop()

                case .failure(let error):
                    logger.error("WebSocket error: \(error.localizedDescription)")
                    self.isConnected = false
                    self.webSocketTask = nil
                    if !self.isIntentionalDisconnect {
                        self.scheduleReconnect()
                    }
                }
            }
        }
    }

    private func handleWSMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else { return }

        let payloadData: Data? = {
            guard let payload = json["payload"] else { return nil }
            return try? JSONSerialization.data(withJSONObject: payload)
        }()

        switch type {
        case "new_message":
            guard let payloadData,
                  let payload = try? JSONDecoder().decode(WSMessagePayload.self, from: payloadData) else { return }
            let msg = DonkeyChatMessage(
                id: payload.id,
                userId: payload.user_id,
                sender: payload.sender,
                message: payload.message,
                messageType: payload.message_type,
                createdAt: payload.created_at
            )
            if !messages.contains(where: { $0.id == msg.id }) {
                messages.append(msg)
            }
            isRemoteTyping = false

        case "typing":
            guard let payloadData,
                  let payload = try? JSONDecoder().decode(WSTypingPayload.self, from: payloadData),
                  payload.sender == "admin" else { return }
            isRemoteTyping = true
            typingClearTask?.cancel()
            typingClearTask = Task {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                isRemoteTyping = false
            }

        default:
            break
        }
    }

    private func scheduleReconnect() {
        reconnectTask?.cancel()
        reconnectTask = Task {
            let delay = min(pow(2.0, Double(reconnectAttempts)), config.maxReconnectDelay)
            reconnectAttempts += 1
            logger.info("Reconnecting in \(Int(delay))s (attempt \(self.reconnectAttempts))")
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled, !isIntentionalDisconnect else { return }
            connectWebSocket()
        }
    }
}

// MARK: - Internal WS Models

private struct WSMessagePayload: Decodable {
    let id: Int
    let user_id: String
    let sender: String
    let message: String
    let message_type: String
    let created_at: String
}

private struct WSTypingPayload: Decodable {
    let user_id: String
    let sender: String
}
