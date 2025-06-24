//
//  NativeAlternativePaymentPhoneItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentPhoneItemView: View {

    let item: NativeAlternativePaymentViewModelItem.PhoneNumberInput

    @Binding
    private(set) var focusedItemId: AnyHashable?

    // MARK: - View

    var body: some View {
        // todo(andrii-vysotskyi): update localizations
        POPhoneNumberField(
            phoneNumber: item.$value,
            countryPrompt: {
                Text(verbatim: "Country")
            },
            numberPrompt: item.prompt
        )
        .phoneNumberFieldTerritories(item.territories)
        .phoneNumberFieldStyle(
            PODefaultPhoneNumberFieldStyle(country: POMenuPickerStyle(inputStyle: style.input), number: .automatic)
        )
        .inputStyle(style.input)
        .backport.focused($focusedItemId, equals: item.id)
        .controlInvalid(item.isInvalid)
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}
