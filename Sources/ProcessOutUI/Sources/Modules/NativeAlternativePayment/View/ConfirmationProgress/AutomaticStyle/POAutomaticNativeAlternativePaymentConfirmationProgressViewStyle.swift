//
//  POAutomaticNativeAlternativePaymentConfirmationProgressViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.06.2025.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

// swiftlint:disable type_name strict_fileprivate generic_type_name

public struct POAutomaticNativeAlternativePaymentConfirmationProgressViewStyle<
    ProgressViewStyleType: ProgressViewStyle,
    GroupBoxStyleType: GroupBoxStyle
>: PONativeAlternativePaymentConfirmationProgressViewStyle {

    public init(progressView: ProgressViewStyleType = .poStep, groupBox: GroupBoxStyleType = .poMultistepProgress) {
        self.progressView = progressView
        self.groupBox = groupBox
    }

    // MARK: - PONativeAlternativePaymentConfirmationProgressViewStyle

    public func makeBody(configuration: Configuration) -> some View {
        ContentView(style: self, configuration: configuration)
    }

    // MARK: - Private Properties

    fileprivate let progressView: ProgressViewStyleType
    fileprivate let groupBox: GroupBoxStyleType
}

// swiftlint:enable type_name strict_fileprivate

private struct ContentView<ProgressViewStyleType: ProgressViewStyle, GroupBoxStyleType: GroupBoxStyle>: View {

    let style: POAutomaticNativeAlternativePaymentConfirmationProgressViewStyle<ProgressViewStyleType, GroupBoxStyleType> // swiftlint:disable:this line_length
    let configuration: PONativeAlternativePaymentConfirmationProgressViewStyleConfiguration

    // MARK: - View

    var body: some View {
        GroupBox {
            Group {
                ProgressView(
                    String(resource: .NativeAlternativePayment.PaymentConfirmation.Progress.FirstStep.title),
                    value: 1
                )
                ProgressView(
                    value: 0.5,
                    label: {
                        Text(String(resource: .NativeAlternativePayment.PaymentConfirmation.Progress.SecondStep.title))
                    },
                    currentValueLabel: {
                        let title = String(
                            resource: .NativeAlternativePayment.PaymentConfirmation.Progress.SecondStep.description,
                            replacements: remainingWaitDurationDescription
                        )
                        Text(title)
                    }
                )
                .onAppear {
                    updateRemainingWaitDuration()
                }
                .onReceive(timer) { _ in
                    updateRemainingWaitDuration()
                }
            }
            .progressViewStyle(style.progressView)
        }
        .groupBoxStyle(style.groupBox)
    }

    // MARK: - Private Properties

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State
    private var remainingWaitDurationDescription: String = ""

    // MARK: - Private Methods

    private func updateRemainingWaitDuration() {
        let remainingDuration = configuration.estimatedCompletionDate.timeIntervalSinceNow
        remainingWaitDurationDescription = dateComponentsFormatter.string(from: remainingDuration) ?? ""
    }
}

private let dateComponentsFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = [.pad]
    return formatter
}()

// swiftlint:enable generic_type_name
