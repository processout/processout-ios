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

final class CardPaymentBuilder {

    init(completion: @escaping (Result<POCard, POFailure>) -> Void) {
        self.completion = completion
    }

    func build() -> UIViewController {
        let threeDSServiceDelegate = CardPayment3DSServiceDelegate()
        let threeDSService = POCheckout3DSServiceBuilder()
            .with(delegate: threeDSServiceDelegate)
            .with(environment: .sandbox)
            .build()
        let delegate = CardPaymentDelegate(
            invoicesService: ProcessOut.shared.invoices, threeDSService: threeDSService
        )
        let configuration = POCardTokenizationConfiguration(isCardholderNameInputVisible: false)
        let viewController = POCardTokenizationViewController(
            configuration: configuration, delegate: delegate, completion: completion
        )
        threeDSServiceDelegate.viewController = viewController
        objc_setAssociatedObject(viewController, &AssociatedObjectKeys.delegate, delegate, .OBJC_ASSOCIATION_RETAIN)
        return viewController
    }

    // MARK: - Private Nested Types

    private enum AssociatedObjectKeys {
        static var delegate: UInt8 = 0
    }

    // MARK: - Private Properties

    private let completion: (Result<POCard, POFailure>) -> Void
}
