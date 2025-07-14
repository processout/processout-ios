//
//  NativeAlternativePaymentViewModelControlGroup.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.07.2025.
//

@_spi(PO) import ProcessOutCoreUI

struct NativeAlternativePaymentViewModelControlGroup {

    /// Available buttons.
    var buttons: [POButtonViewModel]

    /// Boolean value indicating whether controls should be rendered inline.
    var inline: Bool
}
