//
//  BarcodeImageProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2024.
//

import ProcessOut
import UIKit

protocol BarcodeImageProvider {

    /// Generates an image for the given barcode if the barcode format is supported and a valid
    /// image can be produced.
    ///
    /// - Parameters:
    ///   - barcode: The `POBarcode` object representing the barcode to generate the image for.
    ///   - minimumSize: The minimum size the generated image should have.
    ///
    /// - Returns: A `UIImage` of the barcode if successful, or `nil` if generation is not possible.
    func image(for barcode: POBarcode, minimumSize: CGSize) -> UIImage?
}
