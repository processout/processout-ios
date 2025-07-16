//
//  UIFont+FontFeaturesSettings.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

import UIKit

extension UIFont {

    func addingFeatures(_ settings: POFontFeaturesSettings) -> UIFont {
        let settings = [
            settings.numberSpacing
        ]
        let rawSettings = settings.map { setting -> [UIFontDescriptor.FeatureKey: Any] in
            [.type: setting.featureType, .selector: setting.featureSelector]
        }
        let newDescriptor = fontDescriptor.addingAttributes(
            [.featureSettings: rawSettings]
        )
        return UIFont(descriptor: newDescriptor, size: 0)
    }
}
