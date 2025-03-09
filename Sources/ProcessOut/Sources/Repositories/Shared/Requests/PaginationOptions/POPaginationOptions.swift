//
//  POPaginationOptions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

public struct POPaginationOptions: Sendable, Codable {

    public enum Order: String, Sendable, Codable {
        case ascending = "asc", descending = "desc"
    }

    public enum Position: Sendable {
        case after(String), before(String)
    }

    /// Specifies cursor position to fetch items. The page contains the items that come either before or after the
    /// cursor but it does not include the cursor itself.
    ///
    /// For example, to fetch the second page, pass the id of the last item in the first page using the after position.
    /// If you want the fetch the items that come before the cursor, then pass its id as the before position.
    public let position: Position?

    /// Specifies the maximum number of items you want the page to contain. Defaults to 10.
    public let limit: Int

    /// Entities are sorted in ascending order by default.
    public let order: Order

    public init(position: Position? = nil, limit: Int = 10, order: Order = .descending) {
        self.position = position
        self.limit = limit
        self.order = order
    }
}

extension POPaginationOptions.Position: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .before) {
            self = .before(value)
        } else {
            let value = try container.decode(String.self, forKey: .after)
            self = .after(value)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .before(let value):
            try container.encode(value, forKey: .before)
        case .after(let value):
            try container.encode(value, forKey: .after)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case before, after
    }
}
