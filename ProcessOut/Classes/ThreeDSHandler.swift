//
//  ThreeDSHandler.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

/// Custom protocol which lets you implement a 3DS2 integration
public protocol ThreeDSHandler {
    /// method called when a device fingerprint is required
    ///
    /// - Parameters:
    ///   - directoryServerData: Contains information required by the third-party handling the device fingerprinting
    ///   - completion: Callback containing the fingerprint information
    func doFingerprint(directoryServerData: DirectoryServerData, completion: @escaping (ThreeDSFingerprintResponse) -> Void)
    
    /// Method called when a 3DS2 challenge is required
    ///
    /// - Parameters:
    ///   - authentificationData: Authentification data required to present the challenge
    ///   - completion: Callback specifying wheter or not the challenge was successful
    func doChallenge(authentificationData: AuthentificationChallengeData, completion: @escaping (Bool) -> Void)
    
    /// Called when the authorization was successful
    ///
    /// - Parameter invoiceId: Invoice id that was authorized
    func onSuccess(invoiceId: String)
    
    /// Called when the authorization process ends up in a failed state.
    ///
    /// - Parameter error: Error
    func onError(error: ProcessOutException)
}


/// Creates a test 3DS2 handler that lets you integrate and test the 3DS2 flow seamlessly. Only use this while using sandbox API keys
///
/// - Parameter viewController: UIViewController (needed to display a 3DS2 challenge popup)
/// - Returns: Returns a sandbox ready ThreeDS2Handler
public func createThreDSTestHandler(viewController: UIViewController) -> ThreeDSHandler {
    return ThreeDSTestHandler(controller: viewController)
}
public class ThreeDSTestHandler: ThreeDSHandler {
    var controller: UIViewController
    public init(controller: UIViewController) {
        self.controller = controller
    }
    
    public func doFingerprint(directoryServerData: DirectoryServerData, completion: (ThreeDSFingerprintResponse) -> Void) {
        completion(ThreeDSFingerprintResponse(sdkEncData: "", sdkAppID: "", sdkEphemPubKey: ThreeDSFingerprintResponse.SDKEphemPubKey(), sdkReferenceNumber: "", sdkTransID: ""))
    
    }
    
    public func doChallenge(authentificationData: AuthentificationChallengeData, completion: (Bool) -> Void) {
        let alert = UIAlertController(title: "Did you bring your towel?", message: "It's recommended you bring your towel before continuing.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.controller.present(alert, animated: true)
        completion(true)
    }
    
    public func onSuccess(invoiceId: String) {
        print("success: " + invoiceId)
    }
    
    public func onError(error: ProcessOutException) {
        print(error)
    }
    
    
}
