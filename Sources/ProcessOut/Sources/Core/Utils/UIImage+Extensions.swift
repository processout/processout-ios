//
//  UIImage+Dynamic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.04.2024.
//

import UIKit

extension UIImage {

    func rescaledToMatchDeviceScale() -> UIImage {
        // Rescales the image when its scale exceeds the device's display scale.
        // This avoids issues with displaying images in SwiftUI.
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

    @MainActor
    static func dynamic(lightImage: UIImage?, darkImage: UIImage?) -> UIImage? {
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
        let styleTrait = UITraitCollection(userInterfaceStyle: style)
        let traits = UITraitCollection(
            traitsFrom: [image.traitCollection, styleTrait]
        )
        asset.register(image, with: traits)
    }
}
