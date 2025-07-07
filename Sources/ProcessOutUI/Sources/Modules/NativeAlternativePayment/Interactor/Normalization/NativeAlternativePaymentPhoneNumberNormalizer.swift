//
//  NativeAlternativePaymentPhoneNumberNormalizer.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

@_spi(PO) import ProcessOut

struct NativeAlternativePaymentPhoneNumberNormalizer: InputNormalizer {

    let dialingCodes: [PONativeAlternativePaymentFormV2.Parameter.PhoneNumber.DialingCode]

    // MARK: - InputNormalizer

    func normalize(
        input: PONativeAlternativePaymentParameterValue?
    ) -> PONativeAlternativePaymentSubmitDataV2.Parameter.Value.Phone? {
        guard case .phone(let phoneNumber) = input else {
            return nil
        }
        if let regionCode = phoneNumber.regionCode, let number = phoneNumber.number {
            guard let dialingCode = dialingCodes.first(where: { $0.regionCode == regionCode }) else {
                return nil
            }
            let normalizedNumber = number.filter(\.isNumber)
            return .init(dialingCode: dialingCode.value, number: normalizedNumber)
        } else {
            return nil
        }
    }
}
