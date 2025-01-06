//
//  POSavedPaymentMethodsConfiguration+Resolved.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.01.2025.
//

import SwiftUI

extension POSavedPaymentMethodsConfiguration.DeleteButton {

    func resolved(
        defaultTitle: @autoclosure () -> String?, icon defaultIcon: @autoclosure () -> Image?
    ) -> POSavedPaymentMethodsConfiguration.DeleteButton {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        let resolvedIcon = icon ?? defaultIcon().map(AnyView.init(erasing:))
        return .init(title: resolvedTitle, icon: resolvedIcon, confirmation: self.confirmation)
    }
}

extension POSavedPaymentMethodsConfiguration.CancelButton {

    func resolved(
        defaultTitle: @autoclosure () -> String?, icon defaultIcon: @autoclosure () -> Image?
    ) -> POSavedPaymentMethodsConfiguration.CancelButton {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        let resolvedIcon = icon ?? defaultIcon().map(AnyView.init(erasing:))
        return .init(title: resolvedTitle, icon: resolvedIcon, confirmation: self.confirmation)
    }
}
