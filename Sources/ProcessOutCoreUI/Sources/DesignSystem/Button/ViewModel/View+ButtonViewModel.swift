//
//  View+ButtonViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

import SwiftUI

extension Button where Label == AnyView {

    @_spi(PO)
    @MainActor
    public static func create(with viewModel: POButtonViewModel) -> some View {
        ButtonWrapper(viewModel: viewModel)
    }
}

@MainActor
private struct ButtonWrapper: View {

    let viewModel: POButtonViewModel

    // MARK: - View

    var body: some View {
        Button(action: action, label: { buttonLabel })
            .accessibility(identifier: viewModel.id)
            .disabled(!viewModel.isEnabled)
            .buttonLoading(viewModel.isLoading)
            .poButtonRole(viewModel.role)
            .poConfirmationDialog(item: $confirmationDialog)
    }

    // MARK: - Private Properties

    @State
    private var confirmationDialog: POConfirmationDialog?

    // MARK: - Private Methods

    private var buttonLabel: Label<some View, some View> {
        Label {
            if let title = viewModel.title {
                Text(title)
            }
        } icon: {
            viewModel.icon
        }
    }

    private func action() {
        if let confirmation = viewModel.confirmation {
            confirmation.onAppear?()
            confirmationDialog = .init(
                title: confirmation.title,
                message: confirmation.message,
                primaryButton: .init(
                    title: confirmation.confirmButtonTitle, action: viewModel.action
                ),
                secondaryButton: .init(title: confirmation.cancelButtonTitle, role: .cancel)
            )
        } else {
            viewModel.action()
        }
    }
}
