//
//  GroupBoxStyle+PO.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

@available(iOS 14, *)
@_spi(PO)
extension GroupBoxStyle where Self == POGroupBoxStyle {

    /// Default ProcessOut group box style.
    public static var poAutomatic: POGroupBoxStyle {
        .init(
            labelTextStyle: .init(
                color: .Text.primary, typography: .Text.s16(weight: .medium)
            ),
            contentStyle: .init(
                dividerColor: .Border.primary,
                border: .regular(color: .Input.Border.default),
                backgroundColor: .Surface.elevated
            )
        )
    }
}

@available(iOS 16, *)
#Preview {
    GroupBox {
        POLabeledContent {
            Button { } label: {
                Label {
                    Text("Copy")
                } icon: {
                    Image(poResource: .info)
                        .renderingMode(.template)
                }
            }
            .buttonStyle(.secondary)
            .backport.poControlSize(.small)
            .controlWidth(.regular)
        } label: {
            Text("Amount to send")
            Text("$45.99")
        }
    } label: {
        Text("Transfer Details")
    }
    .groupBoxStyle(.poAutomatic)
    .padding()
}
