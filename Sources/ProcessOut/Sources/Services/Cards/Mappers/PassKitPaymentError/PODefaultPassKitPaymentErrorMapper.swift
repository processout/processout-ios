//
//  PODefaultPassKitPaymentErrorMapper.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.12.2023.
//

// todo(andrii-vysotskyi): remove public access level when POPassKitPaymentAuthorizationController is removed

import PassKit

@_spi(PO)
public final class PODefaultPassKitPaymentErrorMapper: POPassKitPaymentErrorMapper {

    public init(logger: POLogger) {
        self.logger = logger
    }

    // MARK: - POPassKitPaymentErrorMapper

    public func map(poError error: Error) -> [Error] {
        if let failure = error as? POFailure, let pkError = map(failure: failure) {
            return [pkError]
        }
        // Only PKPaymentError is displayed within ApplyPay, so we are mapping non-fatal errors that
        // can be retried. Otherwise, the original error is returned, resulting in the Apple Pay sheet
        // being dismissed.
        logger.debug("Unsupported error, returning original object: \(error)")
        return [error]
    }

    // MARK: - Private Properties

    private let logger: POLogger

    // MARK: - Private Methods

    // swiftlint:disable:next cyclomatic_complexity
    private func map(failure: POFailure) -> PKPaymentError? {
        let pkCode: PKPaymentError.Code, userInfo: [PKPaymentErrorKey: Any]
        switch failure.failureCode {
        case .RequestValidation.invalidName, .RequestValidation.missingName:
            pkCode = .billingContactInvalidError
            userInfo = [.contactFieldUserInfoKey: PKContactField.name]
        case .RequestValidation.invalidEmail, .RequestValidation.missingEmail:
            pkCode = .billingContactInvalidError
            userInfo = [.contactFieldUserInfoKey: PKContactField.emailAddress]
        case .RequestValidation.invalidPhoneNumber:
            pkCode = .billingContactInvalidError
            userInfo = [.contactFieldUserInfoKey: PKContactField.phoneNumber]
        case .RequestValidation.invalidAddress:
            pkCode = .billingContactInvalidError
            userInfo = [:]
        case .RequestValidation.invalidCountry:
            pkCode = .billingContactInvalidError
            userInfo = [.postalAddressUserInfoKey: CNPostalAddressCountryKey]
        case .Gateway.invalidState:
            pkCode = .billingContactInvalidError
            userInfo = [.postalAddressUserInfoKey: CNPostalAddressStateKey]
        case .Resource.countryNotFound:
            pkCode = .billingContactInvalidError
            userInfo = [.postalAddressUserInfoKey: CNPostalAddressCountryKey]
        case .Card.cardInvalidName:
            pkCode = .billingContactInvalidError
            userInfo = [.contactFieldUserInfoKey: PKContactField.name]
        case .Card.cardInvalidZip:
            pkCode = .billingContactInvalidError
            userInfo = [.postalAddressUserInfoKey: CNPostalAddressPostalCodeKey]
        case .Card.cardInvalidAddress:
            pkCode = .billingContactInvalidError
            userInfo = [:]
        case .RequestValidation.invalidShippingMethod, .RequestValidation.invalidShippingDelay:
            pkCode = .shippingContactInvalidError
            userInfo = [:]
        case .Mobile.networkUnreachable:
            pkCode = .unknownError
            userInfo = [:]
        default:
            return nil
        }
        let rawUserInfo = userInfo.reduce(into: [:]) { partialResult, element in
            partialResult[element.key.rawValue] = element.value
        }
        // Apple documentation states that localizedDescription found in user info will be displayed to user
        // but that seems to be wrong when returned error is used to initialize PKPaymentAuthorizationResult,
        // so value is not set and we are relying on Apple to resolve proper description.
        return PKPaymentError(pkCode, userInfo: rawUserInfo)
    }
}
