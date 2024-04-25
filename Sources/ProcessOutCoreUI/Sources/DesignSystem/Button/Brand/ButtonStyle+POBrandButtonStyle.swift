//
//  ButtonStyle+POBrandButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

@available(iOS 14, *)
extension ButtonStyle where Self == POBrandButtonStyle {

    /// Simple style
    @_disfavoredOverload
    public static var brand: POBrandButtonStyle {
        .init(title: .init(color: Color(.Text.on), typography: .Fixed.button), border: .clear, shadow: .clear)
    }
}