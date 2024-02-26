//
//  CGImagePropertyOrientation+Utils.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 20.02.2024.
//

import CoreImage

extension CGImagePropertyOrientation {

    /// A boolean value that indicates whether this is a portrait orientation.
    var isPortrait: Bool {
        switch self {
        case .up, .upMirrored, .down, .downMirrored:
            return true
        default:
            return false
        }
    }

    /// A boolean value that indicates whether this is a landscape orientation.
    var isLandscape: Bool {
        !isPortrait
    }
}
