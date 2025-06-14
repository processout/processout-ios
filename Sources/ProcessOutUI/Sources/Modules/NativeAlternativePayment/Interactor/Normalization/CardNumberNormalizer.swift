//
//  NativeAlternativePaymentCardNumberNormalizer.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

@_spi(PO) import ProcessOut

struct NativeAlternativePaymentCardNumberNormalizer: InputNormalizer {

    func normalize(input: PONativeAlternativePaymentParameterValue?) -> String? {
        guard case .string(let value) = input else {
            return nil
        }
        let formatter = POCardNumberFormatter()
        return formatter.normalized(number: value)
    }
}
