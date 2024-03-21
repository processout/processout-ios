//
//  DynamicCheckoutViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI

enum DynamicCheckoutViewModelItem {

    struct ExpressPayment: Identifiable {

        /// Item id.
        let id: String

        /// Item title.
        let title: String?

        /// Payment icon image
        let iconImage: UIImage?

        /// Brand color.
        let brandColor: Color

        /// Boolean value indicating whether button should display loading indicator.
        let isLoading: Bool

        /// Action handler.
        let action: () -> Void
    }

    struct Payment: Identifiable, Hashable {

        /// Item identifier.
        let id: String

        // Payment icon image
        let iconImage: UIImage?

        /// Item title.
        let title: String

        /// Defines whether item is currently selected.
        var isSelected: Binding<Bool>

        /// Payment details.
        let additionalInformation: String?
    }

    struct AlternativePayment: Hashable {

        /// Gateway configuration id that should be used to initiate native alternative payment.
        let gatewayConfigurationId: String
    }

    case progress, expressPayment(ExpressPayment), payment(Payment), card, alternativePayment(AlternativePayment)
}

extension DynamicCheckoutViewModelItem: Identifiable {

    var id: AnyHashable {
        switch self {
        case .progress:
            return Constants.progressId
        case .expressPayment(let item):
            return item.id
        case .payment(let item):
            return item.id
        case .card:
            return Constants.cardId
        case .alternativePayment(let item):
            return item.gatewayConfigurationId
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let cardId = UUID().uuidString
        static let progressId = UUID().uuidString
    }
}
