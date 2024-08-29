//
//  ConfigurationScannerView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 27.08.2024.
//

import SwiftUI

@MainActor
struct ConfigurationScannerView: View {

    let didRecognizeCode: (String) -> Void

    // MARK: - View

    var body: some View {
        VStack {
            Text(.ConfigurationScanner.title)
                .font(.title)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
            BarcodeScannerView(shouldStartScanning: $shouldStartScanning, recognizedCode: $recognizedCode)
                .onAppear {
                    shouldStartScanning = true
                }
                .onDisappear {
                    shouldStartScanning = false
                }
                .onChange(of: recognizedCode) {
                    if let code = recognizedCode {
                        didRecognizeCode(code)
                        shouldStartScanning = false
                        dismiss()
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1.586, contentMode: .fit)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }

    // MARK: - Private Properties

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var shouldStartScanning = false

    @State
    private var recognizedCode: String?
}
