//
//  ThreeDSHandler.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

final class ThreeDSService: ThreeDSServiceType {

    init(decoder: JSONDecoder, encoder: JSONEncoder, logger: POLogger) {
        self.decoder = decoder
        self.encoder = encoder
        self.logger = logger
    }

    // MARK: - ThreeDSCustomerActionHandlerType

    func handle(action: ThreeDSCustomerAction, handler: PO3DSServiceType, completion: @escaping Completion) {
        let completionTrampoline: Completion = { result in
            assert(Thread.isMainThread, "Completion must be called on main thread!")
            completion(result)
        }
        switch action.type {
        case .fingerprintMobile:
            fingerprint(encodedDirectoryServerData: action.value, handler: handler, completion: completionTrampoline)
        case .challengeMobile:
            challenge(encodedChallengeData: action.value, handler: handler, completion: completionTrampoline)
        case .fingerprint:
            fingerprint(url: action.value, handler: handler, completion: completionTrampoline)
        case .redirect, .url:
            redirect(url: action.value, handler: handler, completion: completionTrampoline)
        }
    }

    // MARK: - Private Nested Types

    private struct FingerprintResponse: Encodable {
        let url: URL?
        let headers: [String: String]?
        let body: String
    }

    // MARK: - Private Properties

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let logger: POLogger

    // MARK: - Private Methods

    private func fingerprint(
        encodedDirectoryServerData: String, handler: PO3DSServiceType, completion: @escaping Completion
    ) {
        do {
            let configuration = try decode(PO3DS2Configuration.self, from: encodedDirectoryServerData)
            handler.authenticationRequest(configuration: configuration) { [encoder, logger] result in
                switch result {
                case let .success(request):
                    do {
                        let response = FingerprintResponse(
                            url: nil, headers: nil, body: try self.encode(request: request)
                        )
                        let encodedResponse = String(
                            decoding: try encoder.encode(response).base64EncodedData(), as: UTF8.self
                        )
                        completion(.success("gway_req_" + encodedResponse))
                    } catch {
                        logger.error("Did fail to encode fingerprint: '\(error.localizedDescription)'.")
                        completion(.failure(.init(message: nil, code: .internal(.mobile), underlyingError: error)))
                    }
                case let .failure(failure):
                    completion(.failure(failure))
                }
            }
        } catch let error as POFailure {
            logger.error("Did fail to decode DS data: '\(error.message ?? "")'.")
            completion(.failure(error))
        } catch {
            logger.error("Did fail to decode DS data: '\(error.localizedDescription)'.")
            completion(.failure(.init(code: .internal(.mobile), underlyingError: error)))
        }
    }

    private func challenge(
        encodedChallengeData: String, handler: PO3DSServiceType, completion: @escaping Completion
    ) {
        do {
            let challenge = try decode(PO3DS2Challenge.self, from: encodedChallengeData)
            handler.perform(challenge: challenge) { result in
                switch result {
                case let .success(success):
                    let newSource = success
                        ? "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIllcIn0ifQ=="
                        : "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIk5cIn0ifQ=="
                    completion(.success(newSource))
                case let .failure(failure):
                    completion(.failure(failure))
                }
            }
        } catch {
            logger.error("Did fail to decode challenge data: '\(error.localizedDescription)'.")
            completion(.failure(.init(code: .internal(.mobile), underlyingError: error)))
        }
    }

    private func fingerprint(url: String, handler: PO3DSServiceType, completion: @escaping Completion) {
        guard let url = URL(string: url) else {
            logger.error("Did fail to create fingerprint URL from raw value: '\(url)'.")
            completion(.failure(.init(message: nil, code: .internal(.mobile), underlyingError: nil)))
            return
        }
        let context = PO3DSRedirectContext(url: url, isHeadlessModeAllowed: true, timeout: 10)
        handler.redirect(context: context) { [encoder, logger] result in
            switch result {
            case let .success(newSource):
                completion(.success(newSource))
            case let .failure(failure) where failure.code == .timeout(.mobile):
                // Fingerprinting timeout error is treated differently from other actions.
                do {
                    let response = FingerprintResponse(
                        url: url,
                        headers: ["Content-Type": "application/json"],
                        body: #"{ "threeDS2FingerprintTimeout": true }"#
                    )
                    let responseDataString = String(
                        decoding: try encoder.encode(response).base64EncodedData(), as: UTF8.self
                    )
                    completion(.success("gway_req_" + responseDataString))
                } catch {
                    logger.error("Did fail to encode fingerprint: '\(error.localizedDescription)'.")
                    completion(.failure(.init(message: nil, code: .internal(.mobile), underlyingError: error)))
                }
            case let .failure(failure):
                completion(.failure(failure))
            }
        }
    }

    private func redirect(url: String, handler: PO3DSServiceType, completion: @escaping Completion) {
        guard let url = URL(string: url) else {
            logger.error("Did fail to create redirect URL from raw value: '\(url)'.")
            completion(.failure(.init(message: nil, code: .internal(.mobile), underlyingError: nil)))
            return
        }
        let context = PO3DSRedirectContext(url: url, isHeadlessModeAllowed: false, timeout: nil)
        handler.redirect(context: context, completion: completion)
    }

    // MARK: - Utils

    private func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        let paddedString = string.padding(
            toLength: string.count + (4 - string.count % 4) % 4, withPad: "=", startingAt: 0
        )
        guard let data = Data(base64Encoded: paddedString) else {
            throw POFailure(message: "Invalid base64 encoding.", code: .internal(.mobile))
        }
        return try decoder.decode(type, from: data)
    }

    private func encode(request: PO3DS2AuthenticationRequest) throws -> String {
        // Using JSONSerialization helps avoid creating boilerplate objects for JSON Web Key coding. Implementation
        // doesn't validate JWK correctness and simply re-encodes given value.
        let sdkEphemeralPublicKey = try JSONSerialization.jsonObject(
            with: Data(request.sdkEphemeralPublicKey.utf8)
        )
        var requestParameters = [
            "deviceChannel": "app",
            "sdkAppID": request.sdkAppId,
            "sdkEphemPubKey": sdkEphemeralPublicKey,
            "sdkReferenceNumber": request.sdkReferenceNumber,
            "sdkTransID": request.sdkTransactionId
        ]
        requestParameters["sdkEncData"] = request.deviceData
        return try JSONSerialization.data(withJSONObject: requestParameters).base64EncodedString()
    }
}
