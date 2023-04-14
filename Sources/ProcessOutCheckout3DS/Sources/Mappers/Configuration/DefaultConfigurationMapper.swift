//
//  DefaultConfigurationMapper.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 27.03.2023.
//

import ProcessOut
import Checkout3DS

final class DefaultConfigurationMapper: ConfigurationMapper {

    func convert(configuration: PO3DS2Configuration) -> ThreeDS2ServiceConfiguration.ConfigParameters {
        let directoryServerData = ThreeDS2ServiceConfiguration.DirectoryServerData(
            directoryServerID: configuration.directoryServerId,
            directoryServerPublicKey: configuration.directoryServerPublicKey,
            directoryServerRootCertificates: configuration.directoryServerRootCertificates
        )
        let configParameters = ThreeDS2ServiceConfiguration.ConfigParameters(
            directoryServerData: directoryServerData,
            messageVersion: configuration.messageVersion,
            scheme: configuration.scheme.map(self.convert) ?? ""
        )
        return configParameters
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let visa = "visa"
        static let mastercard = "mastercard"
    }

    // MARK: - Private Methods

    private func convert(scheme: PO3DS2ConfigurationCardScheme) -> String {
        let schemes: [PO3DS2ConfigurationCardScheme: String] = [
            .visa: Constants.visa, .mastercard: Constants.mastercard
        ]
        return schemes[scheme] ?? ""
    }
}
