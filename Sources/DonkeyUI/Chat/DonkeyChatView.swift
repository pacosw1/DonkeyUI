//
//  DonkeyChatView.swift
//  DonkeyUI
//
//  Drop-in support chat view with real-time WebSocket delivery,
//  image support, typing indicators, and theme integration.
//
//  Usage:
//  DonkeyChatView(manager: chatManager, userId: auth.user?.id ?? "")
//

import SwiftUI

#if canImport(UIKit)
import PhotosUI
#endif

public struct DonkeyChatView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.donkeyTheme) private var theme

    @Bindable var manager: DonkeyChatManager
    let userId: String
    var title: String
    var emptyTitle: String
    var emptySubtitle: String

    @State private var newMessage = ""
    @State private var scrollTarget: Int?

    #if canImport(UIKit)
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pendingImage: UIImage?
    @State private var uploadPreviewImage: UIImage?
    @State private var fullscreenImageURL: String?
    #endif

    public init(
        manager: DonkeyChatManager,
        userId: String,
        title: String = "Chat with Developer",
        emptyTitle: String = "No messages yet",
        emptySubtitle: String = "We typically reply within a few hours"
    ) {
        self.manager = manager
        self.userId = userId
        self.title = title
        self.emptyTitle = emptyTitle
        self.emptySubtitle = emptySubtitle
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if manager.isLoading && manager.messages.isEmpty {
                    Spacer()
                    ProgressView().tint(theme.colors.accent)
                    Spacer()
                } else if manager.messages.isEmpty {
                    emptyState
                } else {
                    messageList
                }

                if manager.isRemoteTyping {
                    typingIndicator
                }

                inputBar
            }
            .navigationTitle(title)
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if canImport(UIKit)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                }
                #endif
            }
        }
        .task {
            await manager.start()
        }
        .onDisappear {
            manager.stop()
        }
        #if canImport(UIKit)
        .onChange(of: selectedPhoto) {
            guard let item = selectedPhoto else { return }
            selectedPhoto = nil
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    pendingImage = img
                }
            }
        }
        .confirmationDialog("Send this photo?", isPresented: .init(
            get: { pendingImage != nil },
            set: { if !$0 { pendingImage = nil } }
        ), titleVisibility: .visible) {
            Button("Send Photo") {
                guard let img = pendingImage else { return }
                pendingImage = nil
                uploadPreviewImage = img
                Task {
                    _ = await manager.sendImage(img)
                    uploadPreviewImage = nil
                }
            }
            Button("Cancel", role: .cancel) {
                pendingImage = nil
            }
        }
        .fullScreenCover(item: $fullscreenImageURL) { url in
            fullscreenImage(url)
        }
        #endif
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(theme.colors.onSurface.opacity(0.4))
            Text(emptyTitle)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.onSurface.opacity(0.5))
            Text(emptySubtitle)
                .font(theme.typography.callout)
                .foregroundStyle(theme.colors.onSurface.opacity(0.3))
            Spacer()
        }
    }

    // MARK: - Typing Indicator

    private var typingIndicator: some View {
        HStack {
            Text("\(manager.supportsImages ? title.replacingOccurrences(of: "Chat with ", with: "") : "Developer") is typing...")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.onSurface.opacity(0.5))
                .italic()
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            Spacer()
        }
        .transition(.opacity)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 6) {
                    if manager.hasMore {
                        Button {
                            Task { await manager.loadMore() }
                        } label: {
                            if manager.isLoading {
                                ProgressView().tint(theme.colors.onSurface.opacity(0.4)).padding(.vertical, 8)
                            } else {
                                Text("Load earlier messages")
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.onSurface.opacity(0.4))
                                    .padding(.vertical, 8)
                            }
                        }
                    }

                    ForEach(manager.messages) { msg in
                        messageBubble(msg).id(msg.id)
                    }

                    #if canImport(UIKit)
                    if manager.isUploadingImage, let preview = uploadPreviewImage {
                        uploadingBubble(preview).id(-999)
                    }
                    #endif
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: manager.messages.count) {
                if let last = manager.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onAppear {
                if let last = manager.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Message Bubble

    private func messageBubble(_ msg: DonkeyChatMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 60) }
            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 3) {
                if msg.isImage {
                    imageBubble(msg.message)
                } else {
                    Text(msg.message)
                        .font(theme.typography.callout)
                        .foregroundStyle(msg.isUser ? theme.colors.onPrimary : theme.colors.onSurface)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            msg.isUser ? theme.colors.accent : theme.colors.surface,
                            in: RoundedRectangle(cornerRadius: theme.shape.radiusMedium, style: .continuous)
                        )
                }
                Text(relativeTimestamp(msg.createdAt))
                    .font(theme.typography.caption2)
                    .foregroundStyle(theme.colors.onSurface.opacity(0.3))
                    .padding(.horizontal, 4)
            }
            if !msg.isUser { Spacer(minLength: 60) }
        }
    }

    private func imageBubble(_ urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fit)
            case .failure:
                Label("Image failed", systemImage: "photo")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.onSurface.opacity(0.4))
                    .frame(width: 120, height: 70)
                    .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.shape.radiusSmall))
            default:
                RoundedRectangle(cornerRadius: theme.shape.radiusSmall)
                    .fill(theme.colors.surface)
                    .frame(width: 120, height: 90)
                    .overlay { ProgressView().tint(theme.colors.onSurface.opacity(0.4)) }
            }
        }
        .frame(maxWidth: 220, maxHeight: 180)
        .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium, style: .continuous))
        #if canImport(UIKit)
        .onTapGesture { fullscreenImageURL = urlString }
        #endif
    }

    #if canImport(UIKit)
    private func uploadingBubble(_ image: UIImage) -> some View {
        HStack {
            Spacer(minLength: 60)
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 220, maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium, style: .continuous))
                    .opacity(0.5)

                VStack(spacing: 6) {
                    ProgressView().tint(.white).scaleEffect(1.2)
                    Text("Sending...")
                        .font(theme.typography.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                }
                .padding(8)
                .background(.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func fullscreenImage(_ urlString: String) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            AsyncImage(url: URL(string: urlString)) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fit).ignoresSafeArea()
                } else {
                    ProgressView().tint(.white)
                }
            }
        }
        .onTapGesture { fullscreenImageURL = nil }
        .statusBarHidden()
    }
    #endif

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            #if canImport(UIKit)
            if manager.supportsImages {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: manager.isUploadingImage ? "arrow.trianglehead.2.clockwise" : "photo.on.rectangle")
                        .font(.system(size: 22))
                        .foregroundStyle(manager.isUploadingImage ? theme.colors.onSurface.opacity(0.3) : theme.colors.accent)
                }
                .disabled(manager.isUploadingImage)
            }
            #endif

            TextField("Type a message...", text: $newMessage, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: 20))
                .lineLimit(1...5)
                .onChange(of: newMessage) {
                    manager.sendTyping(userId: userId)
                }

            Button {
                let text = newMessage
                newMessage = ""
                Task {
                    let success = await manager.sendMessage(text)
                    if !success { newMessage = text }
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? theme.colors.accent : theme.colors.onSurface.opacity(0.2))
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var canSend: Bool {
        !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !manager.isSending
    }

    // MARK: - Timestamp

    private func relativeTimestamp(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: isoString)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }
        guard let date else { return isoString }

        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        if seconds < 172800 { return "Yesterday" }
        if seconds < 604800 { return "\(seconds / 86400)d ago" }

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
}

#if canImport(UIKit)
extension String: @retroactive Identifiable {
    public var id: String { self }
}
#endif
