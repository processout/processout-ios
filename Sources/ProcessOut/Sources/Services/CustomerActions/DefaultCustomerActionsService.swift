//
//  DefaultCustomerActionsService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

final class DefaultCustomerActionsService: CustomerActionsService {

    init(
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        jsonWritingOptions: JSONSerialization.WritingOptions = [],
        webSession: WebAuthenticationSession,
        logger: POLogger
    ) {
        self.decoder = decoder
        self.encoder = encoder
        self.jsonWritingOptions = jsonWritingOptions
        self.webSession = webSession
        self.logger = logger
        semaphore = .init(value: 1)
    }

    // MARK: - CustomerActionsService

    func handle(
        action: _CustomerAction, threeDSService: PO3DS2Service, webAuthenticationCallback: POWebAuthenticationCallback?
    ) async throws -> String {
        do {
            try await semaphore.waitUnlessCancelled()
        } catch {
            throw POFailure(message: "Customer action handling was cancelled.", code: .cancelled)
        }
        defer {
            semaphore.signal()
        }
        do {
            switch action.type {
            case .fingerprintMobile:
                return try await fingerprint(encodedConfiguration: action.value, threeDSService: threeDSService)
            case .challengeMobile:
                return try await challenge(encodedChallenge: action.value, threeDSService: threeDSService)
            case .fingerprint:
                return try await fingerprint(url: action.value, callback: webAuthenticationCallback)
            case .redirect, .url:
                return try await redirect(url: action.value, callback: webAuthenticationCallback)
            }
        } catch let error as POFailure {
            throw error
        } catch {
            throw POFailure(message: "Can't process customer action.", code: .generic(.mobile), underlyingError: error)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let deviceChannel = "app"
        static let tokenPrefix = "gway_req_"
        static let fingerprintTimeoutResponseBody = #"{ "threeDS2FingerprintTimeout": true }"#
        static let webFingerprintTimeout: TimeInterval = 10
    }

    private struct AuthenticationResponse: Encodable {
        let url: URL?
        let body: String
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let jsonWritingOptions: JSONSerialization.WritingOptions
    private let webSession: WebAuthenticationSession
    private let logger: POLogger
    private let semaphore: AsyncSemaphore

    // MARK: - Native 3DS

    private func fingerprint(encodedConfiguration: String, threeDSService: PO3DS2Service) async throws -> String {
        let configuration = try decode(PO3DS2Configuration.self, from: encodedConfiguration)
        let requestParameters = try await threeDSService.authenticationRequestParameters(configuration: configuration)
        let response = AuthenticationResponse(url: nil, body: try self.encode(requestParameters: requestParameters))
        return try encode(authenticationResponse: response)
    }

    private func challenge(encodedChallenge: String, threeDSService: PO3DS2Service) async throws -> String {
        let parameters = try decode(PO3DS2ChallengeParameters.self, from: encodedChallenge)
        let result = try await threeDSService.performChallenge(with: parameters)
        let encodedChallengeResult: String
        do {
            encodedChallengeResult = try String(decoding: encoder.encode(result), as: UTF8.self)
        } catch {
            logger.error("Did fail to encode CRES: \(error).")
            throw POFailure(message: "Can't process customer action.", code: .internal(.mobile), underlyingError: error)
        }
        let response = AuthenticationResponse(url: nil, body: encodedChallengeResult)
        return try encode(authenticationResponse: response)
    }

    // MARK: - Redirects

    private func fingerprint(url: String, callback: POWebAuthenticationCallback?) async throws -> String {
        guard let url = URL(string: url) else {
            logger.error("Unable to create URL from string: \(url).")
            throw POFailure(message: "Can't process customer action.", code: .internal(.mobile), underlyingError: nil)
        }
        do {
            let timeoutError = POFailure(
                message: "Unable to complete device fingerprinting within the expected time.", code: .timeout(.mobile)
            )
            return try await withTimeout(Constants.webFingerprintTimeout, error: timeoutError) {
                try await self.redirect(url: url.absoluteString, callback: callback)
            }
        } catch let failure as POFailure where failure.code == .timeout(.mobile) {
            // Fingerprinting timeout is treated differently from other errors.
            let response = AuthenticationResponse(url: url, body: Constants.fingerprintTimeoutResponseBody)
            return try encode(authenticationResponse: response)
        }
    }

    private func redirect(url: String, callback: POWebAuthenticationCallback?) async throws -> String {
        guard let url = URL(string: url) else {
            logger.error("Unable to create URL from string: \(url).")
            throw POFailure(message: "Can't process customer action.", code: .internal(.mobile), underlyingError: nil)
        }
        let returnUrl = try await self.webSession.authenticate(using: .init(url: url, callback: callback))
        let queryItems = URLComponents(string: returnUrl.absoluteString)?.queryItems
        return queryItems?.first { $0.name == "token" }?.value ?? ""
    }

    // MARK: - Coding

    private func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        let paddedString = string.padding(
            toLength: string.count + (4 - string.count % 4) % 4, withPad: "=", startingAt: 0
        )
        guard let data = Data(base64Encoded: paddedString) else {
            logger.error("Failed to decode customer action: invalid base64 payload.")
            throw POFailure(message: "Can't process customer action.", code: .internal(.mobile))
        }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            logger.error("Unable to decode customer action: \(error).")
            throw POFailure(message: "Can't process customer action.", code: .internal(.mobile), underlyingError: error)
        }
    }

    private func encode(requestParameters parameters: PO3DS2AuthenticationRequestParameters) throws -> String {
        do {
            // Using JSONSerialization helps avoid creating boilerplate objects for JSON Web Key for coding.
            // Implementation doesn't validate JWK correctness and simply re-encodes given value.
            let sdkEphemeralPublicKey = try JSONSerialization.jsonObject(
                with: Data(parameters.sdkEphemeralPublicKey.utf8)
            )
            let requestParameters = [
                "deviceChannel": Constants.deviceChannel,
                "sdkAppID": parameters.sdkAppId,
                "sdkEphemPubKey": sdkEphemeralPublicKey,
                "sdkReferenceNumber": parameters.sdkReferenceNumber,
                "sdkTransID": parameters.sdkTransactionId,
                "sdkEncData": parameters.deviceData
            ]
            let requestParametersData = try JSONSerialization.data(
                withJSONObject: requestParameters, options: jsonWritingOptions
            )
            return String(decoding: requestParametersData, as: UTF8.self)
        } catch {
            logger.error("Did fail to encode AREQ parameters: \(error).")
            throw POFailure(message: "Can't process customer action.", code: .internal(.mobile), underlyingError: error)
        }
    }

    /// Encodes given response and creates token with it.
    private func encode(authenticationResponse: AuthenticationResponse) throws -> String {
        do {
            return try Constants.tokenPrefix + encoder.encode(authenticationResponse).base64EncodedString()
        } catch {
            logger.error("Did fail to encode AREQ parameters or CRES: \(error).")
            throw POFailure(message: "Can't process customer action.", code: .internal(.mobile), underlyingError: error)
        }
    }
}
