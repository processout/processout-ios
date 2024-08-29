//
//  BarcodeScannerView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 27.08.2024.
//

// swiftlint:disable strict_fileprivate

import VisionKit
import Vision
import SwiftUI

@MainActor
struct BarcodeScannerView: UIViewControllerRepresentable {

    init(shouldStartScanning: Binding<Bool>, recognizedCode: Binding<String?>) {
        self._shouldStartScanning = shouldStartScanning
        self._recognizedCode = recognizedCode
    }

    // MARK: - UIViewControllerRepresentable

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let symbologies: [VNBarcodeSymbology] = [
            .aztec, .dataMatrix, .pdf417, .qr
        ]
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: symbologies)],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if shouldStartScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
        context.coordinator.view = self
    }

    func makeCoordinator() -> ViewControllerCoordinator {
        ViewControllerCoordinator(view: self)
    }

    // MARK: - Private Properties

    @Binding
    fileprivate var shouldStartScanning: Bool

    @Binding
    fileprivate var recognizedCode: String?
}

final class ViewControllerCoordinator: DataScannerViewControllerDelegate {

    init(view: BarcodeScannerView) {
        self.view = view
    }

    var view: BarcodeScannerView

    // MARK: - DataScannerViewControllerDelegate

    func dataScanner(_: DataScannerViewController, didAdd _: [RecognizedItem], allItems: [RecognizedItem]) {
       recognizedItemsDidChange(allItems)
    }

    func dataScanner(_: DataScannerViewController, didUpdate _: [RecognizedItem], allItems: [RecognizedItem]) {
        recognizedItemsDidChange(allItems)
    }

    func dataScanner(_: DataScannerViewController, didRemove _: [RecognizedItem], allItems: [RecognizedItem]) {
        recognizedItemsDidChange(allItems)
    }

    // MARK: - Private Methods

    private func recognizedItemsDidChange(_ items: [RecognizedItem]) {
        switch items.first {
        case .barcode(let barcode):
            if let value = barcode.payloadStringValue {
                view.recognizedCode = value
            } else {
                view.recognizedCode = nil
            }
        default:
            view.recognizedCode = nil
        }
    }
}

// swiftlint:enable strict_fileprivate
