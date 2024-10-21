//
//  DynamicCheckoutInteractorDefaultChildProvider.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 17.04.2024.
//

import Foundation
@_spi(PO) import ProcessOut

final class DynamicCheckoutInteractorDefaultChildProvider: DynamicCheckoutInteractorChildProvider {

    init(
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
            configuration: cardTokenizationConfiguration(configuration: configuration),
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

    // MARK: - Private Methods

    private func cardTokenizationConfiguration(
        configuration: PODynamicCheckoutPaymentMethod.CardConfiguration
    ) -> POCardTokenizationConfiguration {
        let billingAddressConfiguration = POBillingAddressConfiguration(
            mode: configuration.billingAddress.collectionMode,
            countryCodes: configuration.billingAddress.restrictToCountryCodes,
            defaultAddress: self.configuration.card.billingAddress.defaultAddress,
            attachDefaultsToPaymentMethod: self.configuration.card.billingAddress.attachDefaultsToPaymentMethod
        )
        let cardConfiguration = POCardTokenizationConfiguration(
            title: "",
            isCardholderNameInputVisible: configuration.cardholderNameRequired,
            shouldCollectCvc: configuration.cvcRequired,
            primaryActionTitle: self.configuration.submitButtonTitle ?? String(resource: .DynamicCheckout.Button.pay),
            cancelActionTitle: "",
            billingAddress: billingAddressConfiguration,
            isSavingAllowed: configuration.savingAllowed,
            metadata: self.configuration.card.metadata
        )
        return cardConfiguration
    }

    private func alternativePaymentConfiguration(
        invoiceId: String, gatewayConfigurationId: String
    ) -> PONativeAlternativePaymentConfiguration {
        let alternativePaymentConfiguration = PONativeAlternativePaymentConfiguration(
            invoiceId: invoiceId,
            gatewayConfigurationId: gatewayConfigurationId,
            title: "",
            shouldHorizontallyCenterCodeInput: false,
            successMessage: "",
            primaryActionTitle: self.configuration.submitButtonTitle ?? String(resource: .DynamicCheckout.Button.pay),
            secondaryAction: nil,
            inlineSingleSelectValuesLimit: configuration.alternativePayment.inlineSingleSelectValuesLimit,
            skipSuccessScreen: true,
            paymentConfirmation: alternativePaymentConfirmationConfiguration
        )
        return alternativePaymentConfiguration
    }

    // swiftlint:disable:next identifier_name
    private var alternativePaymentConfirmationConfiguration: PONativeAlternativePaymentConfirmationConfiguration {
        let configuration = self.configuration.alternativePayment.paymentConfirmation
        let confirmationConfiguration = PONativeAlternativePaymentConfirmationConfiguration(
            waitsConfirmation: true,
            timeout: configuration.timeout,
            showProgressIndicatorAfter: configuration.showProgressIndicatorAfter,
            hideGatewayDetails: true,
            confirmButton: configuration.confirmButton.map { button in
                .init(title: button.title)
            },
            secondaryAction: configuration.cancelButton.map { configuration in
                .cancel(title: "", disabledFor: configuration.disabledFor, confirmation: nil)
            }
        )
        return confirmationConfiguration
    }
}
