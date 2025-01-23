//
//  UIImage+Dynamic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.04.2024.
//

import UIKit

extension UIImage {

    @MainActor
    static func dynamic(lightImage: UIImage?, darkImage: UIImage?) -> UIImage? {
        // When image with scale greater than 3 is registered asset created explicitly produced
        // image is malformed and doesn't contain images for light nor dark styles.
        guard let image = lightImage ?? darkImage else {
            return nil
        }
        guard let imageAsset = image.imageAsset else {
            assertionFailure("Unable to create dynamic image for images without asset.")
            return image
        }
        if let lightImage {
            register(image: lightImage, with: .light, in: imageAsset)
        }
        if let darkImage {
            register(image: darkImage, with: .dark, in: imageAsset)
        }
        return image
    }

    // MARK: - Private Methods

    private static func register(image: UIImage, with style: UIUserInterfaceStyle, in asset: UIImageAsset) {
        let scaledImage = image.rescaledToMatchDeviceScale()
        let styleTrait = UITraitCollection(userInterfaceStyle: style)
        let traits = UITraitCollection(
            traitsFrom: [scaledImage.traitCollection, styleTrait]
        )
        asset.register(scaledImage, with: traits)
    }

    private func rescaledToMatchDeviceScale() -> UIImage {
        // Rescales the image when its scale exceeds the device's display scale.
        // This avoids issues with displaying dynamic images in SwiftUI.
        let format = UIGraphicsImageRendererFormat.preferred()
        guard scale > format.scale, size != .zero else {
            return self
        }
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let resizedImage = renderer.image { context in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return resizedImage.withRenderingMode(renderingMode)
    }
}
