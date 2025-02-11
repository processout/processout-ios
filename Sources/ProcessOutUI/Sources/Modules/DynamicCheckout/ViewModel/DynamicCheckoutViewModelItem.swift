//
//  DynamicCheckoutViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI
import PassKit
import ProcessOut
@_spi(PO) import ProcessOutCoreUI

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

        /// Indicates whether button is loading.
        let isLoading: Bool

        /// Action handler.
        let action: () -> Void
    }

    struct RegularPayment {

        /// Payment ID.
        let id: String

        /// Payment info.
        let info: RegularPaymentInfo

        /// Payment content.
        let content: RegularPaymentContent?

        /// Submits payment information.
        let submitButton: POButtonViewModel?
    }

    struct RegularPaymentInfo {

        /// Payment icon image
        let iconImageResource: POImageRemoteResource

        /// Item title.
        let title: String

        /// Indicates whether loading indicator should be visible.
        let isLoading: Bool

        /// Defines whether item is currently selected.
        @Binding
        var isSelected: Bool

        /// Defines whether method should be saved.
        var shouldSave: Binding<Bool>?

        /// Payment details.
        let additionalInformation: String?
    }

    enum RegularPaymentContent {

        /// Card payment content.
        case card(Card)

        /// Native alternative payment content.
        case alternativePayment(AlternativePayment)
    }

    struct AlternativePayment: Identifiable {

        /// Content ID.
        let id: AnyHashable

        /// Creates alternative payment view model.
        let viewModel: () -> AnyViewModel<NativeAlternativePaymentViewModelState>
    }

    struct Card: Identifiable {

        /// Content ID.
        let id: AnyHashable

        /// Creates card tokenization view model.
        let viewModel: () -> AnyViewModel<CardTokenizationViewModelState>
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
    case regularPayment(RegularPayment)

    /// Info message.
    case message(POMessage)

    /// Success item.
    case success(Success)
}

extension DynamicCheckoutViewModelItem: Identifiable, AnimationIdentityProvider {

    var id: AnyHashable {
        switch self {
        case .progress:
            return Constants.progressId
        case .passKitPayment(let item):
            return item.id
        case .expressPayment(let item):
            return item.id
        case .regularPayment(let item):
            return item.id
        case .message(let item):
            return item.id
        case .success(let item):
            return item.id
        }
    }

    var animationIdentity: AnyHashable {
        switch self {
        case .regularPayment(let item):
            return [
                item.id,
                AnyHashable(item.content == nil),
                item.info.additionalInformation == nil,
                item.info.shouldSave == nil,
                item.submitButton?.id
            ]
        default:
            return self.id
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let progressId = UUID().uuidString
    }
}
