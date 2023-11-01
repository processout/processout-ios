//
//  ProcessOutUI.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 01.11.2023.
//

@_spi(PO) import ProcessOutCoreUI

/// Utility that provides a way to configure UI package. It is not mandatory to call
/// ``ProcessOutUI/ProcessOutUI/configure()`` method, but it is highly recommended
/// to avoid potential UI hangs.
public enum ProcessOutUI {

    /// Configures UI package and preloads needed resources.
    public static func configure() {
        POTypography.registerFonts()
        AddressSpecificationProvider.shared.prewarm()
    }
}
