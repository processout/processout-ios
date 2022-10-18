//
//  PORepositoryPaginationOptions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

public struct PORepositoryPaginationOptions {

    public enum Order: String {
        case ascending = "asc", descending = "desc"
    }

    public enum Position {
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

    public init(position: Position?, limit: Int = 10, order: Order = .descending) {
        self.position = position
        self.limit = limit
        self.order = order
    }
}
