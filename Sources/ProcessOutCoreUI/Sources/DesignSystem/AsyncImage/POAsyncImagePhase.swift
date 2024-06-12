//
//  POAsyncImagePhase.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

@_spi(PO)
public enum POAsyncImagePhase {

    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    /// An image failed to load with an error.
    case failure(any Error)
}
