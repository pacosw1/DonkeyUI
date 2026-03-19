//
//  AppStoreReviewCard.swift
//  DonkeyUI
//
//  App Store-style review card with star rating.
//

import SwiftUI

// MARK: - Protocol

/// A type that can be displayed as an App Store review.
///
/// Conform your model to this protocol to use it with ``AppStoreReviewCard``.
public protocol ReviewDisplayable: Identifiable {
    var reviewTitle: String { get }
    var reviewUsername: String { get }
    var reviewTimeLabel: String { get }
    var reviewDescription: String { get }
    var reviewRating: Int { get }
}

// MARK: - Default Implementation

/// A simple concrete implementation of ``ReviewDisplayable``.
public struct SimpleReview: ReviewDisplayable {
    public let id: UUID
    public let reviewTitle: String
    public let reviewUsername: String
    public let reviewTimeLabel: String
    public let reviewDescription: String
    public let reviewRating: Int

    /// Creates a simple review.
    /// - Parameters:
    ///   - title: Review title / headline.
    ///   - username: Reviewer's display name.
    ///   - timeLabel: Time label (e.g. "4w ago").
    ///   - description: Review body text.
    ///   - rating: Star rating (1-5).
    public init(
        id: UUID = UUID(),
        title: String,
        username: String,
        timeLabel: String,
        description: String,
        rating: Int = 5
    ) {
        self.id = id
        self.reviewTitle = title
        self.reviewUsername = username
        self.reviewTimeLabel = timeLabel
        self.reviewDescription = description
        self.reviewRating = rating
    }
}

// MARK: - Rating Star View

/// A row of filled/empty star icons representing a rating.
///
/// ```swift
/// RatingStarView(starCount: 4, starSize: 14, color: .yellow)
/// ```
public struct RatingStarView: View {
    /// Number of filled stars (1-5).
    public var starCount: Int
    /// Size of each star icon.
    public var starSize: CGFloat
    /// Color of the star icons.
    public var color: Color

    /// Creates a rating star view.
    /// - Parameters:
    ///   - starCount: Number of filled stars.
    ///   - starSize: Point size of each star.
    ///   - color: Color for the stars.
    public init(starCount: Int = 5, starSize: CGFloat = 11, color: Color = .orange) {
        self.starCount = starCount
        self.starSize = starSize
        self.color = color
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 1) {
            ForEach(1..<6) { index in
                Image(systemName: index <= starCount ? "star.fill" : "star")
                    .foregroundStyle(color)
            }
            .font(.system(size: starSize))
        }
    }
}

// MARK: - App Store Review Card

/// A card that displays an App Store-style review with title, rating, username, time, and description.
///
/// Works with any type conforming to ``ReviewDisplayable``.
///
/// ```swift
/// let review = SimpleReview(title: "Amazing!", username: "John", timeLabel: "2w ago", description: "Love this app.", rating: 5)
/// AppStoreReviewCard(review: review)
/// ```
public struct AppStoreReviewCard<Review: ReviewDisplayable>: View {
    public let review: Review
    public var cardHeight: CGFloat

    /// Creates an App Store review card.
    /// - Parameters:
    ///   - review: The review to display (any ``ReviewDisplayable`` conforming type).
    ///   - cardHeight: Fixed height for the card (default 150).
    public init(review: Review, cardHeight: CGFloat = 150) {
        self.review = review
        self.cardHeight = cardHeight
    }

    public var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center) {
                    Text(review.reviewTitle)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(review.reviewTimeLabel)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                HStack(alignment: .top) {
                    RatingStarView(starCount: review.reviewRating)
                    Spacer()
                    Text(review.reviewUsername)
                        .foregroundStyle(.gray)
                        .font(.caption)
                }
            }
            .padding(.bottom, 10)

            Text(review.reviewDescription)
                .font(.system(size: 15))

            Spacer()
        }
        .frame(height: cardHeight)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.background.secondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(.separator, lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#Preview("App Store Review Card") {
    VStack(spacing: 16) {
        AppStoreReviewCard(
            review: SimpleReview(
                title: "Best habit tracker!",
                username: "Pacosw",
                timeLabel: "4w ago",
                description: "This app completely changed my daily routine. The streak feature keeps me motivated every single day.",
                rating: 5
            )
        )

        AppStoreReviewCard(
            review: SimpleReview(
                title: "Pretty good",
                username: "Jane D.",
                timeLabel: "2w ago",
                description: "Nice design, but could use a few more customization options.",
                rating: 4
            )
        )

        RatingStarView(starCount: 3, starSize: 20)
    }
    .padding()
}
