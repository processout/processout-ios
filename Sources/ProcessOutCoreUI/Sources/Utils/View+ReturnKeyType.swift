//
//  View+ReturnKeyType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.09.2023.
//

import SwiftUI

extension View {

    /// A semantic label describing the label of submission within a view hierarchy.
    @ViewBuilder
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> some View {
        Group {
            if #available(iOS 15, *) {
                submitLabel(submitLabel(from: returnKeyType))
            } else {
                self
            }
        }
        .environment(\.returnKeyType, returnKeyType)
    }

    // MARK: - Private Methods

    @available(iOS 15, *)
    private func submitLabel(from returnKeyType: UIReturnKeyType) -> SubmitLabel {
        switch returnKeyType {
        case .go:
            return .go
        case .join:
            return .join
        case .next:
            return .next
        case .route:
            return .route
        case .search:
            return .search
        case .send:
            return .send
        case .done:
            return .done
        case .continue:
            return .continue
        default:
            return .return
        }
    }
}

extension EnvironmentValues {

    var returnKeyType: UIReturnKeyType {
        get { self[LabelKey.self] }
        set { self[LabelKey.self] = newValue }
    }

    // MARK: - Private Properties

    private struct LabelKey: EnvironmentKey {
        static var defaultValue = UIReturnKeyType.default
    }
}
