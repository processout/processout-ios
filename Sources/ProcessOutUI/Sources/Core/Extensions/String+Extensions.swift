//
//  String+Extensions.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.07.2023.
//

import Foundation

extension String {

    /// Returns a string object containing the characters of the receiver that lie within a given range.
    func substring(with range: NSRange) -> String {
        (self as NSString).substring(with: range) // swiftlint:disable:this legacy_objc_type
    }
}
