import SwiftUI

#if !os(watchOS)

// MARK: - AdaptiveSheetModifier

/// Presents content as a sheet on compact sizes and a popover on regular sizes.
private struct AdaptiveSheetModifier<SheetContent: View>: ViewModifier {
    @Environment(\.horizontalSizeClass) private var sizeClass

    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        if sizeClass == .compact {
            content.sheet(isPresented: $isPresented) {
                sheetContent()
            }
        } else {
            content.popover(isPresented: $isPresented, arrowEdge: arrowEdge) {
                sheetContent()
            }
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Shows a sheet on compact widths and a popover on regular widths.
    func donkeyAdaptiveSheet<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge = .bottom,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(AdaptiveSheetModifier(
            isPresented: isPresented,
            arrowEdge: arrowEdge,
            sheetContent: content
        ))
    }
}

#endif
