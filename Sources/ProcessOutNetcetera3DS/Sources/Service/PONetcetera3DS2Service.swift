//
//  PONetcetera3DS2Service.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.04.2025.
//

@_spi(PO) import ProcessOut
@_spi(PO) import NetceteraShim
import ThreeDS_SDK

// todo(andrii-vysotskyi): add logs
// todo(andrii-vysotskyi): map errors returned by Netcetera SDK

public actor PONetcetera3DS2Service: PO3DS2Service {

    public init(
        configuration: PONetcetera3DS2ServiceConfiguration = .init(),
        delegate: PONetcetera3DS2ServiceDelegate? = nil
    ) {
        self.eventEmitter = ProcessOut.shared.eventEmitter
        self.configuration = configuration
        self.delegate = delegate
    }

    weak var delegate: PONetcetera3DS2ServiceDelegate?

    // MARK: - PO3DS2Service

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        let service = ThreeDS2ServiceSDK()
        try await service.initialize(
            try configurationParameters(with: configuration),
            locale: self.configuration.locale?.identifier,
            uiCustomizationMap: self.configuration.uiCustomizations
        )
        self.service = service
        let transaction = try service.createTransaction(
            directoryServerId: configuration.directoryServerId, messageVersion: configuration.messageVersion
        )
        self.transaction = transaction
        if self.configuration.showsProgressView {
            try await MainActor.run {
                try transaction.getProgressView().start()
            }
        }
        if let version = self.configuration.bridgingExtensionVersion {
            transaction.useBridgingExtension(version: version)
        }
        if let delegate, await !delegate.netcetera3DS2Service(self, shouldContinueWith: try service.getWarnings()) {
            throw POFailure(code: .Mobile.cancelled)
        }
        let parameters = try transaction.getAuthenticationRequestParameters()
        return PO3DS2AuthenticationRequestParameters(parameters: parameters)
    }

    public func performChallenge(
        with parameters: PO3DS2ChallengeParameters
    ) async throws -> PO3DS2ChallengeResult {
        guard let transaction else {
            throw POFailure(message: "Unable to resolve current transaction.", code: .Mobile.internal)
        }
        var presentingViewController = await PresentingViewControllerProvider.find()
        await delegate?.netcetera3DS2Service(
            self, willPerformChallengeOn: &presentingViewController
        )
        guard let presentingViewController  else {
            throw POFailure(message: "Unable to prepare presentation context.", code: .Mobile.generic)
        }
        let challengeParameters = ChallengeParameters(parameters: parameters)
        if let returnUrl = configuration.returnUrl {
            challengeParameters.setThreeDSRequestorAppURL(threeDSRequestorAppURL: returnUrl.absoluteString)
            observeDeepLinks()
        }
        // fixme(andrii-vysotskyi): presenting controller is being dismissed by Netcetera unintentionally
        let challengeStatus = try await transaction.doChallenge(
            challengeParameters: challengeParameters,
            timeout: Int(configuration.challengeTimeout / 60),
            in: presentingViewController
        )
        return try .init(status: challengeStatus)
    }

    public func clean() async {
        if let transaction {
            await MainActor.run {
                try? transaction.getProgressView().stop()
            }
            try? transaction.close()
            self.transaction = nil
        }
        if let service {
            try? service.cleanup()
            self.service = nil
        }
        deepLinkObservation = nil
    }

    // MARK: - Private Properties

    private let eventEmitter: POEventEmitter, configuration: PONetcetera3DS2ServiceConfiguration
    private var service: ThreeDS2ServiceSDK?, transaction: Transaction?

    // MARK: - Configuration

    private func configurationParameters(
        with configuration: PO3DS2Configuration
    ) throws(POFailure) -> ConfigParameters {
        let builder = ConfigurationBuilder()
        do {
            try builder.poApiKey()
            if let scheme = try customScheme(with: configuration) {
                try builder.add(scheme)
            }
            // todo(andrii-vysotskyi): restrict parameters for payment processors such as Stripe.
            try builder.log(to: .noLog)
        } catch {
            throw POFailure(
                message: "Unable to create configuration parameters.", code: .Mobile.generic, underlyingError: error
            )
        }
        return builder.configParameters()
    }

    private func customScheme(with configuration: PO3DS2Configuration) throws(POFailure) -> Scheme? {
        let wellKnownIds: Set<String> = [
            DsRidValues.mastercard,
            DsRidValues.visa,
            DsRidValues.amex,
            DsRidValues.diners,
            DsRidValues.union,
            DsRidValues.jcb,
            DsRidValues.cartesBancaires,
            DsRidValues.eftpos
        ]
        guard !wellKnownIds.contains(configuration.directoryServerId) else {
            return nil // Rely on pre-configured values bundled with SDK
        }
        let encryptionKey: String, encryptionKeyId: String?
        do {
            let jwk = try JwkDecoder().decode(from: configuration.directoryServerPublicKey)
            let asn = try JwkAsnEncoder().encode(jwk)
            encryptionKey = AsnDerEncoder().encode(asn).base64EncodedString()
            encryptionKeyId = jwk.kid
        } catch {
            throw POFailure(
                message: "Unable to encode directory server public key.", code: .Mobile.generic, underlyingError: error
            )
        }
        // todo(andrii-vysotskyi): validate certificates with Adyen
        let scheme = Scheme(
            name: configuration.$scheme.typed()?.rawValue ?? "<unknown>",
            ids: [configuration.directoryServerId],
            logoImageName: nil,
            encryption: encryptionKey,
            encryptionKeyId: encryptionKeyId,
            roots: configuration.directoryServerRootCertificates
        )
        return scheme
    }

    // MARK: - OOB

    private var deepLinkObservation: AnyObject?

    private func observeDeepLinks() {
        deepLinkObservation = eventEmitter.on(PODeepLinkReceivedEvent.self) { event in
            let userActivitySchemes: Set<String> = ["http", "https"]
            if let scheme = event.url.scheme, userActivitySchemes.contains(scheme) {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = event.url
                return ThreeDSSDKAppDelegate.shared.appOpened(userActivity: userActivity)
            }
            return ThreeDSSDKAppDelegate.shared.appOpened(url: event.url)
        }
    }
}
