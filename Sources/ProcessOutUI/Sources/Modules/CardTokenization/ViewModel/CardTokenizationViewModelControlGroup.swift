//
//  CardTokenizationViewModelControlGroup.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2025.
//

@_spi(PO) import ProcessOutCoreUI

struct CardTokenizationViewModelControlGroup {

    /// Available buttons.
    var buttons: [POButtonViewModel]

    /// Boolean value indicating whether controls should be rendered inline.
    var inline: Bool
}
