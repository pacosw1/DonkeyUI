import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum DonkeyUIDefaults {
    #if canImport(UIKit)
    public static let secondaryBackground = Color(uiColor: UIColor.secondarySystemBackground)
    public static let systemBackground = Color(uiColor: UIColor.systemBackground)
    #else
    public static let secondaryBackground = Color(NSColor.controlBackgroundColor)
    public static let systemBackground = Color(NSColor.windowBackgroundColor)
    #endif
}
