//
//  NativeAlternativePaymentPhoneNumberValidator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

@_spi(PO) import ProcessOut

struct NativeAlternativePaymentPhoneNumberValidator: InputValidator {

    /// A Boolean value indicating whether the input is required.
    let required: Bool

    /// Localization settings.
    let localization: LocalizationConfiguration

    // MARK: -

    func validate(_ input: PONativeAlternativePaymentSubmitDataV2.Parameter.Value.Phone?) -> InputValidation {
        if input != nil {
            return .valid
        }
        if required {
            return .invalid(
                errorMessage: String(
                    resource: .NativeAlternativePayment.Error.requiredParameter, configuration: localization
                )
            )
        }
        return .valid
    }
}
