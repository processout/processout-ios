//
//  CustomerActionHandler.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

import Foundation

final class CustomerActionHandler: CustomerActionHandlerType {

    init(decoder: JSONDecoder, encoder: JSONEncoder) {
        self.decoder = decoder
        self.encoder = encoder
    }

    // MARK: - CustomerActionHandlerType

    func handle(
        customerAction: CustomerAction,
        delegate: Delegate,
        completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        switch customerAction.type {
        case .fingerprintMobile:
            fingerprint(encodedDirectoryServerData: customerAction.value, delegate: delegate, completion: completion)
        case .challengeMobile:
            challenge(encodedChallengeData: customerAction.value, delegate: delegate, completion: completion)
        case .fingerprint:
            fingerprint(url: customerAction.value, delegate: delegate, completion: completion)
        case .redirect, .url:
            redirect(url: customerAction.value, delegate: delegate, completion: completion)
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

    // MARK: - Private Methods

    private func fingerprint(
        encodedDirectoryServerData: String,
        delegate: Delegate,
        completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        let directoryServerData: PODirectoryServerData
        switch decode(PODirectoryServerData.self, from: encodedDirectoryServerData) {
        case let .success(data):
            directoryServerData = data
        case let .failure(failure):
            completion(.failure(failure))
            return
        }
        delegate.fingerprint(data: directoryServerData) { [encoder] result in
            assert(Thread.isMainThread)
            switch result {
            case let .success(fingerprint):
                do {
                    let fingerprintDataString = String(decoding: try self.encoder.encode(fingerprint), as: UTF8.self)
                    let response = FingerprintResponse(url: nil, headers: nil, body: fingerprintDataString)
                    let responseDataString = String(
                        decoding: try encoder.encode(response).base64EncodedData(), as: UTF8.self
                    )
                    let newSource = "gway_req_" + responseDataString
                    completion(.success(newSource))
                } catch {
                    Logger.services.error("Did fail to encode fingerprint: '\(error.localizedDescription)'.")
                    completion(.failure(.init(message: nil, code: .internal, underlyingError: error)))
                }
            case let .failure(error):
                completion(.failure(.init(message: nil, code: .unknown, underlyingError: error)))
            }
        }
    }

    private func challenge(
        encodedChallengeData: String,
        delegate: Delegate,
        completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        let challenge: POAuthentificationChallengeData
        switch decode(POAuthentificationChallengeData.self, from: encodedChallengeData) {
        case let .success(data):
            challenge = data
        case let .failure(failure):
            completion(.failure(failure))
            return
        }
        delegate.challenge(challenge: challenge) { result in
            assert(Thread.isMainThread)
            switch result {
            case let .success(success):
                let newSource = success
                    ? "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIllcIn0ifQ=="
                    : "gway_req_eyJib2R5Ijoie1widHJhbnNTdGF0dXNcIjpcIk5cIn0ifQ=="
                completion(.success(newSource))
            case let .failure(error):
                completion(.failure(.init(message: nil, code: .unknown, underlyingError: error)))
            }
        }
    }

    private func fingerprint(
        url: String, delegate: Delegate, completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        if let url = URL(string: url) {
            let timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [encoder] _ in
                do {
                    let response = FingerprintResponse(
                        url: url,
                        headers: ["Content-Type": "application/json"],
                        body: #"{ "threeDS2FingerprintTimeout": true }"#
                    )
                    let responseDataString = String(
                        decoding: try encoder.encode(response).base64EncodedData(), as: UTF8.self
                    )
                    let newSource = "gway_req_" + responseDataString
                    completion(.success(newSource))
                } catch {
                    Logger.services.error("Did fail to encode fingerprint: '\(error.localizedDescription)'.")
                    completion(.failure(.init(message: nil, code: .internal, underlyingError: error)))
                }
                delegate.fingerprintDidTimeout()
            }
            delegate.fingerprint(url: url) { [self] result in
                guard timer.isValid else {
                    return
                }
                timer.invalidate()
                complete(with: result, completion: completion)
            }
        } else {
            let failure = POFailure(message: nil, code: .internal, underlyingError: nil)
            completion(.failure(failure))
        }
    }

    private func redirect(
        url: String, delegate: Delegate, completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        if let url = URL(string: url) {
            delegate.redirect(url: url) { result in
                self.complete(with: result, completion: completion)
            }
        } else {
            let failure = POFailure(message: nil, code: .internal, underlyingError: nil)
            completion(.failure(failure))
        }
    }

    // MARK: - Utils

    private func complete(
        with result: Result<String, Error>, completion: @escaping (Result<String, POFailure>) -> Void
    ) {
        assert(Thread.isMainThread)
        let result = result.mapError { error in
            POFailure(message: nil, code: .unknown, underlyingError: error)
        }
        completion(result)
    }

    private func decode<T: Decodable>(_ type: T.Type, from string: String) -> Result<T, POFailure> {
        let paddedString = string.padding(
            toLength: string.count + (4 - string.count % 4) % 4, withPad: "=", startingAt: 0
        )
        let data = Data(paddedString.utf8).base64EncodedData()
        do {
            return .success(try decoder.decode(type, from: data))
        } catch {
            return .failure(.init(message: nil, code: .internal, underlyingError: error))
        }
    }
}
