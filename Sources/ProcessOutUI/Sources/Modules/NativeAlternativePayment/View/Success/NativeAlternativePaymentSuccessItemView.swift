//
//  NativeAlternativePaymentSuccessItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

struct NativeAlternativePaymentSuccessItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Success

    // MARK: - View

    var body: some View {
        let configuration = PONativeAlternativePaymentSuccessViewStyleConfiguration {
            Text(item.title)
        } description: {
            if let description = item.description {
                Text(description)
            }
        }
        AnyView(style.successView.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    @Environment(\.nativeAlternativePaymentStyle)
    private var style
}

#Preview {
    NativeAlternativePaymentSuccessItemView(
        item: .init(title: "Payment approved!", description: "You paid $40.00")
    )
}
