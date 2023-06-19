//
//  DefaultSafariViewModelDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.11.2022.
//

import Foundation

protocol DefaultSafariViewModelDelegate: AnyObject {

    /// Asks delegate to complete with given url.
    /// - Throws: error if transform is not possible for some reason.
    func complete(with url: URL) throws

    /// Completes with failure.
    func complete(with failure: POFailure)
}
