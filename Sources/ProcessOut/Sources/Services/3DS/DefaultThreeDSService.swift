//
//  DefaultThreeDSService.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

@MainActor
final class DefaultThreeDSService: ThreeDSService {

    nonisolated init(
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        jsonWritingOptions: JSONSerialization.WritingOptions = [],
        webSession: WebAuthenticationSession
    ) {
        self.decoder = decoder
        self.encoder = encoder
        self.jsonWritingOptions = jsonWritingOptions
        self.webSession = webSession
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
                return try await fingerprint(url: action.value)
            case .redirect, .url:
                return try await redirect(url: action.value)
            }
        } catch let error as POFailure {
            throw error
        } catch {
            throw POFailure(code: .generic(.mobile), underlyingError: error)
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

    private struct AuthenticationResponse: Encodable {
        let url: URL?
        let body: String
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let jsonWritingOptions: JSONSerialization.WritingOptions
    private let webSession: WebAuthenticationSession

    // MARK: - Native 3DS

    private func fingerprint(encodedConfiguration: String, delegate: Delegate) async throws -> String {
        let configuration = try decode(PO3DS2Configuration.self, from: encodedConfiguration)
        let request = try await delegate.authenticationRequest(configuration: configuration)
        let response = AuthenticationResponse(url: nil, body: try self.encode(request: request))
        return try encode(authenticationResponse: response)
    }

    private func challenge(encodedChallenge: String, delegate: Delegate) async throws -> String {
        let challenge = try decode(PO3DS2Challenge.self, from: encodedChallenge)
        let success = try await delegate.handle(challenge: challenge)
        let encodedResponse = success
            ? Constants.challengeSuccessEncodedResponse
            : Constants.challengeFailureEncodedResponse
        return Constants.tokenPrefix + encodedResponse
    }

    // MARK: - Web Based 3DS

    private func fingerprint(url: String) async throws -> String {
        guard let url = URL(string: url) else {
            let message = "Unable to create URL from string: \(url)."
            throw POFailure(message: message, code: .internal(.mobile), underlyingError: nil)
        }
        do {
            return try await handle(url: url, timeout: Constants.webFingerprintTimeout)
        } catch let failure as POFailure where failure.code == .timeout(.mobile) {
            // Fingerprinting timeout is treated differently from other errors.
            let response = AuthenticationResponse(url: url, body: Constants.fingerprintTimeoutResponseBody)
            return try encode(authenticationResponse: response)
        }
    }

    private func redirect(url: String) async throws -> String {
        guard let url = URL(string: url) else {
            let message = "Unable to create URL from string: \(url)."
            throw POFailure(message: message, code: .internal(.mobile), underlyingError: nil)
        }
        return try await handle(url: url, timeout: .greatestFiniteMagnitude)
    }

    private func handle(url: URL, timeout: TimeInterval) async throws -> String {
        let url = try await withTimeout(
            timeout,
            error: POFailure(code: .timeout(.mobile)),
            perform: {
                try await self.webSession.authenticate(using: url)
            }
        )
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        return queryItems?.first { $0.name == "token" }?.value ?? ""
    }

    // MARK: - Coding

    private func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        let paddedString = string.padding(
            toLength: string.count + (4 - string.count % 4) % 4, withPad: "=", startingAt: 0
        )
        guard let data = Data(base64Encoded: paddedString) else {
            throw POFailure(message: "Invalid base64 encoding.", code: .internal(.mobile))
        }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            let message = "Did fail to decode given type."
            throw POFailure(message: message, code: .internal(.mobile), underlyingError: error)
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
            let message = "Did fail to encode AREQ parameters."
            throw POFailure(message: message, code: .internal(.mobile), underlyingError: error)
        }
    }

    /// Encodes given response and creates token with it.
    private func encode(authenticationResponse: AuthenticationResponse) throws -> String {
        do {
            return try Constants.tokenPrefix + encoder.encode(authenticationResponse).base64EncodedString()
        } catch {
            let message = "Did fail to encode AREQ parameters."
            throw POFailure(message: message, code: .internal(.mobile), underlyingError: error)
        }
    }
}
