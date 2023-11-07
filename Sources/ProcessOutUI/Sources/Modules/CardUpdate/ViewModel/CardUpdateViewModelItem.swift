//
//  CardUpdateViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import Foundation
import SwiftUI

enum CardUpdateViewModelItem {

    struct Input: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Current parameter's value text.
        @Binding var value: String

        /// Parameter's placeholder.
        let placeholder: String

        /// Boolean value indicating whether value is valid.
        let isInvalid: Bool

        /// Boolean value indicating whether input is currently enabled.
        let isEnabled: Bool

        /// Input icon.
        let icon: Image?

        /// Action to perform when the user submits a value to this input.
        let onSubmit: () -> Void
    }

    struct Error: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Error description.
        let description: String
    }

    case input(Input), error(Error), progress
}

extension CardUpdateViewModelItem: Identifiable {

    var id: AnyHashable {
        switch self {
        case .input(let item):
            return item.id
        case .error(let item):
            return item.id
        case .progress:
            return Constants.progressId
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let progressId = UUID().uuidString
    }
}
