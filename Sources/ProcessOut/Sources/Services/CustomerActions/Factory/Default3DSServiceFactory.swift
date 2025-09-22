//
//  Default3DSServiceFactory.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.09.2025.
//

import Foundation
#if canImport(ProcessOutNetcetera3DS)
import ProcessOutNetcetera3DS
#endif

struct Default3DSServiceFactory: ThreeDSServiceFactory {

    func make3DSService(with input: ThreeDSServiceFactoryInput) throws(POFailure) -> PO3DS2Service {
        #if canImport(ProcessOutNetcetera3DS)
        PONetcetera3DS2Service(
            configuration: .init(
                authenticationMode: .compatibility,
                locale: input.localeIdentifier.map(Locale.init),
                showsProgressView: false,
                bridgingExtensionVersion: nil,
                returnUrl: returnUrl(with: input),
            ),
            delegate: nil
        )
        #else
        throw POFailure(message: "Default 3DS Service is not available.", code: .Mobile.generic)
        #endif
    }

    // MARK: - Private Methods

    private func returnUrl(with input: ThreeDSServiceFactoryInput) -> URL? {
        var components = URLComponents()
        switch input.webAuthenticationCallback?.value {
        case .scheme(let scheme):
            components.scheme = scheme
            components.host = "processout"
        case let .https(host, path):
            components.scheme = "https"
            components.path = path.hasPrefix("/") ? path : "/" + path
            components.host = host
        case nil:
            return nil
        }
        return components.url
    }
}
