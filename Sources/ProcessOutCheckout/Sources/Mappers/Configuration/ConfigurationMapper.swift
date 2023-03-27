//
//  ConfigurationMapper.swift
//  ProcessOutCheckout
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

import ProcessOut
import Checkout3DS

final class ConfigurationMapper: ConfigurationMapperType {

    func convert(configuration: PO3DS2Configuration) -> ThreeDS2ServiceConfiguration.ConfigParameters {
        let directoryServerData = ThreeDS2ServiceConfiguration.DirectoryServerData(
            directoryServerID: configuration.directoryServerId,
            directoryServerPublicKey: configuration.directoryServerPublicKey,
            directoryServerRootCertificate: configuration.directoryServerRootCertificates.last ?? ""
        )
        let configParameters = ThreeDS2ServiceConfiguration.ConfigParameters(
            directoryServerData: directoryServerData,
            messageVersion: configuration.messageVersion,
            scheme: configuration.scheme.map(self.convert) ?? ""
        )
        return configParameters
    }

    // MARK: - Private Methods

    private func convert(scheme: PO3DS2ConfigurationCardScheme) -> String {
        scheme.rawValue
    }
}
