//
//  Backport+ControlSize.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI

extension POBackport where Wrapped: View {

    /// Sets the size for controls within this view.
    @available(iOS, deprecated: 15, message: "Use View/controlSize(_:) directly.")
    @_spi(PO)
    @ViewBuilder
    public func poControlSize(_ controlSize: POControlSize) -> some View {
        if #available(iOS 15, *) {
            wrapped
                .environment(\.poControlSize, controlSize)
                .controlSize(.init(poControlSize: controlSize))
        } else {
            wrapped.environment(\.poControlSize, controlSize)
        }
    }
}

extension EnvironmentValues {

    /// The size to apply to controls within a view.
    ///
    /// The default is ``POControlSize/regular``.
    @available(iOS, deprecated: 15, message: "Use View/controlSize directly.")
    public internal(set) var poControlSize: POControlSize {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue = POControlSize.regular
    }
}

@available(iOS 15, *)
extension ControlSize {

    fileprivate init(poControlSize size: POControlSize) { // swiftlint:disable:this strict_fileprivate
        switch size {
        case .regular:
            self = .regular
        case .small:
            self = .small
        }
    }
}
