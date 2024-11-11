//
//  POCardUpdateConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import SwiftUI

/// A configuration object that defines how a card update module behaves.
/// Use `nil` as a value for a nullable property to indicate that default value should be used.
@MainActor
@preconcurrency
public struct POCardUpdateConfiguration: Sendable {

    /// Text field configuration.
    @MainActor
    @preconcurrency
    public struct TextField: Sendable {

        /// Text providing users with guidance on what to type into the text field.
        public let prompt: String?

        /// Text field icon.
        public let icon: AnyView?

        public init<Icon: View>(prompt: String? = nil, icon: Icon? = AnyView?.none) {
            self.prompt = prompt
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Button configuration.
    @MainActor
    @preconcurrency
    public struct SubmitButton: Sendable {

        /// Button title, such as "Pay". Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` to use default value.
        public let icon: AnyView?

        public init<Icon: View>(title: String? = nil, icon: Icon? = AnyView?.none) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
        }
    }

    /// Cancel button configuration.
    @MainActor
    @preconcurrency
    public struct CancelButton: Sendable {

        /// Button title. Pass `nil` title to use default value.
        public let title: String?

        /// Button icon. Pass `nil` title to use default value.
        public let icon: AnyView?

        /// When property is set implementation asks user to confirm cancel.
        public let confirmation: POConfirmationDialogConfiguration?

        /// Creates cancel button configuration.
        public init<Icon: View>(
            title: String? = nil, icon: Icon? = AnyView?.none, confirmation: POConfirmationDialogConfiguration? = nil
        ) {
            self.title = title
            self.icon = icon.map(AnyView.init(erasing:))
            self.confirmation = confirmation
        }
    }

    /// Card id that needs to be updated.
    public let cardId: String

    /// Allows to provide card information that will be visible in UI. It is also possible to inject
    /// it dynamically using ``POCardUpdateDelegate/cardInformation(cardId:)``.
    public let cardInformation: POCardUpdateInformation?

    /// Custom title. Use empty string to hide title.
    public let title: String?

    /// Configuration for the CVC text field.
    public let cvc: TextField

    /// Boolean flag determines whether user will be asked to select scheme if co-scheme is available.
    @_spi(PO)
    public var isSchemeSelectionAllowed: Bool = false

    /// Submit button configuration.
    public let submitButton: SubmitButton

    /// Cancel button configuration.
    public let cancelButton: CancelButton?

    public init(
        cardId: String,
        cardInformation: POCardUpdateInformation? = nil,
        title: String? = nil,
        cvc: TextField = .init(),
        submitButton: SubmitButton = .init(),
        cancelButton: CancelButton? = .init()
    ) {
        self.cardId = cardId
        self.cardInformation = cardInformation
        self.title = title
        self.cvc = cvc
        self.submitButton = submitButton
        self.cancelButton = cancelButton
    }
}

extension POCardUpdateConfiguration {

    /// Primary action text, such as "Submit".
    @available(*, deprecated, renamed: "submitButton.title")
    public var primaryActionTitle: String? {
        submitButton.title
    }

    /// Primary action text, such as "Cancel". Use empty string to hide button.
    @available(*, deprecated, renamed: "cancelButton.title")
    public var cancelActionTitle: String? {
        cancelButton == nil ? "" : cancelButton?.title
    }

    @available(*, deprecated)
    @_disfavoredOverload
    public init(
        cardId: String,
        cardInformation: POCardUpdateInformation? = nil,
        title: String? = nil,
        primaryActionTitle: String? = nil,
        cancelActionTitle: String? = nil
    ) {
        self.cardId = cardId
        self.cardInformation = cardInformation
        self.title = title
        self.cvc = .init()
        self.submitButton = .init(title: primaryActionTitle)
        self.cancelButton = cancelActionTitle?.isEmpty == true ? nil : .init(title: cancelActionTitle)
    }
}
