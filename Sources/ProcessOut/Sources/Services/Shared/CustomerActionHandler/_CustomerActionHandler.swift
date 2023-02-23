//
//  _CustomerActionHandler.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

// swiftlint:disable type_name todo
// - TODO: Remove underscore when legacy counterpart won't be needed.
final class _CustomerActionHandler: CustomerActionHandlerType {

    init(decoder: JSONDecoder, encoder: JSONEncoder, logger: POLogger) {
        self.decoder = decoder
        self.encoder = encoder
        self.logger = logger
    }

    // MARK: - CustomerActionHandlerType

    func handle(customerAction: _CustomerAction, delegate: Delegate, completion: @escaping Completion) {
        let completionTrampoline: Completion = { result in
            assert(Thread.isMainThread, "Completion must be called on main thread!")
            completion(result)
        }
        switch customerAction.type {
        case .fingerprintMobile:
            fingerprint(
                encodedDirectoryServerData: customerAction.value, delegate: delegate, completion: completionTrampoline
            )
        case .challengeMobile:
            challenge(encodedChallengeData: customerAction.value, delegate: delegate, completion: completionTrampoline)
        case .fingerprint:
            fingerprint(url: customerAction.value, delegate: delegate, completion: completionTrampoline)
        case .redirect, .url:
            redirect(url: customerAction.value, delegate: delegate, completion: completionTrampoline)
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

    private func fingerprint(encodedDirectoryServerData: String, delegate: Delegate, completion: @escaping Completion) {
        do {
            let directoryServerData = try decode(PODirectoryServerData.self, from: encodedDirectoryServerData)
            delegate.fingerprint(data: directoryServerData) { [encoder, logger] result in
                switch result {
                case let .success(fingerprint):
                    do {
                        let response = FingerprintResponse(
                            url: nil,
                            headers: nil,
                            body: String(decoding: try self.encoder.encode(fingerprint), as: UTF8.self)
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
        } catch {
            logger.error("Did fail to decode DS data: '\(error.localizedDescription)'.")
            completion(.failure(.init(code: .internal(.mobile), underlyingError: error)))
        }
    }

    private func challenge(encodedChallengeData: String, delegate: Delegate, completion: @escaping Completion) {
        do {
            let challenge = try decode(POAuthentificationChallengeData.self, from: encodedChallengeData)
            delegate.challenge(challenge: challenge) { result in
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

    private func fingerprint(url: String, delegate: Delegate, completion: @escaping Completion) {
        guard let url = URL(string: url) else {
            logger.error("Did fail to create fingerprint URL from raw value: '\(url)'.")
            completion(.failure(.init(message: nil, code: .internal(.mobile), underlyingError: nil)))
            return
        }
        let context = PORedirectCustomerActionContext(url: url, isHeadlessModeAllowed: true, timeout: 10)
        delegate.redirect(context: context) { [encoder, logger] result in
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

    private func redirect(url: String, delegate: Delegate, completion: @escaping Completion) {
        guard let url = URL(string: url) else {
            logger.error("Did fail to create redirect URL from raw value: '\(url)'.")
            completion(.failure(.init(message: nil, code: .internal(.mobile), underlyingError: nil)))
            return
        }
        let context = PORedirectCustomerActionContext(url: url, isHeadlessModeAllowed: false, timeout: nil)
        delegate.redirect(context: context, completion: completion)
    }

    // MARK: - Utils

    private func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
        let paddedString = string.padding(
            toLength: string.count + (4 - string.count % 4) % 4, withPad: "=", startingAt: 0
        )
        let data = Data(paddedString.utf8).base64EncodedData()
        return try decoder.decode(type, from: data)
    }
}
