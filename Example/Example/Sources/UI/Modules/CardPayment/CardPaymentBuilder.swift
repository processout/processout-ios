//
//  CardPaymentBuilder.swift
//  Example
//
//  Created by Andrii Vysotskyi on 10.03.2023.
//

import UIKit
import ProcessOut
import ProcessOutUI
import ProcessOutCheckout3DS

@MainActor
final class CardPaymentBuilder {

    init(threeDSService: CardPayment3DSService = .test, completion: @escaping (Result<POCard, POFailure>) -> Void) {
        self.threeDSService = threeDSService
        self.completion = completion
    }

    func build() -> UIViewController {
        let threeDSService: PO3DSService
        switch self.threeDSService {
        case .test:
            threeDSService = POTest3DSService()
        case .checkout:
            threeDSService = POCheckout3DSService(environment: .sandbox)
        }
        let delegate = CardPaymentDelegate(
            invoicesService: ProcessOut.shared.invoices, threeDSService: threeDSService
        )
        let configuration = POCardTokenizationConfiguration(isCardholderNameInputVisible: false)
        let viewController = POCardTokenizationViewController(
            configuration: configuration, delegate: delegate, completion: completion
        )
        objc_setAssociatedObject(viewController, &AssociatedObjectKeys.delegate, delegate, .OBJC_ASSOCIATION_RETAIN)
        return viewController
    }

    // MARK: - Private Nested Types

    private enum AssociatedObjectKeys {
        static var delegate: UInt8 = 0
    }

    // MARK: - Private Properties

    private let threeDSService: CardPayment3DSService
    private let completion: (Result<POCard, POFailure>) -> Void
}
