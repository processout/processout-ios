//
//  DefaultBarcodeImageProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2024.
//

@_spi(PO) import ProcessOut
import CoreImage.CIFilterBuiltins
import UIKit

final class DefaultBarcodeImageProvider: BarcodeImageProvider {

    init(logger: POLogger) {
        self.logger = logger
    }

    // MARK: - BarcodeImageProvider

    func image(for barcode: POBarcode, minimumSize: CGSize) -> UIImage? {
        guard let ciImage = ciFilter(for: barcode)?.outputImage else {
            logger.warn("Failed to generate CIImage for barcode of type \(barcode.type.rawValue).")
            return nil
        }
        let scaledCiImage = ciImage.transformed(
            by: transform(from: ciImage.extent.size, to: minimumSize)
        )
        let renderer = UIGraphicsImageRenderer(size: scaledCiImage.extent.size)
        let image = renderer.image { context in
            let ciContext = CIContext(cgContext: context.cgContext, options: nil)
            ciContext.draw(scaledCiImage, in: scaledCiImage.extent, from: scaledCiImage.extent)
        }
        return image
    }

    // MARK: - Private Properties

    private let logger: POLogger

    // MARK: - Private Methods

    private func ciFilter(for barcode: POBarcode) -> CIFilter? {
        switch barcode.type {
        case .qr:
            let generator = CIFilter.qrCodeGenerator()
            generator.message = barcode.message
            generator.correctionLevel = "L"
            return generator
        default:
            return nil
        }
    }

    /// Creates a scaling transform to resize an object from its original size to at least
    /// the specified minimum target size, preserving aspect ratio.
    private func transform(from originalSize: CGSize, to minTargetSize: CGSize) -> CGAffineTransform {
        let scale = max(
            max(minTargetSize.width, 1) / originalSize.width, max(minTargetSize.height, 1) / originalSize.height
        )
        return .init(scaleX: scale, y: scale)
    }
}
