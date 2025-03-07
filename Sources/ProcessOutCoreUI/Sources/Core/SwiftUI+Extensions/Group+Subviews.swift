//
//  Group+Subviews.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI

extension Group {

    /// Constructs a group from the subviews of the given view.
    @_spi(PO)
    @MainActor
    public init<Base: View, Result: View>(
        poSubviews view: Base,
        @ViewBuilder transform: @escaping (_VariadicView.Children) -> Result
    ) where Content == POSubviewsTransformView<Base, Result> {
        self.init { POSubviewsTransformView(subviews: view, transform: transform) }
    }
}

@_spi(PO)
@MainActor
@frozen
public struct POSubviewsTransformView<Subviews: View, Content: View>: View {

    @inlinable
    init(subviews: Subviews, @ViewBuilder transform: @escaping (_VariadicView.Children) -> Content) {
        tree = .init(.init(transform: transform)) { subviews }
    }

    // MARK: - View

    @inlinable
    public var body: some View {
        tree
    }

    // MARK: - Private Properties

    @usableFromInline
    let tree: _VariadicView.Tree<POSubviewsTransformViewRoot<Content>, Subviews>
}

@_spi(PO)
@MainActor
@frozen
public struct POSubviewsTransformViewRoot<Content: View>: _VariadicView_MultiViewRoot {

    @inlinable
    init(transform: @escaping (_VariadicView.Children) -> Content) {
        self.transform = transform
    }

    // MARK: - _VariadicView_MultiViewRoot

    @inlinable
    public func body(children: _VariadicView.Children) -> Content {
        transform(children)
    }

    // MARK: - Private Properties

    @usableFromInline
    let transform: (_ children: _VariadicView.Children) -> Content
}
