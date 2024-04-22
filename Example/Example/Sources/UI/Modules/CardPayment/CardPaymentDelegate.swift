//
//  CardPaymentDelegate.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.11.2023.
//

import Foundation
@_spi(PO) import ProcessOut
import ProcessOutUI

final class CardPaymentDelegate: POCardTokenizationDelegate {

    init(invoicesService: POInvoicesService, threeDSService: PO3DSService) {
        self.invoicesService = invoicesService
        self.threeDSService = threeDSService
    }

    func cardTokenization(didTokenizeCard card: POCard) async throws {
        let invoiceCreationRequest = POInvoiceCreationRequest(
            name: UUID().uuidString,
            amount: "20",
            currency: "USD",
            returnUrl: Constants.returnUrl
        )
        let invoice = try await invoicesService.createInvoice(request: invoiceCreationRequest)
        let invoiceAuthorizationRequest = POInvoiceAuthorizationRequest(
            invoiceId: invoice.id, source: card.id
        )
        try await invoicesService.authorizeInvoice(request: invoiceAuthorizationRequest, threeDSService: threeDSService)
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let threeDSService: PO3DSService
}
