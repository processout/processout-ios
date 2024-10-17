//
//  View+ReturnKeyType.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 25.09.2023.
//

import SwiftUI

extension POBackport where Wrapped == Any {

    /// A semantic label describing the label of submission within a view hierarchy.
    public struct SubmitLabel: Equatable, Sendable {

        let returnKeyType: UIReturnKeyType

        init(_ type: UIReturnKeyType) {
            returnKeyType = type
        }

        // MARK: -

        /// Defines a submit label with text of "Done".
        public static let `default` = Self(.default)

        /// Defines a submit label with text of "Done".
        public static let done = Self(.done)

        /// Defines a submit label with text of "Next".
        public static let next = Self(.next)

        /// Defines a submit label with text of "Search".
        public static let search = Self(.search)
    }
}

extension POBackport where Wrapped: View {

    /// A semantic label describing the label of submission within a view hierarchy.
    @ViewBuilder
    public func submitLabel(_ label: POBackport<Any>.SubmitLabel) -> some View {
        Group {
            if #available(iOS 15, *) {
                wrapped.submitLabel(submitLabel(from: label))
            } else {
                wrapped
            }
        }
        .environment(\.backportSubmitLabel, label)
    }

    // MARK: - Private Methods

    @available(iOS 15, *)
    private func submitLabel(from label: POBackport<Any>.SubmitLabel) -> SwiftUI.SubmitLabel {
        switch label {
        case .next:
            return .next
        case .search:
            return .search
        default:
            return .done
        }
    }
}

extension EnvironmentValues {

    /// Submit label.
    @Entry
    var backportSubmitLabel = POBackport.SubmitLabel.default
}
