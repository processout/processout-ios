//
//  DynamicCheckoutViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI
import ProcessOut

enum DynamicCheckoutViewModelItem {

    struct PassKitPayment {

        /// Id.
        let id: String

        /// Action handler.
        let action: () -> Void
    }

    struct ExpressPayment: Identifiable {

        /// Item id.
        let id: String

        /// Item title.
        let title: String

        /// Payment icon image
        let iconImageResource: POImageRemoteResource

        /// Brand color.
        let brandColor: UIColor

        /// Action handler.
        let action: () -> Void
    }

    struct Payment: Identifiable, Equatable {

        /// Item identifier.
        let id: String

        /// Payment icon image
        let iconImageResource: POImageRemoteResource

        /// Brand color.
        let brandColor: UIColor

        /// Item title.
        let title: String

        /// Indicates whether loading indicator should be visible.
        let isLoading: Bool

        /// Defines whether item is currently selected.
        @Binding
        var isSelected: Bool

        /// Payment details.
        let additionalInformation: String?
    }

    struct AlternativePayment: Equatable {

        /// Gateway configuration id that should be used to initiate native alternative payment.
        let gatewayConfigurationId: String
    }

    // swiftlint:disable:next line_length
    case progress, passKitPayment(PassKitPayment), expressPayment(ExpressPayment), payment(Payment), card, alternativePayment(AlternativePayment)
}

extension DynamicCheckoutViewModelItem: Identifiable {

    var id: AnyHashable {
        switch self {
        case .progress:
            return Constants.progressId
        case .passKitPayment(let item):
            return item.id
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
