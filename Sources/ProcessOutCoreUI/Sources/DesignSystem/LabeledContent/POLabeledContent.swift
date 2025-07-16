//
//  POLabeledContent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

/// A container for attaching a label to a value-bearing view.
///
/// The instance's content represents a read-only or read-write value, and its
/// label identifies or describes the purpose of that value.
@_spi(PO)
public struct POLabeledContent<Label: View, Content: View>: View {

    /// Creates a standard labeled element, with a view that conveys
    /// the value of the element and a label.
    public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        configuration = .init(label: label, content: content)
    }

    // MARK: - View

    public var body: some View {
        AnyView(style.makeBody(configuration: configuration))
    }

    // MARK: - Private Properties

    private let configuration: POLabeledContentStyleConfiguration

    @Environment(\.poLabeledContentStyle)
    private var style
}
