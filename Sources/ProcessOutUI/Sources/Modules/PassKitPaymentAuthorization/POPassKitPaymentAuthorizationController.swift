//
//  POPassKitPaymentAuthorizationController.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit
@_spi(PO) import ProcessOut

public final class POPassKitPaymentAuthorizationController: NSObject {

    /// Determine whether this device can process payment requests.
    public class func canMakePayments() -> Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }

    /// Determine whether this device can process payment requests using specific payment network brands.
    public class func canMakePayments(usingNetworks supportedNetworks: [PKPaymentNetwork]) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }

    /// Determine whether this device can process payments using the specified networks and capabilities bitmask
    public class func canMakePayments(
        usingNetworks supportedNetworks: [PKPaymentNetwork], capabilities capabilties: PKMerchantCapability
    ) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks, capabilities: capabilties)
    }

    /// Initialize the controller with a payment request.
    public init?(paymentRequest: PKPaymentRequest) {
        if PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) == nil {
            return nil
        }
        self.paymentRequest = paymentRequest
        controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        super.init()
        commonInit()
    }

    /// Presents the Apple Pay UI modally over your app. You are responsible for dismissal
    public func present(completion: ((Bool) -> Void)? = nil) {
        controller.present(completion: completion)
    }

    /// Dismisses the Apple Pay UI. Call this when you receive the paymentAuthorizationControllerDidFinish delegate
    /// callback, or otherwise wish a dismissal to occur
    public func dismiss(completion: (() -> Void)? = nil) {
        controller.dismiss(completion: completion)
    }

    /// The controller's delegate.
    public weak var delegate: POPassKitPaymentAuthorizationControllerDelegate? {
        get { coordinator.delegate }
        set { coordinator.delegate = newValue }
    }

    // MARK: - Private Properties

    private let paymentRequest: PKPaymentRequest
    private let controller: PKPaymentAuthorizationController

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var coordinator: PassKitPaymentAuthorizationCoordinator!

    // MARK: - Private Methods

    private func commonInit() {
        coordinator = PassKitPaymentAuthorizationCoordinator(
            controller: self,
            paymentRequest: paymentRequest,
            contactMapper: DefaultPassKitContactMapper(logger: ProcessOut.shared.logger),
            errorMapper: DefaultPassKitPaymentErrorMapper(logger: ProcessOut.shared.logger),
            cardsService: ProcessOut.shared.cards
        )
        controller.delegate = coordinator
    }
}

extension POPassKitPaymentAuthorizationController {

    /// Presents the payment sheet modally over your app.
    public func present() async -> Bool {
        await withUnsafeContinuation { continuation in
            present(completion: continuation.resume)
        }
    }

    /// Dismisses the payment sheet.
    public func dismiss() async {
        await withUnsafeContinuation { continuation in
            dismiss(completion: continuation.resume)
        }
    }
}
