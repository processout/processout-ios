//
//  NativeAlternativePaymentConfirmationProgressItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

struct NativeAlternativePaymentConfirmationProgressItemView: View { // swiftlint:disable:this type_name

    let item: NativeAlternativePaymentViewModelItem.ConfirmationProgress

    // MARK: -

    var body: some View {
        let configuration = PONativeAlternativePaymentConfirmationProgressViewStyleConfiguration(
            estimatedCompletionDate: item.estimatedCompletionDate
        )
        AnyView(style.paymentConfirmationProgressView.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}
