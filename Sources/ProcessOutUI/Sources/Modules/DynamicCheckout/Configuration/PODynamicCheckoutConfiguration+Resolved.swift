//
//  PODynamicCheckoutConfiguration+Resolved.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

extension PODynamicCheckoutConfiguration.ExpressCheckoutSettingsButton {

    func resolved(
        defaultTitle: @autoclosure () -> String?, icon defaultIcon: @autoclosure () -> Image?
    ) -> PODynamicCheckoutConfiguration.ExpressCheckoutSettingsButton {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        let resolvedIcon = icon ?? defaultIcon().map(AnyView.init(erasing:))
        return .init(title: resolvedTitle, icon: resolvedIcon)
    }
}

extension PODynamicCheckoutConfiguration.ExpressCheckout {

    func resolved(defaultTitle: @autoclosure () -> String?) -> PODynamicCheckoutConfiguration.ExpressCheckout {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        return .init(title: resolvedTitle, settingsButton: settingsButton)
    }
}
