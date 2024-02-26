//
//  CardScannerView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 21.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@_spi(PO)
@available(iOS 14, *)
public struct POCardScannerView: View {

    init(viewModel: some CardScannerViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel))
    }

    public var body: some View {
        VStack(spacing: POSpacing.medium) {
            Text(viewModel.title)
                .textStyle(style.title)
            POHorizontalSizeReader { width in
                POCameraPreviewView(session: viewModel.captureSession)
                    .frame(width: width, height: width / 1.586) // ISO/IEC 7810 based Aspect Ratio
            }
        }
        .padding(.vertical, POSpacing.medium)
        .padding(.horizontal, POSpacing.large)
        .background(style.backgroundColor.ignoresSafeArea())
    }

    // MARK: - Private Properties

    @Environment(\.cardScannerStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardScannerViewModel
}
