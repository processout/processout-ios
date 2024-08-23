//
//  FeaturesView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 22.08.2024.
//

import SwiftUI

struct FeaturesView: View {

    var body: some View {
        FeaturesViewRepresentable()
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(String(localized: .Features.title))
    }
}

private struct FeaturesViewRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        FeaturesBuilder().build()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Ignored
    }
}
