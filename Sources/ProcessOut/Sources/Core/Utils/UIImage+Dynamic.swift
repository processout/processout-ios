//
//  UIImage+Dynamic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 04.04.2024.
//

import UIKit

extension UIImage {

    static func dynamic(lightImage: UIImage?, darkImage: UIImage?) -> UIImage {
        let asset = UIImageAsset()
        if let image = lightImage {
            register(image: image, with: .light, in: asset)
        }
        if let image = darkImage {
            register(image: image, with: .dark, in: asset)
        }
        return asset.image(with: .current)
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
