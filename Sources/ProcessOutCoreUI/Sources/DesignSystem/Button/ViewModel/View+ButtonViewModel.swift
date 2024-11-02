//
//  View+ButtonViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

import SwiftUI

extension Button where Label == AnyView {

    @_spi(PO)
    @available(iOS 14, *)
    public static func create(with viewModel: POButtonViewModel) -> some View {
        ButtonWrapper(viewModel: viewModel)
    }
}

@available(iOS 14, *)
private struct ButtonWrapper: View {

    let viewModel: POButtonViewModel

    // MARK: - View

    var body: some View {
        Button(viewModel.title, action: action)
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

    private func action() {
        if let confirmation = viewModel.confirmation {
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
