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

    func handle(request: CustomerActionRequest, threeDSService: PO3DS2Service) async throws -> String {
        try await semaphore.waitUnlessCancelled(
            cancellationError: POFailure(message: "Customer action handling was cancelled.", code: .Mobile.cancelled)
        )
        defer {
            semaphore.signal()
        }
        do {
            switch request.customerAction.type {
            case .fingerprintMobile:
                return try await fingerprint(
                    encodedConfiguration: request.customerAction.value, threeDSService: threeDSService
                )
            case .challengeMobile:
                return try await challenge(
                    encodedChallenge: request.customerAction.value, threeDSService: threeDSService
                )
            case .fingerprint:
                return try await fingerprint(
                    url: request.customerAction.value, callback: request.webAuthenticationCallback
                )
            case .redirect, .url:
                return try await redirect(
                    url: request.customerAction.value,
                    callback: request.webAuthenticationCallback,
                    prefersEphemeralSession: request.prefersEphemeralWebAuthenticationSession
                )
            }
        } catch let error as POFailure {
            throw error
        } catch {
            throw POFailure(message: "Can't process customer action.", code: .Mobile.generic, underlyingError: error)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let deviceChannel = "app"
        static let gatewayRequestPrefix = "gway_req_"
        static let fingerprintTimeoutGatewayRequestBody = #"{ "threeDS2FingerprintTimeout": true }"#
        static let webFingerprintTimeout: TimeInterval = 10
    }

    private struct GatewayRequest: Encodable {
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
        let gatewayRequest = GatewayRequest(url: nil, body: try self.encode(requestParameters: requestParameters))
        return try encode(gatewayRequest: gatewayRequest)
    }

    private func challenge(encodedChallenge: String, threeDSService: PO3DS2Service) async throws -> String {
        let parameters = try decode(PO3DS2ChallengeParameters.self, from: encodedChallenge)
        let result = try await threeDSService.performChallenge(with: parameters)
        let encodedChallengeResult: String
        do {
            encodedChallengeResult = try String(decoding: encoder.encode(result), as: UTF8.self)
        } catch {
            logger.error("Did fail to encode CRES: \(error).")
            throw POFailure(message: "Can't process customer action.", code: .Mobile.internal, underlyingError: error)
        }
        let gatewayRequest = GatewayRequest(url: nil, body: encodedChallengeResult)
        return try encode(gatewayRequest: gatewayRequest)
    }

    // MARK: - Redirects

    private func fingerprint(url: String, callback: POWebAuthenticationCallback?) async throws -> String {
        guard let url = URL(string: url) else {
            logger.error("Unable to create URL from string: \(url).")
            throw POFailure(message: "Can't process customer action.", code: .Mobile.internal, underlyingError: nil)
        }
        do {
            let timeoutError = POFailure(
                message: "Unable to complete device fingerprinting within the expected time.", code: .Mobile.timeout
            )
            return try await withTimeout(Constants.webFingerprintTimeout, error: timeoutError) {
                try await self.redirect(url: url.absoluteString, callback: callback, prefersEphemeralSession: true)
            }
        } catch let failure as POFailure where failure.failureCode == .Mobile.timeout {
            // Fingerprinting timeout is treated differently from other errors.
            let gatewayRequest = GatewayRequest(url: url, body: Constants.fingerprintTimeoutGatewayRequestBody)
            return try encode(gatewayRequest: gatewayRequest)
        }
    }

    private func redirect(
        url: String, callback: POWebAuthenticationCallback?, prefersEphemeralSession: Bool
    ) async throws -> String {
        guard let url = URL(string: url) else {
            logger.error("Unable to create URL from string: \(url).")
            throw POFailure(message: "Can't process customer action.", code: .Mobile.internal, underlyingError: nil)
        }
        let returnUrl = try await self.webSession.authenticate(
            using: .init(url: url, callback: callback, prefersEphemeralSession: prefersEphemeralSession)
        )
        let queryItems = URLComponents(string: returnUrl.absoluteString)?.queryItems
        return queryItems?.first { $0.name == "token" }?.value ?? ""
    }

    // MARK: - Decoding

    private func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        let paddedString = string.padding(
            toLength: string.count + (4 - string.count % 4) % 4, withPad: "=", startingAt: 0
        )
        guard let data = Data(base64Encoded: paddedString) else {
            logger.error("Failed to decode customer action: invalid base64 payload.")
            throw POFailure(message: "Can't process customer action.", code: .Mobile.internal)
        }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            logger.error("Unable to decode customer action: \(error).")
            throw POFailure(message: "Can't process customer action.", code: .Mobile.internal, underlyingError: error)
        }
    }

    // MARK: - Encoding

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
            throw POFailure(message: "Can't process customer action.", code: .Mobile.internal, underlyingError: error)
        }
    }

    private func encode(gatewayRequest: GatewayRequest) throws -> String {
        do {
            return try Constants.gatewayRequestPrefix + encoder.encode(gatewayRequest).base64EncodedString()
        } catch {
            logger.error("Did fail to encode gateway request: \(error).")
            throw POFailure(message: "Can't process customer action.", code: .Mobile.internal, underlyingError: error)
        }
    }
}
