//
//  POToolbar.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.12.2024.
//

import SwiftUI

/// Simplified toolbar view.
@_spi(PO)
public struct POToolbar<Leading: View, Principal: View, Trailing: View>: View {

    public init(
        alignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder principal: @escaping () -> Principal,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.leading = leading
        self.principal = principal
        self.trailing = trailing
    }

    // MARK: - View

    public var body: some View {
        ZStack(alignment: .init(horizontal: .center, vertical: alignment)) {
            HStack(alignment: alignment, spacing: spacing) {
                leading()
                    .onSizeChange { size in
                        leadingSize = size
                    }
                Spacer()
                trailing()
                    .onSizeChange { size in
                        trailingSize = size
                    }
            }
            principal()
                .padding(.horizontal, max(leadingSize?.width ?? 0, trailingSize?.width ?? 0))
        }
    }

    // MARK: - Private Properties

    private let alignment: VerticalAlignment
    private let spacing: CGFloat?

    private let leading: () -> Leading
    private let principal: () -> Principal
    private let trailing: () -> Trailing

    @State private var leadingSize: CGSize?
    @State private var trailingSize: CGSize?
}
