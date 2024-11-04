//
//  CardUpdateViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import Foundation
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

enum CardUpdateViewModelItem {

    typealias Input = POTextFieldViewModel

    struct Picker: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Available options.
        let options: [PickerOption]

        /// Currently selected option id.
        @Binding var selectedOptionId: String?

        /// Boolean flag indicating whether inline style is preferred.
        let preferrsInline: Bool
    }

    struct PickerOption: Identifiable {

        /// Option id.
        let id: String

        /// Option title.
        let title: String
    }

    struct Error: Identifiable {

        /// Item identifier.
        let id: AnyHashable

        /// Error description.
        let description: String
    }

    case input(Input), picker(Picker), error(Error), progress
}

extension CardUpdateViewModelItem: Identifiable {

    var id: AnyHashable {
        switch self {
        case .input(let item):
            return item.id
        case .picker(let item):
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
