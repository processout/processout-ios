//
//  View+ConfirmationDialog.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.05.2024.
//

import SwiftUI

extension View {

    @_spi(PO)
    public func poConfirmationDialog(item: Binding<POConfirmationDialog?>) -> some View {
        modifier(ContentModifier(confirmationDialog: item))
    }
}

@MainActor
private struct ContentModifier: ViewModifier {

    @Binding
    private(set) var confirmationDialog: POConfirmationDialog?

    func body(content: Content) -> some View {
        content
            .backport.onChange(of: isPresented) {
                if !isPresented {
                    confirmationDialog = nil
                }
            }
            .backport.onChange(of: confirmationDialog != nil) {
                isPresented = confirmationDialog != nil
                confirmationDialogSnapshot = confirmationDialog
            }
            .overlay(
                // When an alert defined at multiple levels in the view hierarchy, only the
                // higher-level alert will be shown. Workaround is to present alert from an overlay.
                Color.clear.alert(isPresented: $isPresented) { confirmationAlert }
            )
    }

    // MARK: - Private Properties

    @State
    private var isPresented = false

    @State
    private var confirmationDialogSnapshot: POConfirmationDialog?

    private var confirmationAlert: Alert {
        guard let dialog = confirmationDialogSnapshot else {
            preconditionFailure("Confirmation dialog must be set.")
        }
        let alert: Alert
        if let secondaryButton = dialog.secondaryButton {
            alert = Alert(
                title: Text(dialog.title),
                message: dialog.message.map(Text.init),
                primaryButton: createAlertButton(with: dialog.primaryButton),
                secondaryButton: createAlertButton(with: secondaryButton)
            )
        } else {
            alert = Alert(
                title: Text(dialog.title),
                message: dialog.message.map(Text.init),
                dismissButton: createAlertButton(with: dialog.primaryButton)
            )
        }
        return alert
    }

    // MARK: - Private Methods

    private func createAlertButton(with button: POConfirmationDialog.Button) -> Alert.Button {
        let createButton = switch button.role {
        case nil:
            Alert.Button.default
        case .cancel:
            Alert.Button.cancel(_:action:)
        case .destructive:
            Alert.Button.destructive
        }
        let action = {
            confirmationDialog = nil
            button.action?()
        }
        return createButton(Text(button.title), action)
    }
}
