import SwiftUI

#if !os(watchOS)

// MARK: - Draggable Modifier

private struct DonkeyDraggableModifier<T: Transferable>: ViewModifier {
    let data: T

    func body(content: Content) -> some View {
        content.draggable(data)
    }
}

// MARK: - Drop Target Modifier

private struct DonkeyDropTargetModifier<T: Transferable>: ViewModifier {
    let type: T.Type
    let action: ([T]) -> Bool

    func body(content: Content) -> some View {
        content.dropDestination(for: type, action: { items, _ in
            action(items)
        })
    }
}

// MARK: - View Extensions

public extension View {
    /// Makes the view draggable with the given transferable data.
    func donkeyDraggable<T: Transferable>(_ data: T) -> some View {
        modifier(DonkeyDraggableModifier(data: data))
    }

    /// Marks the view as a drop target for the specified transferable type.
    func donkeyDropTarget<T: Transferable>(
        for type: T.Type,
        action: @escaping ([T]) -> Bool
    ) -> some View {
        modifier(DonkeyDropTargetModifier(type: type, action: action))
    }
}

#endif
