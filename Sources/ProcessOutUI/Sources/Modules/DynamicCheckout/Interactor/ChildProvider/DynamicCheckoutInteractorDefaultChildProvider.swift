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
        configuration: PODynamicCheckoutPaymentMethod.CardConfiguration
    ) -> any CardTokenizationInteractor {
        let interactor = DefaultCardTokenizationInteractor(
            cardsService: cardsService,
            logger: logger,
            configuration: cardTokenizationConfiguration(configuration: configuration),
            completion: { _ in }
        )
        return interactor
    }

    func nativeAlternativePaymentInteractor(gatewayConfigurationId: String) -> any NativeAlternativePaymentInteractor {
        var logger = self.logger
        logger[attributeKey: .gatewayConfigurationId] = gatewayConfigurationId
        let interactor = NativeAlternativePaymentDefaultInteractor(
            configuration: alternativePaymentConfiguration(gatewayId: gatewayConfigurationId),
            invoicesService: invoicesService,
            imagesRepository: imagesRepository,
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
            isCardholderNameInputVisible: configuration.requireCardholderName,
            shouldCollectCvc: configuration.requireCvc,
            primaryActionTitle: "",
            cancelActionTitle: "",
            billingAddress: billingAddressConfiguration,
            metadata: self.configuration.card.metadata
        )
        return cardConfiguration
    }

    private func alternativePaymentConfiguration(gatewayId: String) -> PONativeAlternativePaymentConfiguration {
        let confirmationConfiguration = PONativeAlternativePaymentConfirmationConfiguration(
            waitsConfirmation: true,
            timeout: configuration.alternativePayment.captureConfirmation.timeout,
            showProgressIndicatorAfter: configuration.alternativePayment.captureConfirmation.showProgressIndicatorAfter,
            secondaryAction: secondaryActionConfiguration(
                with: configuration.alternativePayment.captureConfirmation.cancelButton
            )
        )
        let alternativePaymentConfiguration = PONativeAlternativePaymentConfiguration(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: gatewayId,
            title: "",
            successMessage: "",
            primaryActionTitle: "",
            secondaryAction: secondaryActionConfiguration(with: configuration.alternativePayment.cancelButton),
            inlineSingleSelectValuesLimit: configuration.alternativePayment.inlineSingleSelectValuesLimit,
            skipSuccessScreen: true,
            paymentConfirmation: confirmationConfiguration
        )
        return alternativePaymentConfiguration
    }

    private func secondaryActionConfiguration(
        with configuration: PODynamicCheckoutAlternativePaymentConfiguration.CancelButton?
    ) -> PONativeAlternativePaymentConfiguration.SecondaryAction? {
        configuration.map { .cancel(title: "", disabledFor: $0.disabledFor, confirmation: nil) }
    }
}
