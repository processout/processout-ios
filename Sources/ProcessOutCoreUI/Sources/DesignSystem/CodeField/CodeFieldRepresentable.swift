//
//  CodeFieldRepresentable.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

struct CodeFieldRepresentable: UIViewRepresentable {

    let length: Int

    @Binding
    var text: String

    @Binding
    var textIndex: String.Index?

    @Binding
    var isMenuVisible: Bool

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> CodeFieldView {
        let codeField = CodeFieldView(coordinator: context.coordinator)
        focusCoordinator?.track(control: codeField)
        return codeField
    }

    func updateUIView(_ uiView: CodeFieldView, context: Context) {
        // Since coordinator is referencing `representable` which is a struct. New instance should be injected every
        // time runtime asks us to update uiView.
        context.coordinator.representable = self
        updateFirstResponder(uiView: uiView)
        updateMenu(uiView: uiView)
    }

    func makeCoordinator() -> CodeFieldViewCoordinator {
        CodeFieldViewCoordinator()
    }

    // MARK: - Private Properties

    @Environment(\.focusCoordinator)
    private var focusCoordinator

    // MARK: - Private Methods

    private func updateFirstResponder(uiView: CodeFieldView) {
        if textIndex == nil {
            uiView.resignFirstResponder()
        } else {
            uiView.becomeFirstResponder()
        }
    }

    private func updateMenu(uiView: CodeFieldView) {
        if isMenuVisible, uiView.isFirstResponder {
            let controller = UIMenuController.shared
            controller.showMenu(from: uiView, rect: uiView.bounds)
        } else {
            UIMenuController.shared.hideMenu(from: uiView)
        }
    }
}
