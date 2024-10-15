//
//  POFontFeaturesSettings.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

@_spi(PO)
public struct POFontFeaturesSettings: Sendable {

    /// The number spacing feature type specifies a choice for the appearance of digits.
    public var numberSpacing: POFontNumberSpacing = .proportional
}
