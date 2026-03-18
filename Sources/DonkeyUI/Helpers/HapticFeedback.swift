import Foundation

#if canImport(UIKit)
import UIKit
#endif

// MARK: - DonkeyHaptics

public struct DonkeyHaptics {

    #if canImport(UIKit)

    public static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    public static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    public static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    public static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    public static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    public static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    public static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    #else

    public static func light() {}
    public static func medium() {}
    public static func heavy() {}
    public static func success() {}
    public static func warning() {}
    public static func error() {}
    public static func selection() {}

    #endif
}
