//
//  AdyenThreeDSHandler.swift
//  ProcessOut_Example
//
//  Created by Jeremy Lejoux on 19/06/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//
import ProcessOut
import Adyen3DS2

class AdyenThreeDSHandler: ThreeDSHandler {
    
    var transaction: ADYTransaction?
    
    func doFingerprint(directoryServerData: DirectoryServerData, completion: @escaping (ThreeDSFingerprintResponse) -> Void) {
        let parameters = ADYServiceParameters()
        parameters.directoryServerIdentifier = directoryServerData.directoryServerID
        parameters.directoryServerPublicKey = directoryServerData.directoryServerPublicKey
        
        ADYService.service(with: parameters, appearanceConfiguration: nil, completionHandler: {(service: ADYService) -> Void
            in
            do {
                self.transaction = try service.transaction(withMessageVersion: nil)
                    let authReqParams = self.transaction!.authenticationRequestParameters
                    if let sdkEphemPubKeyData = authReqParams.sdkEphemeralPublicKey.data(using: .utf8) {
                        let sdkEphemPubKey = try JSONDecoder().decode(ThreeDSFingerprintResponse.SDKEphemPubKey.self, from: sdkEphemPubKeyData)
                        let fingerprintResponse = ThreeDSFingerprintResponse(
                            sdkEncData: authReqParams.deviceInformation,
                            sdkAppID: authReqParams.sdkApplicationIdentifier,
                            sdkEphemPubKey: sdkEphemPubKey,
                            sdkReferenceNumber: authReqParams.sdkReferenceNumber,
                            sdkTransID: authReqParams.sdkTransactionIdentifier)
                        
                        completion(fingerprintResponse)
                        
                    } else {
                        print("Could not encode sdkEphem")
                    }
            } catch {
                print(error)
            }
        })
    }
    
    func doChallenge(authentificationData: AuthentificationChallengeData, completion: @escaping (Bool) -> Void) {
        let challengeParameters = ADYChallengeParameters(serverTransactionIdentifier: authentificationData.threeDSServerTransID, acsTransactionIdentifier: authentificationData.acsTransID, acsReferenceNumber: authentificationData.acsReferenceNumber, acsSignedContent: authentificationData.acsSignedContent)
        
        transaction?.performChallenge(with: challengeParameters, completionHandler: { (result, error) in
            if result != nil{
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func onSuccess(invoiceId: String) {
        print(invoiceId + " SUCCESS")
    }
    
    func onError(error: ProcessOutException) {
        print(error)
    }
    
    
}
