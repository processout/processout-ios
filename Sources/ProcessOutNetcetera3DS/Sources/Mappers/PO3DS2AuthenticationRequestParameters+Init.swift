//
//  PO3DS2AuthenticationRequestParameters+Netcetera.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import ProcessOutCore
import ThreeDS_SDK

extension PO3DS2AuthenticationRequestParameters {

    init(parameters: AuthenticationRequestParameters) {
        self.init(
            deviceData: parameters.getDeviceData(),
            sdkAppId: parameters.getSDKAppID(),
            sdkEphemeralPublicKey: parameters.getSDKEphemeralPublicKey(),
            sdkReferenceNumber: parameters.getSDKReferenceNumber(),
            sdkTransactionId: parameters.getSDKTransactionId()
        )
    }
}
