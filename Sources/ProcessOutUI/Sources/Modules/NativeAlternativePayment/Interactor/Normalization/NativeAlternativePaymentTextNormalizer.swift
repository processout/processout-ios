//
//  NativeAlternativePaymentTextNormalizer.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

struct NativeAlternativePaymentTextNormalizer: InputNormalizer {

    func normalize(input: NativeAlternativePaymentInteractorState.ParameterValue?) -> String? {
        if case .string(let value) = input {
            return value
        }
        return nil
    }
}
