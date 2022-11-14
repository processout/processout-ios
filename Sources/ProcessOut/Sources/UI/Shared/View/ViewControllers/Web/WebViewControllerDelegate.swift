//
//  WebViewControllerDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.11.2022.
//

import Foundation

protocol WebViewControllerDelegate<Success>: AnyObject {

    associatedtype Success

    /// Returns url to use for initial navigation.
    var url: URL { get }

    /// Asks delegate to convert given url into expected success value.
    /// - Throws: error if transform is not possible for some reason.
    func mapToSuccessValue(url: URL) throws -> Success
}
