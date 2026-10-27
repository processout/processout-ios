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
///
/// 3DS flow is strictly sequential: an authentication, optionally followed by a challenge, and
/// `clean()` at the end. The service does not serialize concurrent calls. Overlapping operations
/// are considered a developer error and are rejected.
///
/// The Netcetera SDK does not tolerate concurrent use, so only one authentication should be
/// running at a time across all instances of this service.
public actor PONetcetera3DS2Service: PO3DS2Service {

    /// Creates a new instance of `PONetcetera3DS2Service`.
    public init(
        configuration: PONetcetera3DS2ServiceConfiguration = .init(),
        delegate: PONetcetera3DS2ServiceDelegate? = nil
    ) {
        self.eventEmitter = ProcessOut.shared.eventEmitter
        self.logger = ProcessOut.shared.logger
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
        if Task.isCancelled {
            throw POFailure(message: "Authentication was cancelled.", code: .Mobile.cancelled)
        }
        switch state {
        case .idle:
            break
        case .ready:
            throw POFailure(message: "Previous transaction was not cleaned, call clean() first.", code: .Mobile.generic)
        case .authenticating, .challenging, .cleaning:
            throw POFailure(message: "Another operation is already in progress.", code: .Mobile.generic)
        }
        state = .authenticating
        do {
            let (context, parameters) = try await createTransaction(configuration: configuration)
            state = .ready(context)
            return parameters
        } catch {
            state = .idle
            throw error
        }
    }

    public func performChallenge(
        with parameters: PO3DS2ChallengeParameters
    ) async throws -> PO3DS2ChallengeResult {
        if Task.isCancelled {
            throw POFailure(message: "Challenge was cancelled.", code: .Mobile.cancelled)
        }
        guard case .ready(let context) = state,
              context.transactionId == parameters.threeDSServerTransactionId else {
            throw POFailure(message: "Unable to resolve current transaction.", code: .Mobile.generic)
        }
        state = .challenging(context)
        defer {
            state = .ready(context)
        }
        return try await performChallenge(with: parameters, in: context)
    }

    public func clean() async {
        switch state {
        case .idle:
            break
        case .ready(let context):
            state = .cleaning
            await tearDown(service: context.service, transaction: context.transaction)
            deepLinkObservation = nil
            state = .idle
        case .authenticating, .challenging, .cleaning:
            logger.warn("Ignoring clean() while another operation is in progress.")
        }
    }

    // MARK: -

    init(
        configuration: PONetcetera3DS2ServiceConfiguration = .init(),
        delegate: PONetcetera3DS2ServiceDelegate? = nil,
        eventEmitter: POEventEmitter,
        logger: POLogger
    ) {
        self.eventEmitter = eventEmitter
        self.logger = logger
        self.configuration = configuration
        self.delegate = delegate
    }

    // MARK: - Private Nested Types

    private enum State {

        /// No transaction. The only state from which authentication may start.
        case idle

        /// Authentication request parameters are being created.
        case authenticating

        /// Transaction exists and may be challenged or cleaned.
        case ready(TransactionContext)

        /// Challenge is being performed on the transaction.
        case challenging(TransactionContext)

        /// Transaction is being closed and SDK resources are being released.
        case cleaning
    }

    private struct TransactionContext {
        let service: ThreeDS2ServiceSDK, transaction: Transaction, transactionId: String
    }

    // MARK: - Private Properties

    private let configuration: PONetcetera3DS2ServiceConfiguration
    private let eventEmitter: POEventEmitter, logger: POLogger

    private var state: State = .idle
    private var deepLinkObservation: AnyObject?

    // MARK: - Authentication

    /// Initializes the SDK and creates a transaction. Resources created before a failure are
    /// released here, so a failed authentication leaves nothing behind to clean.
    private func createTransaction(
        configuration: PO3DS2Configuration
    ) async throws -> (TransactionContext, PO3DS2AuthenticationRequestParameters) {
        var initializedService: ThreeDS2ServiceSDK?, createdTransaction: Transaction?
        do {
            let service = ThreeDS2ServiceSDK()
            try await service.initialize(
                try configurationParameters(with: configuration),
                locale: self.configuration.locale?.identifier,
                uiCustomization: self.configuration.uiCustomizationsV2
            )
            initializedService = service
            let transaction = try await service.createTransaction(
                directoryServerId: configuration.directoryServerId, messageVersion: configuration.messageVersion
            )
            createdTransaction = transaction
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
            let context = TransactionContext(
                service: service, transaction: transaction, transactionId: configuration.directoryServerTransactionId
            )
            return (context, PO3DS2AuthenticationRequestParameters(parameters: parameters))
        } catch {
            await tearDown(service: initializedService, transaction: createdTransaction)
            throw error
        }
    }

    // MARK: - Challenge

    private func performChallenge(
        with parameters: PO3DS2ChallengeParameters, in context: TransactionContext
    ) async throws -> PO3DS2ChallengeResult {
        var presentingViewController = await PresentingViewControllerProvider.find()
        await delegate?.netcetera3DS2Service(
            self, willPerformChallengeOn: &presentingViewController
        )
        guard let presentingViewController  else {
            throw POFailure(message: "Unable to prepare presentation context.", code: .Mobile.generic)
        }
        try await MainActor.run {
            // Workaround to prevent Netcetera from modifing UI from background thread
            try context.transaction.getProgressView().start()
        }
        let challengeParameters = ChallengeParameters(parameters: parameters)
        if let returnUrl = configuration.returnUrl {
            setReturnUrl(returnUrl, in: challengeParameters, transactionId: parameters.threeDSServerTransactionId)
        }
        let challengeStatus = try await context.transaction.doChallenge(
            challengeParameters: challengeParameters,
            timeout: Int(configuration.challengeTimeout / 60),
            in: presentingViewController
        )
        return try .init(status: challengeStatus)
    }

    // MARK: - Clean

    private func tearDown(service: ThreeDS2ServiceSDK?, transaction: Transaction?) async {
        if let transaction {
            await MainActor.run {
                try? transaction.getProgressView().stop()
            }
            try? await transaction.close()
        }
        if let service {
            try? await service.cleanup()
        }
    }

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
            try builder.log(to: self.configuration.logLevel)
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

    private func setReturnUrl(_ returnUrl: URL, in challengeParameters: ChallengeParameters, transactionId: String) {
        guard var components = URLComponents(url: returnUrl, resolvingAgainstBaseURL: false) else {
            return
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(.init(name: "transID", value: transactionId))
        components.queryItems = queryItems
        guard let threeDSRequestorAppURL = components.url else {
            return
        }
        challengeParameters.setThreeDSRequestorAppURL(threeDSRequestorAppURL: threeDSRequestorAppURL.absoluteString)
        observeDeepLinks()
    }

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
