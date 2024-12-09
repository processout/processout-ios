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
        invoiceId: String, gatewayConfigurationId: String
    ) -> any NativeAlternativePaymentInteractor {
        var logger = self.logger
        logger[attributeKey: .invoiceId] = invoiceId
        logger[attributeKey: .gatewayConfigurationId] = gatewayConfigurationId
        let interactor = NativeAlternativePaymentDefaultInteractor(
            configuration: alternativePaymentConfiguration(
                invoiceId: invoiceId, gatewayConfigurationId: gatewayConfigurationId
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
        invoiceId: String, gatewayConfigurationId: String
    ) -> PONativeAlternativePaymentConfiguration {
        let configuration = PONativeAlternativePaymentConfiguration(
            invoiceId: invoiceId,
            gatewayConfigurationId: gatewayConfigurationId,
            title: "",
            shouldHorizontallyCenterCodeInput: false,
            inlineSingleSelectValuesLimit: configuration.alternativePayment.inlineSingleSelectValuesLimit,
            barcodeInteraction: barcodeInteraction(
                with: self.configuration.alternativePayment.barcodeInteraction
            ),
            submitButton: submitButtonConfiguration(with: configuration.submitButton),
            cancelButton: configuration.cancelButton.map { cancelButtonConfiguration(with: $0) },
            paymentConfirmation: alternativePaymentConfirmationConfiguration(),
            success: nil
        )
        return configuration
    }

    private func submitButtonConfiguration(
        with configuration: PODynamicCheckoutConfiguration.SubmitButton
    ) -> PONativeAlternativePaymentConfiguration.SubmitButton {
        .init(title: configuration.title ?? String(resource: .DynamicCheckout.Button.pay), icon: configuration.icon)
    }

    private func cancelButtonConfiguration(
        with configuration: PODynamicCheckoutConfiguration.CancelButton
    ) -> PONativeAlternativePaymentConfiguration.CancelButton {
        .init(title: configuration.title, icon: configuration.icon, confirmation: configuration.confirmation)
    }

    private func barcodeInteraction(
        with interaction: PODynamicCheckoutAlternativePaymentConfiguration.BarcodeInteraction
    ) -> PONativeAlternativePaymentConfiguration.BarcodeInteraction {
        PONativeAlternativePaymentConfiguration.BarcodeInteraction(
            saveButton: submitButtonConfiguration(with: interaction.saveButton),
            saveErrorConfirmation: interaction.saveErrorConfirmation,
            generateHapticFeedback: interaction.generateHapticFeedback
        )
    }

    private func alternativePaymentConfirmationConfiguration() -> PONativeAlternativePaymentConfiguration.Confirmation {
        PONativeAlternativePaymentConfiguration.Confirmation(
            waitsConfirmation: true,
            timeout: configuration.alternativePayment.paymentConfirmation.timeout,
            showProgressViewAfter: configuration.alternativePayment.paymentConfirmation.showProgressViewAfter,
            hideGatewayDetails: true,
            confirmButton: configuration.alternativePayment.paymentConfirmation.confirmButton.map { configuration in
                submitButtonConfiguration(with: configuration)
            },
            cancelButton: configuration.alternativePayment.paymentConfirmation.cancelButton.map { configuration in
                cancelButtonConfiguration(with: configuration)
            }
        )
    }

    private func cancelButtonConfiguration(
        with configuration: PODynamicCheckoutAlternativePaymentConfiguration.CancelButton
    ) -> PONativeAlternativePaymentConfiguration.CancelButton {
        PONativeAlternativePaymentConfiguration.CancelButton(
            title: configuration.title,
            icon: configuration.icon,
            disabledFor: configuration.disabledFor,
            confirmation: configuration.confirmation
        )
    }
}
