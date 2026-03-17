//
//  POCardTokenizationConfiguration+Resolved.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.04.2025.
//

import SwiftUI

extension POCardTokenizationConfiguration.CardScanner.ScanButton {

    func resolved(
        defaultTitle: @autoclosure () -> String?, icon defaultIcon: @autoclosure () -> Image?
    ) -> Self {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        let resolvedIcon = icon ?? defaultIcon().map(AnyView.init(erasing:))
        return .init(title: resolvedTitle, icon: resolvedIcon)
    }
}

extension POCardTokenizationConfiguration.PreferredScheme {

    /// Returns resolved configuration.
    func resolved(defaultTitle: @autoclosure () -> String?) -> Self {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        return .init(title: resolvedTitle, prefersInline: prefersInline)
    }
}

extension POCardTokenizationConfiguration.SubmitButton {

    func resolved(
        defaultTitle: @autoclosure () -> String?, icon defaultIcon: @autoclosure () -> Image?
    ) -> Self {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        let resolvedIcon = icon ?? defaultIcon().map(AnyView.init(erasing:))
        return .init(title: resolvedTitle, icon: resolvedIcon)
    }
}

extension POCardTokenizationConfiguration.CancelButton {

    func resolved(
        defaultTitle: @autoclosure () -> String?, icon defaultIcon: @autoclosure () -> Image?
    ) -> Self {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        let resolvedIcon = icon ?? defaultIcon().map(AnyView.init(erasing:))
        return .init(title: resolvedTitle, icon: resolvedIcon, confirmation: self.confirmation)
    }
}
