//
//  NativeAlternativePaymentSuccessItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentSuccessItemView: View {

    let item: NativeAlternativePaymentViewModelItem.Success

    // MARK: - View

    var body: some View {
        // todo(andrii-vysotskyi): support custom style
        VStack(spacing: POSpacing.space6) {
            ProgressView(value: 1)
                .poProgressViewStyle(.poStep)
            Text(item.title)
                .foregroundColor(Color.Text.primary)
                .typography(.Text.s20(weight: .semibold))
            Text(item.description)
                .typography(.Paragraph.s16(weight: .regular))
                .foregroundColor(Color.Text.secondary)
        }
        .padding(.top, POSpacing.space28)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

@available(iOS 14, *)
#Preview {
    NativeAlternativePaymentSuccessItemView(
        item: .init(title: "Payment approved!", description: "You paid $40.00")
    )
}
