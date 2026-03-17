//
//  POCardScannerConfiguration+Resolved.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.03.2026.
//

import SwiftUI

extension POCardScannerConfiguration.CancelButton {

    func resolved(
        defaultTitle: @autoclosure () -> String?, icon defaultIcon: @autoclosure () -> Image? = nil
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
