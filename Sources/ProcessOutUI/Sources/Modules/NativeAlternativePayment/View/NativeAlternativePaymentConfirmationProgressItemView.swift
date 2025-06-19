//
//  NativeAlternativePaymentConfirmationProgressItemView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
struct NativeAlternativePaymentConfirmationProgressItemView: View { // swiftlint:disable:this type_name

    let item: NativeAlternativePaymentViewModelItem.ConfirmationProgress

    // MARK: -

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 28) {
                ProgressView("Transfer sent", value: 1)
                ProgressView(
                    value: 0.5,
                    label: {
                        Text("Waiting for confirmation")
                    },
                    currentValueLabel: {
                        Text("Please wait for \(remainingWaitDurationDescription) minutes")
                    }
                )
                .onReceive(timer) { _ in
                    updateRemainingWaitDuration()
                }
            }
            .progressViewStyle(.poStep)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .groupBoxStyle(.poMultistepProgress)
    }

    // MARK: - Private Properties

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State
    private var remainingWaitDurationDescription: String = ""

    // MARK: - Private Methods

    private func updateRemainingWaitDuration() {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        // swiftlint:disable:next line_length
        remainingWaitDurationDescription = formatter.string(from: item.estimatedCompletionDate.timeIntervalSinceNow) ?? ""
    }
}
