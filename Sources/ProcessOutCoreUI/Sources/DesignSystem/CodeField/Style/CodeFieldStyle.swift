//
//  CodeFieldStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

@MainActor
protocol CodeFieldStyle: Sendable {

    /// A view that represents the body of a button.
    associatedtype Body: View

    /// Creates a view that represents the body of a code field.
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> Self.Body

    /// The properties of a button.
    typealias Configuration = CodeFieldStyleConfiguration
}
