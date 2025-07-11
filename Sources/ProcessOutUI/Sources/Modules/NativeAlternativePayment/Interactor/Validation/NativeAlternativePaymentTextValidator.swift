//
//  NativeAlternativePayment.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

@_spi(PO) import ProcessOut

/// A validator for text input that supports optional length constraints and required field checks.
struct NativeAlternativePaymentTextValidator: InputValidator {

    init(minLength: Int? = nil, maxLength: Int? = nil, required: Bool) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.required = required
    }

    /// The minimum number of characters allowed in the input.
    let minLength: Int?

    /// The maximum number of characters allowed in the input.
    let maxLength: Int?

    /// A Boolean value indicating whether the input is required.
    let required: Bool

    // MARK: - InputValidator

    func validate(_ input: String?) -> InputValidation {
        if let input {
            if let maxLength, input.count > maxLength {
                if let minLength, minLength == maxLength {
                    let message = String(
                        resource: .NativeAlternativePayment.Error.invalidLength, replacements: maxLength
                    )
                    return .invalid(errorMessage: message)
                }
                let message = String(
                    resource: .NativeAlternativePayment.Error.invalidMaxLength, replacements: maxLength
                )
                return .invalid(errorMessage: message)
            }
            if let minLength, input.count < minLength {
                if let maxLength, minLength == maxLength {
                    let message = String(
                        resource: .NativeAlternativePayment.Error.invalidLength, replacements: minLength
                    )
                    return .invalid(errorMessage: message)
                }
                let message = String(
                    resource: .NativeAlternativePayment.Error.invalidMinLength, replacements: minLength
                )
                return .invalid(errorMessage: message)
            }
            return .valid
        }
        if required {
            let message = String(resource: .NativeAlternativePayment.Error.requiredParameter)
            return .invalid(errorMessage: message)
        }
        return .valid
    }
}
