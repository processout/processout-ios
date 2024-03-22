//
//  PODynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

import SwiftUI

@available(iOS 14, *)
public struct PODynamicCheckoutView: View {

    public init(configuration: PODynamicCheckoutConfiguration, delegate: PODynamicCheckoutDelegate) {
        self.configuration = configuration
        self.delegate = delegate
    }

    // MARK: - View

    public var body: some View {
        // todo(andrii-vysotskyi): ensure that view model is created only once, see https://stackoverflow.com/questions/62635914/initialize-stateobject-with-a-parameter-in-swiftui
        let viewModel = DefaultDynamicCheckoutViewModel()
        let router = DefaultDynamicCheckoutRouter(configuration: configuration)
        DynamicCheckoutView(viewModel: viewModel, router: router)
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutConfiguration
    private weak var delegate: PODynamicCheckoutDelegate?
}
