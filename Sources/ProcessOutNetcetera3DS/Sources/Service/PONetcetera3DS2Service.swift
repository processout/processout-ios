//
//  PONetcetera3DS2Service.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.04.2025.
//

@_spi(PO) import ProcessOut
@_spi(PO) import NetceteraShim
import ThreeDS_SDK

/// A concrete implementation of `PO3DS2Service` using the Netcetera 3DS SDK.
public actor PONetcetera3DS2Service: PO3DS2Service {

    /// Creates a new instance of `PONetcetera3DS2Service`.
    public init(
        configuration: PONetcetera3DS2ServiceConfiguration = .init(),
        delegate: PONetcetera3DS2ServiceDelegate? = nil
    ) {
        self.eventEmitter = ProcessOut.shared.eventEmitter
        self.configuration = configuration
        self.delegate = delegate
    }

    /// Service's delegate.
    public weak var delegate: PONetcetera3DS2ServiceDelegate?

    // MARK: - PO3DS2Service

    /// Returns the version of the 3DS SDK that is integrated with the 3DS Requestor App.
    public nonisolated var version: String? {
        "2.5.2.2"
    }

    public func authenticationRequestParameters(
        configuration: PO3DS2Configuration
    ) async throws -> PO3DS2AuthenticationRequestParameters {
        try await Self.authenticationSemaphore.waitUnlessCancelled(
            cancellationError: POFailure(message: "Authentication was cancelled.", code: .Mobile.cancelled)
        )
        shouldSignalAuthenticationSemaphoreAfterClean = true
        try await executionSemaphore.waitUnlessCancelled(
            cancellationError: POFailure(message: "Authentication was cancelled.", code: .Mobile.cancelled)
        )
        defer {
            executionSemaphore.signal()
        }
        guard transaction == nil else {
            throw POFailure(message: "Another authentication is already in progress.", code: .Mobile.generic)
        }
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
        self.transactionId = configuration.directoryServerTransactionId
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
        try await executionSemaphore.waitUnlessCancelled(
            cancellationError: POFailure(message: "Challenge was cancelled.", code: .Mobile.cancelled)
        )
        defer {
            executionSemaphore.signal()
        }
        guard let transaction, transactionId == parameters.threeDSServerTransactionId else {
            throw POFailure(message: "Unable to resolve current transaction.", code: .Mobile.internal)
        }
        var presentingViewController = await PresentingViewControllerProvider.find()
        await delegate?.netcetera3DS2Service(
            self, willPerformChallengeOn: &presentingViewController
        )
        guard let presentingViewController  else {
            throw POFailure(message: "Unable to prepare presentation context.", code: .Mobile.generic)
        }
        try await MainActor.run {
            // Workaround to prevent Netcetera from modifing UI from background thread
            try transaction.getProgressView().start()
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
        await executionSemaphore.wait()
        if let transaction {
            await MainActor.run {
                try? transaction.getProgressView().stop()
            }
            try? transaction.close()
            self.transaction = nil
        }
        transactionId = nil
        if let service {
            try? service.cleanup()
            self.service = nil
        }
        deepLinkObservation = nil
        if shouldSignalAuthenticationSemaphoreAfterClean {
            shouldSignalAuthenticationSemaphoreAfterClean = false
            Self.authenticationSemaphore.signal()
        }
        executionSemaphore.signal()
    }

    // MARK: -

    init(
        configuration: PONetcetera3DS2ServiceConfiguration = .init(),
        delegate: PONetcetera3DS2ServiceDelegate? = nil,
        eventEmitter: POEventEmitter
    ) {
        self.eventEmitter = eventEmitter
        self.configuration = configuration
        self.delegate = delegate
        self.service = .init()
    }

    // MARK: - Private Properties

    private let configuration: PONetcetera3DS2ServiceConfiguration, eventEmitter: POEventEmitter
    private var service: ThreeDS2ServiceSDK?, transaction: Transaction?, transactionId: String?

    /// A semaphore used to ensure that only one method of this object runs at a time,
    /// providing atomic-like behavior.
    private let executionSemaphore = AsyncSemaphore(value: 1)

    /// The Netcetera SDK, while allowing multiple instances, appears to have shared state issues
    /// that can lead to incorrect behavior during concurrent authentication requests.
    ///
    /// This semaphore acts as a workaround to ensure that only one authentication process is
    /// executed at a time, effectively enforcing singleton-like behavior.
    private static let authenticationSemaphore = AsyncSemaphore(value: 1)
    private var shouldSignalAuthenticationSemaphoreAfterClean = false // swiftlint:disable:this identifier_name

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
            if case .compatibility = self.configuration.authenticationMode {
                // Restrict parameters known to produce large values to maintain compatibility with payment
                // providers that enforce size limits on the authentication request payload (e.g., Stripe
                // limits payload to 5000 characters).
                //
                // - I003: Available font families
                // - I011: Available locale identifiers
                try builder.restrictedParameters(["I003", "I011"])
            }
            try builder.log(to: .error)
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
        let encryption: String, encryptionKeyId: String?
        do {
            let jwk = try JwkDecoder().decode(from: configuration.directoryServerPublicKey)
            if let certificate = jwk.x5c?.first {
                encryption = certificate
            } else {
                let asn = try JwkAsnEncoder().encode(jwk)
                encryption = AsnDerEncoder().encode(asn).base64EncodedString()
            }
            encryptionKeyId = jwk.kid
        } catch {
            throw POFailure(
                message: "Unable to encode directory server public key.", code: .Mobile.generic, underlyingError: error
            )
        }
        var roots: [String]?
        if !configuration.directoryServerRootCertificates.isEmpty {
            roots = configuration.directoryServerRootCertificates.map(\.base64WithFixedPadding)
        }
        let scheme = Scheme(
            name: configuration.$scheme.typed()?.rawValue ?? "<unknown>",
            ids: [configuration.directoryServerId],
            logoImageName: nil,
            encryption: encryption,
            encryptionKeyId: encryptionKeyId,
            roots: roots
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
