//
//  CardUpdateViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 07.11.2023.
//

import Foundation
import SwiftUI

enum CardUpdateViewModelItem {

    typealias Input = InputViewModel

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
