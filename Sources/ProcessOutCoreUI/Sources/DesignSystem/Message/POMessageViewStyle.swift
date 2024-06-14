//
//  POMessageViewStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

public protocol POMessageViewStyle {

    /// A view that represents the body of a message.
    associatedtype Body: View

    /// Creates a view that represents the body of a message.
    ///
    /// - Parameter configuration : The properties of the message.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// Style configuration.
    typealias Configuration = POMessageViewStyleConfiguration
}
