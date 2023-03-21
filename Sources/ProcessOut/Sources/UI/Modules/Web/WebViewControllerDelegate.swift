//
//  WebViewControllerDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.11.2022.
//

import Foundation

protocol WebViewControllerDelegate: AnyObject {

    /// Returns url to use for initial navigation.
    var url: URL { get }

    /// Asks delegate to complete with given url.
    /// - Throws: error if transform is not possible for some reason.
    func complete(with url: URL) throws

    /// Completes with failure.
    func complete(with failure: POFailure)
}
