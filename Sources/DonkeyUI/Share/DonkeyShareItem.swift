#if !os(watchOS)
import SwiftUI

public struct DonkeyShareItem: Transferable {
    public let text: String?
    public let url: URL?

    public static func text(_ text: String) -> DonkeyShareItem {
        DonkeyShareItem(text: text, url: nil)
    }

    public static func url(_ url: URL) -> DonkeyShareItem {
        DonkeyShareItem(text: nil, url: url)
    }

    public static func textAndURL(_ text: String, url: URL) -> DonkeyShareItem {
        DonkeyShareItem(text: text, url: url)
    }

    public init(text: String? = nil, url: URL? = nil) {
        self.text = text
        self.url = url
    }

    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { item in
            if let text = item.text, let url = item.url {
                return "\(text)\n\(url.absoluteString)"
            } else if let url = item.url {
                return url.absoluteString
            } else {
                return item.text ?? ""
            }
        }
    }
}
#endif
