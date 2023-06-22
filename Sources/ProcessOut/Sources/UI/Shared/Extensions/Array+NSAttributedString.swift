//
//  Array+NSAttributedString.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.06.2023.
//

import Foundation

extension Array where Element == NSAttributedString {

    /// Returns a new attributed string by concatenating the elements of the sequence,
    /// adding the given separator between each element.
    func joined(separator: NSAttributedString = .init()) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        dropLast().forEach { element in
            mutableAttributedString.append(element)
            mutableAttributedString.append(separator)
        }
        if let last {
            mutableAttributedString.append(last)
        }
        return mutableAttributedString
    }
}
