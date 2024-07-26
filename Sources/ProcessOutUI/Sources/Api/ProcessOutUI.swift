//
//  ProcessOutUI.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 01.11.2023.
//

@_spi(PO) import ProcessOutCoreUI

/// Utility that provides a way to configure UI package.
///
/// This method should be called when the application starts to ensure that all resources are loaded and available
/// for SDK to use. It also allows to avoid potential UI hangs during runtime.
public enum ProcessOutUI {

    /// Configures UI package and preloads needed resources.
    @MainActor
    public static func configure() {
        POTypography.registerFonts()
        AddressSpecificationProvider.shared.prewarm()
        PODefaultPhoneNumberMetadataProvider.shared.prewarm()
    }
}
