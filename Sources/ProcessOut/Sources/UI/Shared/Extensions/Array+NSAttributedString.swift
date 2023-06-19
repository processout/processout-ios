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
    func joined(separator: NSAttributedString? = nil) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        enumerated().forEach { offset, element in
            mutableAttributedString.append(element)
            if let separator, offset < count - 1 {
                mutableAttributedString.append(separator)
            }
        }
        return mutableAttributedString
    }
}
