//
//  UrlSessionHttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation
import UIKit.UIDevice

final class UrlSessionHttpConnector: HttpConnector {

    init(
        sessionConfiguration: URLSessionConfiguration,
        requestMapper: HttpConnectorRequestMapper,
        decoder: JSONDecoder,
        logger: POLogger
    ) {
        self.requestMapper = requestMapper
        self.session = URLSession(configuration: sessionConfiguration)
        self.decoder = decoder
        self.logger = logger
        urlRequestFormatter = UrlRequestFormatter()
        urlResponseFormatter = UrlResponseFormatter(includesHeaders: false)
    }

    // MARK: - HttpConnectorType

    func execute<Value>(request: HttpConnectorRequest<Value>) async throws -> HttpConnectorResponse<Value> {
        let sessionRequest = try await requestMapper.urlRequest(from: request)
        var logger = self.logger
        logger[attributeKey: "RequestId"] = request.id
        logger.debug(
            "Will send request: \(urlRequestFormatter.string(from: sessionRequest))"
        )
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: sessionRequest)
        } catch let error as URLError {
            logger.info("Request did fail with error: '\(error)'.")
            throw convertToFailure(urlError: error)
        } catch {
            logger.error("Request did fail with unknown error '\(error)'.")
            throw Failure(code: .internal, underlyingError: error)
        }
        return try decodeResponse(Value.self, from: data, response: response, logger: logger)
    }

    func replace(configuration: HttpConnectorConfiguration) {
        requestMapper.replace(configuration: configuration)
    }

    // MARK: - Private Properties

    private let session: URLSession
    private let requestMapper: HttpConnectorRequestMapper
    private let decoder: JSONDecoder
    private let logger: POLogger
    private let urlRequestFormatter: UrlRequestFormatter
    private let urlResponseFormatter: UrlResponseFormatter

    // MARK: - Private Methods

    private func decodeResponse<Value: Decodable>(
        _ valueType: Value.Type, from data: Data, response: URLResponse, logger: POLogger
    ) throws -> HttpConnectorResponse<Value> {
        guard let response = response as? HTTPURLResponse else {
            logger.error("Unexpected url response type.")
            throw Failure(code: .internal, underlyingError: nil)
        }
        let responseDescription = urlResponseFormatter.string(from: response, data: data)
        logger.debug("Received response: \(responseDescription)")
        do {
            if try decoder.decode(Response.self, from: data).success {
                let value = try decoder.decode(Value.self, from: data)
                let headers = response.allHeaderFields as? [String: String] ?? [:]
                return HttpConnectorResponse(value: value, headers: headers)
            }
            let serverCode = try decoder.decode(HttpConnectorFailure.Server.self, from: data)
            throw Failure(code: .server(serverCode, statusCode: response.statusCode), underlyingError: nil)
        } catch let error as DecodingError {
            logger.error("Did fail to decode response: '\(error)'")
            throw Failure(code: .decoding(statusCode: response.statusCode), underlyingError: error)
        }
    }

    private func convertToFailure(urlError error: Error) -> Failure {
        let code: Failure.Code
        switch error {
        case URLError.cancelled:
            code = .cancelled
        case URLError.notConnectedToInternet, URLError.networkConnectionLost:
            code = .networkUnreachable
        case URLError.timedOut:
            code = .timeout
        default:
            code = .internal
        }
        return Failure(code: code, underlyingError: error)
    }
}

private struct Response: Decodable {

    /// Indicates whether request was processed successfully.
    let success: Bool
}
