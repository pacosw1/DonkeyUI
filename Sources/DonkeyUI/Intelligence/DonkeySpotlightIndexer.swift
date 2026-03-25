#if canImport(CoreSpotlight)
import CoreSpotlight
import os.log

private let logger = Logger(subsystem: "DonkeyUI", category: "Spotlight")

/// Protocol for making app models searchable via Spotlight.
public protocol DonkeySearchable {
    var searchableID: String { get }
    var searchableDomain: String { get }
    var searchableTitle: String { get }
    var searchableDescription: String? { get }
    var searchableKeywords: [String] { get }
    var searchableThumbnailData: Data? { get }
}

public extension DonkeySearchable {
    var searchableDescription: String? { nil }
    var searchableKeywords: [String] { [] }
    var searchableThumbnailData: Data? { nil }
}

/// Helper for indexing app content in Spotlight with semantic search support.
public enum DonkeySpotlightIndexer {

    /// Index multiple items for Spotlight search.
    public static func index(_ items: [any DonkeySearchable]) async throws {
        let searchableItems = items.map(makeSearchableItem)
        try await CSSearchableIndex.default().indexSearchableItems(searchableItems)
        logger.debug("Indexed \(items.count) items in Spotlight")
    }

    /// Index a single item for Spotlight search.
    public static func index(_ item: any DonkeySearchable) async throws {
        try await index([item])
    }

    /// Remove items by their identifiers.
    public static func remove(identifiers: [String]) async throws {
        try await CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: identifiers)
        logger.debug("Removed \(identifiers.count) items from Spotlight")
    }

    /// Remove all items in a domain.
    public static func remove(domain: String) async throws {
        try await CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domain])
        logger.debug("Removed Spotlight items in domain: \(domain)")
    }

    /// Remove all indexed items.
    public static func removeAll() async throws {
        try await CSSearchableIndex.default().deleteAllSearchableItems()
        logger.debug("Removed all Spotlight items")
    }

    private static func makeSearchableItem(_ item: any DonkeySearchable) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .text)
        attributes.title = item.searchableTitle
        attributes.contentDescription = item.searchableDescription
        attributes.keywords = item.searchableKeywords
        attributes.thumbnailData = item.searchableThumbnailData

        return CSSearchableItem(
            uniqueIdentifier: item.searchableID,
            domainIdentifier: item.searchableDomain,
            attributeSet: attributes
        )
    }
}
#endif
