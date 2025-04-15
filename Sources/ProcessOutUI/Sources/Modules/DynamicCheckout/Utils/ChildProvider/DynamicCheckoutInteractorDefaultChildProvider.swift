//
//  DynamicCheckoutInteractorDefaultChildProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

import Foundation
@_spi(PO) import ProcessOut

@MainActor
final class DynamicCheckoutInteractorDefaultChildProvider: DynamicCheckoutInteractorChildProvider {

    nonisolated init(
        configuration: PODynamicCheckoutConfiguration,
        cardsService: POCardsService,
        invoicesService: POInvoicesService,
        imagesRepository: POImagesRepository,
        logger: POLogger
    ) {
        self.configuration = configuration
        self.cardsService = cardsService
        self.invoicesService = invoicesService
        self.imagesRepository = imagesRepository
        self.logger = logger
    }

    // MARK: - DynamicCheckoutInteractorChildProvider

    func cardTokenizationInteractor(
        invoiceId: String, configuration: PODynamicCheckoutPaymentMethod.CardConfiguration
    ) -> any CardTokenizationInteractor {
        var logger = logger
        logger[attributeKey: .invoiceId] = invoiceId
        let interactor = DefaultCardTokenizationInteractor(
            cardsService: cardsService,
            logger: logger,
            configuration: cardTokenizationConfiguration(with: configuration),
            completion: { _ in }
        )
        return interactor
    }

    func nativeAlternativePaymentInteractor(
        invoiceId: String,
        gatewayConfigurationId: String,
        configuration: PODynamicCheckoutAlternativePaymentConfiguration
    ) -> any NativeAlternativePaymentInteractor {
        var logger = self.logger
        logger[attributeKey: .invoiceId] = invoiceId
        logger[attributeKey: .gatewayConfigurationId] = gatewayConfigurationId
        let interactor = NativeAlternativePaymentDefaultInteractor(
            configuration: alternativePaymentConfiguration(
                invoiceId: invoiceId,
                gatewayConfigurationId: gatewayConfigurationId,
                configuration: configuration
            ),
            invoicesService: invoicesService,
            imagesRepository: imagesRepository,
            barcodeImageProvider: DefaultBarcodeImageProvider(logger: logger),
            logger: logger,
            completion: { _ in }
        )
        return interactor
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutConfiguration
    private let cardsService: POCardsService
    private let invoicesService: POInvoicesService
    private let imagesRepository: POImagesRepository
    private let logger: POLogger

    // MARK: - Card Tokenization Configuration

    private func cardTokenizationConfiguration(
        with methodConfiguration: PODynamicCheckoutPaymentMethod.CardConfiguration
    ) -> POCardTokenizationConfiguration {
        POCardTokenizationConfiguration(
            title: "",
            cardholderName: methodConfiguration.cardholderNameRequired
                ? textFieldConfiguration(with: configuration.card.cardholderName) : nil,
            cardNumber: textFieldConfiguration(with: configuration.card.cardNumber),
            expirationDate: textFieldConfiguration(with: configuration.card.expirationDate),
            cvc: methodConfiguration.cvcRequired ? textFieldConfiguration(with: configuration.card.cvc) : nil,
            preferredScheme: .init(
                schemeSelectionAllowed: methodConfiguration.schemeSelectionAllowed,
                configuration: configuration.card.preferredScheme
            ),
            cardScanner: configuration.card.cardScanner.map(POCardTokenizationConfiguration.CardScanner.init),
            billingAddress: billingAddressConfiguration(with: methodConfiguration),
            isSavingAllowed: methodConfiguration.savingAllowed,
            submitButton: submitButtonConfiguration(with: configuration.submitButton),
            cancelButton: configuration.cancelButton.map { cancelButtonConfiguration(with: $0) },
            metadata: configuration.card.metadata
        )
    }

    private func billingAddressConfiguration(
        with methodConfiguration: PODynamicCheckoutPaymentMethod.CardConfiguration
    ) -> POCardTokenizationConfiguration.BillingAddress {
        POCardTokenizationConfiguration.BillingAddress(
            mode: methodConfiguration.billingAddress.collectionMode,
            countryCodes: methodConfiguration.billingAddress.restrictToCountryCodes,
            defaultAddress: configuration.card.billingAddress.defaultAddress,
            attachDefaultsToPaymentMethod: configuration.card.billingAddress.attachDefaultsToPaymentMethod
        )
    }

    private func textFieldConfiguration(
        with configuration: PODynamicCheckoutCardConfiguration.TextField
    ) -> POCardTokenizationConfiguration.TextField {
        .init(prompt: configuration.prompt, icon: configuration.icon)
    }

    private func submitButtonConfiguration(
        with configuration: PODynamicCheckoutConfiguration.SubmitButton
    ) -> POCardTokenizationConfiguration.SubmitButton {
        .init(title: configuration.title ?? String(resource: .DynamicCheckout.Button.pay), icon: configuration.icon)
    }

    private func cancelButtonConfiguration(
        with configuration: PODynamicCheckoutConfiguration.CancelButton
    ) -> POCardTokenizationConfiguration.CancelButton {
        .init(title: configuration.title, icon: configuration.icon, confirmation: configuration.confirmation)
    }

    // MARK: - Alternative Payment Configuration

    private func alternativePaymentConfiguration(
        invoiceId: String,
        gatewayConfigurationId: String,
        configuration: PODynamicCheckoutAlternativePaymentConfiguration
    ) -> PONativeAlternativePaymentConfiguration {
        let childConfiguration = PONativeAlternativePaymentConfiguration(
            invoiceId: invoiceId,
            gatewayConfigurationId: gatewayConfigurationId,
            title: "",
            shouldHorizontallyCenterCodeInput: false,
            inlineSingleSelectValuesLimit: configuration.inlineSingleSelectValuesLimit,
            barcodeInteraction: .init(configuration: configuration.barcodeInteraction),
            submitButton: .init(
                title: self.configuration.submitButton.title ?? String(resource: .DynamicCheckout.Button.pay),
                icon: self.configuration.submitButton.icon
            ),
            cancelButton: self.configuration.cancelButton.map(
                PONativeAlternativePaymentConfiguration.CancelButton.init
            ),
            paymentConfirmation: .init(configuration: configuration.paymentConfirmation),
            success: nil
        )
        return childConfiguration
    }
}

// swiftlint:disable no_extension_access_modifier

private extension PONativeAlternativePaymentConfiguration.Confirmation {

