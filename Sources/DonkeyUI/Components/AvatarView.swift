import SwiftUI

// MARK: - AvatarSize

public enum AvatarSize: CGFloat {
    case small = 32
    case medium = 44
    case large = 64
    case xl = 80

    public var fontSize: CGFloat {
        switch self {
        case .small: return 13
        case .medium: return 18
        case .large: return 26
        case .xl: return 34
        }
    }
}

// MARK: - AvatarView

public struct AvatarView: View {
    var name: String?
    var imageURL: URL?
    var systemIcon: String
    var size: AvatarSize
    var color: Color?

    @Environment(\.donkeyTheme) var theme

    public init(
        name: String? = nil,
        imageURL: URL? = nil,
        systemIcon: String = "person.fill",
        size: AvatarSize = .medium,
        color: Color? = nil
    ) {
        self.name = name
        self.imageURL = imageURL
        self.systemIcon = systemIcon
        self.size = size
        self.color = color
    }

    private var resolvedColor: Color {
        color ?? theme.colors.primary
    }

    private var initials: String? {
        guard let name = name, !name.isEmpty else { return nil }
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }

    public var body: some View {
        Group {
            if let url = imageURL {
                asyncImageContent(url: url)
            } else if let initials = initials {
                initialsContent(initials)
            } else {
                iconContent
            }
        }
        .frame(width: size.rawValue, height: size.rawValue)
        .clipShape(Circle())
    }

    private func asyncImageContent(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                fallbackView
            case .empty:
                ProgressView()
                    .frame(width: size.rawValue, height: size.rawValue)
                    .background(resolvedColor.opacity(0.1))
            @unknown default:
                fallbackView
            }
        }
    }

    private func initialsContent(_ text: String) -> some View {
        ZStack {
            Circle()
                .fill(resolvedColor.opacity(0.15))

            Text(text)
                .font(.system(size: size.fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(resolvedColor)
        }
    }

    private var iconContent: some View {
        ZStack {
            Circle()
                .fill(resolvedColor.opacity(0.15))

            Image(systemName: systemIcon)
                .font(.system(size: size.fontSize * 0.85))
                .foregroundStyle(resolvedColor)
        }
    }

    private var fallbackView: some View {
        Group {
            if let initials = initials {
                initialsContent(initials)
            } else {
                iconContent
            }
        }
    }
}

// MARK: - Preview

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                AvatarView(name: "John Doe", size: .small)
                AvatarView(name: "John Doe", size: .medium)
                AvatarView(name: "John Doe", size: .large)
                AvatarView(name: "John Doe", size: .xl)
            }

            HStack(spacing: 16) {
                AvatarView(name: "Alice", size: .medium, color: .purple)
                AvatarView(name: "Bob Smith", size: .medium, color: .orange)
                AvatarView(size: .medium, color: .blue)
                AvatarView(systemIcon: "star.fill", size: .medium, color: .yellow)
            }

            HStack(spacing: 16) {
                AvatarView(
                    name: "Fallback",
                    imageURL: URL(string: "https://example.com/avatar.jpg"),
                    size: .large
                )
                AvatarView(
                    imageURL: URL(string: "https://picsum.photos/200"),
                    size: .large
                )
            }
        }
        .padding()
    }
}
