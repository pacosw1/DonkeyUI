//
//  EmojiPicker.swift
//  DonkeyUI
//
//  Emoji-only keyboard input picker.
//  Forces the emoji keyboard and accepts only single emoji characters.
//

#if canImport(UIKit)
import SwiftUI
import Combine
import UIKit

// MARK: - UIKit Emoji Text View

/// A `UITextView` subclass that forces the emoji keyboard as the input mode.
public class DonkeyUIEmojiTextView: UITextView {

    public func setEmoji() {
        _ = self.textInputMode
    }

    override public var textInputContextIdentifier: String? {
        return ""
    }

    override public var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                self.keyboardType = .default
                return mode
            }
        }
        return nil
    }

    /// Dismisses the emoji keyboard.
    public func dismissKeyboard() {
        self.resignFirstResponder()
    }
}

// MARK: - SwiftUI Representable

/// A SwiftUI wrapper around ``DonkeyUIEmojiTextView`` that presents an emoji-only keyboard.
///
/// Accepts a single emoji character; any non-emoji input or multi-character input is rejected.
public struct DonkeyEmojiTextView: UIViewRepresentable {
    @Binding public var text: String
    public var placeholder: String
    public var fontSize: CGFloat

    /// Creates an emoji text view.
    /// - Parameters:
    ///   - text: Binding to the selected emoji string.
    ///   - placeholder: Placeholder text (shown in the underlying text view).
    ///   - fontSize: Font size for the emoji display.
    public init(text: Binding<String>, placeholder: String = "", fontSize: CGFloat = 40) {
        self._text = text
        self.placeholder = placeholder
        self.fontSize = fontSize
    }

    public func makeUIView(context: Context) -> DonkeyUIEmojiTextView {
        let emojiTextView = DonkeyUIEmojiTextView()
        emojiTextView.text = text
        emojiTextView.tintColor = .clear
        emojiTextView.delegate = context.coordinator
        emojiTextView.backgroundColor = .clear
        emojiTextView.font = UIFont.systemFont(ofSize: fontSize)
        emojiTextView.textAlignment = .center

        let verticalPadding = (50 - (emojiTextView.font?.lineHeight ?? 40)) / 2
        emojiTextView.textContainerInset = UIEdgeInsets(
            top: verticalPadding, left: 0,
            bottom: verticalPadding, right: 0
        )

        return emojiTextView
    }

    public func updateUIView(_ uiView: DonkeyUIEmojiTextView, context: Context) {
        uiView.text = text
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: DonkeyEmojiTextView

        init(parent: DonkeyEmojiTextView) {
            self.parent = parent
        }

        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let isSingleEmoji = text.donkeyOnlyEmoji().count == text.count && text.count == 1
            let isDeleting = text.isEmpty

            if isSingleEmoji {
                DispatchQueue.main.async {
                    self.parent.text = text
                }
                return false
            } else if isDeleting {
                return false
            } else {
                return false
            }
        }

        public func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
        }
    }
}

// MARK: - EmojiPicker View

/// A tap-to-edit emoji picker that opens the emoji keyboard.
///
/// Displays the currently selected emoji inside a bordered container.
/// Tapping it opens the system emoji keyboard for selection.
///
/// ```swift
/// @State private var emoji = "🎸"
/// EmojiPicker(selected: $emoji)
/// ```
///
/// - Parameters:
///   - selected: Binding to the currently selected emoji string.
///   - size: Display size of the emoji container (default 50).
public struct EmojiPicker: View {
    @Binding public var selected: String
    @FocusState private var isEmojiTextViewFocused: Bool
    public var size: CGFloat

    /// Creates an emoji picker.
    /// - Parameters:
    ///   - selected: Binding to the selected emoji.
    ///   - size: Size of the emoji display area.
    public init(selected: Binding<String>, size: CGFloat = 50) {
        self._selected = selected
        self.size = size
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 2) {
            DonkeyEmojiTextView(text: $selected, placeholder: "Enter emoji")
                .frame(width: size, height: size)
                .focused($isEmojiTextViewFocused)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isEmojiTextViewFocused = true
        }
    }
}

// MARK: - String / Character Extensions

public extension Character {
    /// Whether this character is an emoji.
    var isDonkeyEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

public extension String {
    /// Returns a copy of the string containing only emoji characters.
    func donkeyOnlyEmoji() -> String {
        return self.filter { $0.isDonkeyEmoji }
    }
}

// MARK: - Preview

#Preview("Emoji Picker") {
    struct EmojiPickerPreview: View {
        @State private var emoji = "🎸"
        var body: some View {
            VStack(spacing: 20) {
                EmojiPicker(selected: $emoji)
                Text("Selected: \(emoji)")
            }
            .padding()
        }
    }
    return EmojiPickerPreview()
}
#endif
