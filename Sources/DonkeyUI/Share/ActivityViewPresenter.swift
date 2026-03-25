#if canImport(UIKit) && !os(watchOS)
import SwiftUI
import UIKit

struct ActivityViewController: UIViewControllerRepresentable {
    let items: [Any]
    let excludedTypes: [UIActivity.ActivityType]
    let onComplete: ((Bool) -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedTypes.isEmpty ? nil : excludedTypes
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete?(completed)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ActivitySheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    let items: [Any]
    let excludedTypes: [UIActivity.ActivityType]
    let onComplete: ((Bool) -> Void)?

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            ActivityViewController(
                items: items,
                excludedTypes: excludedTypes,
                onComplete: { completed in
                    onComplete?(completed)
                    isPresented = false
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}

public extension View {
    /// Present a UIActivityViewController as a sheet.
    func activitySheet(
        isPresented: Binding<Bool>,
        items: [Any],
        excludedTypes: [UIActivity.ActivityType] = [],
        onComplete: ((Bool) -> Void)? = nil
    ) -> some View {
        modifier(ActivitySheetModifier(
            isPresented: isPresented,
            items: items,
            excludedTypes: excludedTypes,
            onComplete: onComplete
        ))
    }
}
#endif
