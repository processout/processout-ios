//
//  POCardScannerDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.04.2025.
//

import AVFoundation

/// Card scanner view delegate.
public protocol POCardScannerDelegate: AnyObject, Sendable {

    /// Implementation could return region of interest inside rect for card recognition.
    @MainActor
    func cardScanner(regionOfInterestInside rect: CGRect) -> CGRect?
}

extension POCardScannerDelegate {

    @MainActor
    public func cardScanner(regionOfInterestInside rect: CGRect) -> CGRect? {
        nil
    }
}
