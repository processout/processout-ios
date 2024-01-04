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
            directoryServerID: "M000000003",
            // swiftlint:disable:next line_length
            directoryServerPublicKey: "eyJjcnYiOiJQLTI1NiIsImt0eSI6IkVDIiwieCI6Im4xa1BzejFRc3lZMUlsQ2x6SHd6VFZ2Y1JPZ1BtcHZ5bWZ3eDdjcUx1OVkiLCJ5IjoiMDRZbC1XSlFTVzBBclBlSkZqSXU5d19ycnNoaDctMUY2aEJpWlExUmFhbyJ9",
            directoryServerRootCertificates: [
                // swiftlint:disable:next line_length
                "MIIDSzCCAjOgAwIBAgIISFX+yGDbtvQwDQYJKoZIhvcNAQELBQAwIDEeMBwGA1UEAxMVbWluaWNhIHJvb3QgY2EgNDg1NWZlMCAXDTIxMDExOTA4NTc1NFoYDzIxMjEwMTE5MDg1NzU0WjAgMR4wHAYDVQQDExVtaW5pY2Egcm9vdCBjYSA0ODU1ZmUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDVes5iP44ATynSsZz0CASMWQFsoPwzzudFujpEJCVSOeHe+FGRxPp10LSo5JHAjZs5GX1HtihxGI5FFg9Rnh6nA6e90ih36uLnZvyIq41MOBdyMh9YlmqFoIO/Xk39hF8cIMTG5mATZ3XIwDIFFt+1jQk+f5qVrsjV52QNidGW7SYhTpDeXTv1Rf5L65rmudPp8ekwSPt79ah1KPSuTwurfa/qVY6gx2uFwWk7H2uE+TYhwUJlyKXtuSsHj0p2uKiXzTDIjK3wSpYiAO/QjhE2AEiZM9JKYMA47cdTaV2hdKJZS2ic0N6TDmG39P+GfrbbepCuXWV0hjXhlty6gmtRAgMBAAGjgYYwgYMwDgYDVR0PAQH/BAQDAgKEMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBSAkzJvoSMHvwGHo+iqj4X7DCIIljAfBgNVHSMEGDAWgBSAkzJvoSMHvwGHo+iqj4X7DCIIljANBgkqhkiG9w0BAQsFAAOCAQEAMRvz5g/2mLZibea+mXUQgAmFewMkmUNDZaqADbR8FUHqYQMnst0ymJhgzzqtk932JOLC0j1I0Od4y7+ljAdC8W0dNOxk57zMIHvNxk2PtNrK0lGOJrCdSeRBIxTOXn+pJYmwBn+qpxmBJykDm0pkLoNAdB3n9vfcY2Kh4QUrdB4uQZT5x61jsbnkRE0FO4LoRxx1wLDkvjzjuCM9Eu7EowgyR/4iO7H6n11iwVSQdO0aVOg3nHwEdGHWryvysKu1Sp36TA7bbsRZmtaQWnWkRheqmZynqte/yhl5i3EXOnyIhd1TRwWYvg7T8qEDiXNNeqc/3fivkm+mYOfck/LNqA"
            ]
        )
        let configParameters = ThreeDS2ServiceConfiguration.ConfigParameters(
            directoryServerData: directoryServerData,
            messageVersion: "2.2.0",
            scheme: "visa"
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
