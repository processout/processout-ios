//
//  NativeAlternativePaymentPhoneNumberNormalizer.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

@_spi(PO) import ProcessOut

struct NativeAlternativePaymentPhoneNumberNormalizer: InputNormalizer {

    func normalize(
        input: NativeAlternativePaymentInteractorState.ParameterValue?
    ) -> PONativeAlternativePaymentAuthorizationRequestV2.Parameter.Value.Phone? {
        guard case .phone(let phoneNumber) = input else {
            return nil
        }
        if let regionCode = phoneNumber.regionCode, let number = phoneNumber.number {
            guard let dialingCode = PODefaultPhoneNumberMetadataProvider.shared.countryCode(for: regionCode) else {
                return nil
            }
            return .init(dialingCode: dialingCode, number: number)
        } else {
            return nil
        }
    }
}
