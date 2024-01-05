//
//  DefaultThreeDSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

final class DefaultThreeDSService: ThreeDSService {

    init(
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        jsonWritingOptions: JSONSerialization.WritingOptions = [],
        logger: POLogger
    ) {
        self.decoder = decoder
        self.encoder = encoder
        self.jsonWritingOptions = jsonWritingOptions
        self.logger = logger
    }

    // MARK: - ThreeDSService

    func handle(action: ThreeDSCustomerAction, delegate: Delegate) async throws -> String {
        do {
            switch action.type {
            case .fingerprintMobile:
                return try await fingerprint(encodedConfiguration: action.value, delegate: delegate)
            case .challengeMobile:
                return try await challenge(encodedChallenge: action.value, delegate: delegate)
            case .fingerprint:
                return try await fingerprint(url: action.value, delegate: delegate)
            case .redirect, .url:
                return try await redirect(url: action.value, delegate: delegate)
            }
        } catch {
            // todo(andrii-vysotskyi): when async delegate methods are publically available ensure
            // that thrown errors are mapped to POFailure if needed.
            logger.debug("Failed to handle 3DS action: \(error)")
            throw error
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let deviceChannel = "app"
        static let tokenPrefix = "gway_req_"
        static let challengeSuccessEncodedResponse = "eyJib2R5IjoieyBcInRyYW5zU3RhdHVzXCI6IFwiWVwiIH0ifQ=="
        static let challengeFailureEncodedResponse = "eyJib2R5IjoieyBcInRyYW5zU3RhdHVzXCI6IFwiTlwiIH0ifQ=="
        static let fingerprintTimeoutResponseBody = #"{ "threeDS2FingerprintTimeout": true }"#
        static let webFingerprintTimeout: TimeInterval = 10
    }

    private struct ChallengeResponse: Encodable {
        let url: URL?
        let body: String
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let jsonWritingOptions: JSONSerialization.WritingOptions
    private let logger: POLogger

    // MARK: - Private Methods

    private func fingerprint(encodedConfiguration: String, delegate: Delegate) async throws -> String {
        let configuration = try decode(PO3DS2Configuration.self, from: encodedConfiguration)
        let request = try await delegate.authenticationRequest(configuration: configuration)
        let response = ChallengeResponse(url: nil, body: try self.encode(request: request))
        return try encode(challengeResponse: response)
    }

    private func challenge(encodedChallenge: String, delegate: Delegate) async throws -> String {
        let challenge = try decode(PO3DS2Challenge.self, from: encodedChallenge)
        let success = try await delegate.handle(challenge: challenge)
        let encodedResponse = success
            ? Constants.challengeSuccessEncodedResponse
            : Constants.challengeFailureEncodedResponse
        return Constants.tokenPrefix + encodedResponse
    }

    private func fingerprint(url: String, delegate: Delegate) async throws -> String {
        guard let url = URL(string: url) else {
            logger.error("Did fail to create fingerprint URL from raw value: '\(url)'.")
            throw POFailure(message: nil, code: .internal(.mobile), underlyingError: nil)
        }
        let context = PO3DSRedirect(url: url, timeout: Constants.webFingerprintTimeout)
        do {
            return try await delegate.handle(redirect: context)
        } catch let failure as POFailure where failure.code == .timeout(.mobile) {
            // Fingerprinting timeout is treated differently from other errors.
            let response = ChallengeResponse(url: url, body: Constants.fingerprintTimeoutResponseBody)
            return try encode(challengeResponse: response)
        }
    }

    private func redirect(url: String, delegate: Delegate) async throws -> String {
        guard let url = URL(string: url) else {
            logger.error("Did fail to create redirect URL from raw value: '\(url)'.")
            throw POFailure(message: nil, code: .internal(.mobile), underlyingError: nil)
        }
        let context = PO3DSRedirect(url: url, timeout: nil)
        return try await delegate.handle(redirect: context)
    }

    // MARK: - Coding

    private func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        let paddedString = string.padding(
            toLength: string.count + (4 - string.count % 4) % 4, withPad: "=", startingAt: 0
        )
        guard let data = Data(base64Encoded: paddedString) else {
            logger.error("Did fail to decode base64 string.")
            throw POFailure(message: "Invalid base64 encoding.", code: .internal(.mobile))
        }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            logger.error("Did fail to decode given type: \(error)")
            throw POFailure(code: .internal(.mobile), underlyingError: error)
        }
    }

    private func encode(request: PO3DS2AuthenticationRequest) throws -> String {
        do {
            // Using JSONSerialization helps avoid creating boilerplate objects for JSON Web Key for coding.
            // Implementation doesn't validate JWK correctness and simply re-encodes given value.
            let sdkEphemeralPublicKey = try JSONSerialization.jsonObject(
                with: Data(request.sdkEphemeralPublicKey.utf8)
            )
            let requestParameters = [
                "deviceChannel": Constants.deviceChannel,
                "sdkAppID": request.sdkAppId,
                "sdkEphemPubKey": sdkEphemeralPublicKey,
                "sdkReferenceNumber": request.sdkReferenceNumber,
                "sdkTransID": request.sdkTransactionId,
                "sdkEncData": request.deviceData
            ]
            let requestParametersData = try JSONSerialization.data(
                withJSONObject: requestParameters, options: jsonWritingOptions
            )
            return String(decoding: requestParametersData, as: UTF8.self)
        } catch {
            logger.error("Did fail to encode authentication request: \(error)")
            throw POFailure(code: .internal(.mobile), underlyingError: error)
        }
    }

    // MARK: - Utils

    /// Encodes given response and creates token with it.
    private func encode(challengeResponse: ChallengeResponse) throws -> String {
        do {
            return try Constants.tokenPrefix + encoder.encode(challengeResponse).base64EncodedString()
        } catch {
            logger.error("Did fail to encode fingerprint: '\(error)'.")
            throw POFailure(message: nil, code: .internal(.mobile), underlyingError: error)
        }
    }
}
