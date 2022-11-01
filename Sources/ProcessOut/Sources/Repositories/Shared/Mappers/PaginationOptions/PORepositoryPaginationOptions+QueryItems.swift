//
//  PORepositoryPaginationOptions+QueryItems.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

extension PORepositoryPaginationOptions {

    /// Returns query items for pagination options.
    var queryItems: [String: CustomStringConvertible] {
        var queryItems: [String: CustomStringConvertible] = ["limit": limit, "order": order.rawValue]
        switch position {
        case .before(let item):
            queryItems["end_before"] = item
        case .after(let item):
            queryItems["start_after"] = item
        default:
            break
        }
        return queryItems
    }
}
