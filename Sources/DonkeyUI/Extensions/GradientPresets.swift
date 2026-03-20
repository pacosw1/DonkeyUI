import SwiftUI

// MARK: - Gradient Presets

public extension LinearGradient {

    /// Warm orange to yellow to light
    static var sunrise: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.95, green: 0.45, blue: 0.15),
                     Color(red: 0.98, green: 0.72, blue: 0.20),
                     Color(red: 1.00, green: 0.90, blue: 0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Deep blue to cyan to light blue
    static var ocean: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.15, blue: 0.55),
                     Color(red: 0.10, green: 0.55, blue: 0.75),
                     Color(red: 0.50, green: 0.82, blue: 0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Purple to pink to orange
    static var sunset: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.45, green: 0.15, blue: 0.65),
                     Color(red: 0.85, green: 0.30, blue: 0.50),
                     Color(red: 0.98, green: 0.55, blue: 0.30)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Dark green to green to mint
    static var forest: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.08, green: 0.30, blue: 0.15),
                     Color(red: 0.18, green: 0.60, blue: 0.32),
                     Color(red: 0.55, green: 0.85, blue: 0.68)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Purple to magenta to pink
    static var berry: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.45, green: 0.10, blue: 0.55),
                     Color(red: 0.75, green: 0.15, blue: 0.50),
                     Color(red: 0.95, green: 0.40, blue: 0.60)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Dark gold to gold to light gold
    static var gold: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.55, green: 0.40, blue: 0.10),
                     Color(red: 0.80, green: 0.65, blue: 0.15),
                     Color(red: 0.95, green: 0.85, blue: 0.45)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Near-black to dark blue to indigo
    static var midnight: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.05, blue: 0.12),
                     Color(red: 0.10, green: 0.12, blue: 0.35),
                     Color(red: 0.25, green: 0.22, blue: 0.55)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Purple to lavender to light purple
    static var lavender: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.50, green: 0.30, blue: 0.70),
                     Color(red: 0.68, green: 0.55, blue: 0.85),
                     Color(red: 0.85, green: 0.75, blue: 0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview

#Preview("Gradient Presets") {
    let presets: [(String, LinearGradient)] = [
        ("Sunrise", .sunrise),
        ("Ocean", .ocean),
        ("Sunset", .sunset),
        ("Forest", .forest),
        ("Berry", .berry),
        ("Gold", .gold),
        ("Midnight", .midnight),
        ("Lavender", .lavender),
    ]

    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(presets, id: \.0) { name, gradient in
                gradient
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        Text(name)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    )
            }
        }
        .padding()
    }
}
