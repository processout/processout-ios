//
//  ChallengeParameters+ProcessOut.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import ProcessOut
import ThreeDS_SDK

extension ChallengeParameters {

    convenience init(parameters: PO3DS2ChallengeParameters) {
        self.init(
            threeDSServerTransactionID: parameters.threeDSServerTransactionId,
            acsTransactionID: parameters.acsTransactionId,
            acsRefNumber: parameters.acsReferenceNumber,
            acsSignedContent: parameters.acsSignedContent
        )
    }
}
