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
public struct POSubviewsTransformView<Subviews: View, Content: View>: View {

    init(subviews: Subviews, @ViewBuilder transform: @escaping (_VariadicView.Children) -> Content) {
        tree = .init(.init(transform: transform)) { subviews }
    }

    // MARK: - View

    public var body: some View {
        tree
    }

    // MARK: - Private Properties

    @usableFromInline
    let tree: _VariadicView.Tree<SubviewsTransformViewRoot<Content>, Subviews>
}

@MainActor
@usableFromInline
struct SubviewsTransformViewRoot<Content: View>: _VariadicView_MultiViewRoot {

    @inlinable
    init(transform: @escaping (_VariadicView.Children) -> Content) {
        self.transform = transform
    }

    // MARK: - _VariadicView_MultiViewRoot

    @usableFromInline
    func body(children: _VariadicView.Children) -> Content {
        transform(children)
    }

    // MARK: - Private Properties

    @usableFromInline
    let transform: (_ children: _VariadicView.Children) -> Content
}
