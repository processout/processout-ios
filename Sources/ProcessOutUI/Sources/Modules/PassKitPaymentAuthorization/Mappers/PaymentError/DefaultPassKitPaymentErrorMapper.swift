//
//  DefaultPassKitPaymentErrorMapper.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.12.2023.
//

import PassKit
@_spi(PO) import ProcessOut

final class DefaultPassKitPaymentErrorMapper: PassKitPaymentErrorMapper {

    init(logger: POLogger) {
        self.logger = logger
    }

    func map(poError error: Error) -> [Error] {
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

    private func map(failure: POFailure) -> NSError? {
        let pkCode: PKPaymentError.Code?
        var userInfo: [String: Any] = [:]
        switch failure.code {
        case .validation(let code):
            pkCode = map(validationCode: code, userInfo: &userInfo)
        case .notFound(.country):
            pkCode = .billingContactInvalidError
            userInfo[PKPaymentErrorKey.postalAddressUserInfoKey.rawValue] = CNPostalAddressCountryKey
        case .generic(let code):
            pkCode = map(genericCode: code, userInfo: &userInfo)
        case .networkUnreachable:
            pkCode = .unknownError
        default:
            return nil
        }
        guard let pkCode else {
            return nil
        }
        // Apple documentation states that localizedDescription found in user info will be displayed to user
        // but that seems to be wrong, so value is not set and we are relying on Apple to resolve proper description.
        return NSError(domain: PKPaymentError.errorDomain, code: pkCode.rawValue, userInfo: userInfo)
    }

    /// Maps given code to PKPaymentError code and fills user info with details if possible.
    private func map(genericCode code: POFailure.GenericCode, userInfo: inout [String: Any]) -> PKPaymentError.Code? {
        switch code {
        case .cardInvalidName:
            userInfo[PKPaymentErrorKey.contactFieldUserInfoKey.rawValue] = PKContactField.name
        case .cardInvalidZip:
            userInfo[PKPaymentErrorKey.postalAddressUserInfoKey.rawValue] = CNPostalAddressPostalCodeKey
        case .cardInvalidAddress:
            break
        default:
            return nil
        }
        return .billingContactInvalidError
    }

    /// Maps given code to PKPaymentError code and fills user info with details if possible.
    private func map(
        validationCode code: POFailure.ValidationCode, userInfo: inout [String: Any]
    ) -> PKPaymentError.Code? {
        switch code {
        case .invalidName, .missingName:
            userInfo[PKPaymentErrorKey.contactFieldUserInfoKey.rawValue] = PKContactField.name
        case .invalidEmail, .missingEmail:
            userInfo[PKPaymentErrorKey.contactFieldUserInfoKey.rawValue] = PKContactField.emailAddress
        case .invalidPhoneNumber:
            userInfo[PKPaymentErrorKey.contactFieldUserInfoKey.rawValue] = PKContactField.phoneNumber
        case .invalidAddress:
            break
        case .invalidCountry:
            userInfo[PKPaymentErrorKey.postalAddressUserInfoKey.rawValue] = CNPostalAddressCountryKey
        case .invalidState:
            userInfo[PKPaymentErrorKey.postalAddressUserInfoKey.rawValue] = CNPostalAddressStateKey
        default:
            return nil
        }
        return .billingContactInvalidError
    }
}
