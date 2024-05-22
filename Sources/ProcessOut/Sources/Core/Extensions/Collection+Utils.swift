//
//  Collection+Utils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
