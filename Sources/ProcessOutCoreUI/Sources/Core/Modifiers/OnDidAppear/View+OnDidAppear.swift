//
//  View+OnDidAppear.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.10.2023.
//

import SwiftUI

extension View {

    /// Adds an action to perform after this view appears.
    @MainActor
    func onDidAppear(perform action: @escaping () -> Void) -> some View {
        background(ViewControllerRepresentable(onDidAppear: action))
    }
}

private final class ViewController: UIViewController {

    init(onDidAppear: @escaping () -> Void) {
        self.onDidAppear = onDidAppear
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var onDidAppear: () -> Void

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onDidAppear()
    }
}

@MainActor
private struct ViewControllerRepresentable: UIViewControllerRepresentable {

    let onDidAppear: () -> Void

    func makeUIViewController(context: Context) -> ViewController {
        ViewController(onDidAppear: onDidAppear)
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        uiViewController.onDidAppear = onDidAppear
    }
}
