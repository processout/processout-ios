//
//  View+ButtonViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2024.
//

import SwiftUI

extension View {

    /// Configures a button view using provided view model.
    ///
    /// - Parameters:
    ///   - viewModel: The view model containing button properties.
    ///   - styleProvider: An object that provides the button style based on the role.
    @_spi(PO)
    @ViewBuilder
    public func buttonViewModel(_ viewModel: POButtonViewModel) -> some View {
        self
            .disabled(!viewModel.isEnabled)
            .buttonLoading(viewModel.isLoading)
            .poButtonRole(viewModel.role)
            .accessibility(identifier: viewModel.id)
    }
}