    init(configuration: PODynamicCheckoutAlternativePaymentConfiguration.PaymentConfirmation) {
        waitsConfirmation = true
        timeout = configuration.timeout
        showProgressViewAfter = configuration.showProgressViewAfter
        hideGatewayDetails = true
        if let configuration = configuration.confirmButton {
            confirmButton = .init(title: configuration.title, icon: configuration.icon)
        } else {
            confirmButton = nil
        }
        cancelButton = configuration.cancelButton.map(PONativeAlternativePaymentConfiguration.CancelButton.init)
    }
}

extension PONativeAlternativePaymentConfiguration.CancelButton {

    init(configuration: PODynamicCheckoutAlternativePaymentConfiguration.CancelButton) {
        title = configuration.title
        icon = configuration.icon
        disabledFor = configuration.disabledFor
        confirmation = configuration.confirmation
    }

    init(configuration: PODynamicCheckoutConfiguration.CancelButton) {
        self.init(title: configuration.title, icon: configuration.icon, confirmation: configuration.confirmation)
    }
}

private extension PONativeAlternativePaymentConfiguration.BarcodeInteraction {

    init(configuration: PODynamicCheckoutAlternativePaymentConfiguration.BarcodeInteraction) {
        saveButton = .init(title: configuration.saveButton.title, icon: configuration.saveButton.icon)
        saveErrorConfirmation = configuration.saveErrorConfirmation
        generateHapticFeedback = configuration.generateHapticFeedback
    }
}

private extension POCardTokenizationConfiguration.PreferredScheme {

    init?(schemeSelectionAllowed: Bool, configuration: PODynamicCheckoutCardConfiguration.PreferredScheme) {
        guard schemeSelectionAllowed else {
            return nil
        }
        self.init(title: configuration.title, prefersInline: configuration.prefersInline)
    }
}

private extension POCardTokenizationConfiguration.CardScanner {

    init(configuration: PODynamicCheckoutCardConfiguration.CardScanner) {
        let scanButton = POCardTokenizationConfiguration.CardScanner.ScanButton(configuration: configuration.scanButton)
        self.init(scanButton: scanButton, configuration: configuration.configuration)
    }
}

private extension POCardTokenizationConfiguration.CardScanner.ScanButton {

    init(configuration: PODynamicCheckoutCardConfiguration.CardScanner.ScanButton) {
        self.init(title: configuration.title, icon: configuration.icon)
    }
}

// swiftlint:enable no_extension_access_modifier
