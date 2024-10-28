//
//  DefaultConfigurationMapper.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

import ProcessOut
import Checkout3DS

struct DefaultConfigurationMapper: ConfigurationMapper {

    func convert(configuration: PO3DS2Configuration) -> ThreeDS2ServiceConfiguration.ConfigParameters {
        let directoryServerData = ThreeDS2ServiceConfiguration.DirectoryServerData(
            directoryServerID: configuration.directoryServerId,
            directoryServerPublicKey: configuration.directoryServerPublicKey,
            directoryServerRootCertificates: configuration.directoryServerRootCertificates
        )
        let configParameters = ThreeDS2ServiceConfiguration.ConfigParameters(
            directoryServerData: directoryServerData,
            messageVersion: configuration.messageVersion,
            scheme: configuration.$scheme.typed().map(self.convert) ?? ""
        )
        return configParameters
    }

    // MARK: - Private Methods

    private func convert(scheme: POCardScheme) -> String {
        // todo(andrii-vysotskyi): fail mapping if scheme is unsupported
        let supportedSchemes: Set<POCardScheme> = [.visa, .mastercard]
        guard supportedSchemes.contains(scheme) else {
            return ""
        }
        return scheme.rawValue
    }
}
