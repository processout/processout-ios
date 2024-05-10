//
//  DynamicCheckoutViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI
import PassKit
import ProcessOut

enum DynamicCheckoutViewModelItem {

    struct PassKitPayment: Identifiable {

        /// Id.
        let id: String

        /// Payment button type.
        let buttonType: PKPaymentButtonType

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

    struct PaymentInfo: Identifiable, Equatable {

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

    struct AlternativePayment: Identifiable {

        /// Alternative payment item ID.
        let id: AnyHashable

        /// Creates alternative payment view model.
        let viewModel: () -> AnyNativeAlternativePaymentViewModel
    }

    struct Card: Identifiable {

        /// Card item ID.
        let id: AnyHashable

        /// Creates card tokenization view model.
        let viewModel: () -> AnyCardTokenizationViewModel
    }

    struct Success: Identifiable {

        /// Item ID.
        let id: AnyHashable

        /// Success message.
        let message: String

        /// Decoration image.
        let image: UIImage?
    }

    /// Progress item.
    case progress

    /// PassKit button item.
    case passKitPayment(PassKitPayment)

    /// Express payment button item.
    case expressPayment(ExpressPayment)

    /// Regular payment item info.
    case payment(PaymentInfo)

    /// Card collection item.
    case card(Card)

    /// Native alternative payment collection item.
    case alternativePayment(AlternativePayment)

    /// Success item.
    case success(Success)
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
        case .card(let item):
            return item.id
        case .alternativePayment(let item):
            return item.id
        case .success(let item):
            return item.id
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let progressId = UUID().uuidString
    }
}
