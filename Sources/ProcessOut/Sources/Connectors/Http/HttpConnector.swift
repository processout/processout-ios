//
//  HttpConnector.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

import Foundation

final class HttpConnector: HttpConnectorType {

    // MARK: - Public Nested Types

    struct Configuration {

        /// Base url to use to send requests to.
        let baseUrl: URL

        /// Project id to associate requests with.
        let projectId: String

        /// Project's private key.
        let privateKey: String?

        /// SDK version.
        let version: String
    }

    // MARK: -

    init(
        configuration: Configuration,
        sessionConfiguration: URLSessionConfiguration,
        decoder: JSONDecoder,
        encoder: JSONEncoder,
        deviceMetadataProvider: DeviceMetadataProviderType,
        logger: POLogger
    ) {
        self.configuration = configuration
        self.session = URLSession(configuration: sessionConfiguration)
        self.decoder = decoder
        self.encoder = encoder
        self.deviceMetadataProvider = deviceMetadataProvider
        self.logger = logger
        workQueue = DispatchQueue(label: "process-out.http-connector", attributes: .concurrent)
        urlRequestFormatter = UrlRequestFormatter()
        urlResponseFormatter = UrlResponseFormatter(includesHeaders: false)
    }

    // MARK: - HttpConnectorType

    func execute<Value>(
        request: HttpConnectorRequest<Value>, completion: @escaping (Result<Value, Failure>) -> Void
    ) -> POCancellableType {
        let cancellable = GroupCancellable()
        workQueue.async { [logger, urlRequestFormatter] in
            do {
                let sessionRequest = try self.createUrlRequest(request: request)
                logger.debug("Sending \(urlRequestFormatter.string(from: sessionRequest))")
                let dataTask = self.session.dataTask(with: sessionRequest) { data, response, error in
                    self.completeRequest(
                        requestId: request.id, with: data, urlResponse: response, error: error, completion: completion
                    )
                }
                dataTask.resume()
                cancellable.add(dataTask)
            } catch {
                self.logger.error("Did fail to create a request: '\(error.localizedDescription)'.")
                self.completeRequest(with: .failure(error), completion: completion)
            }
        }
        return cancellable
    }

    // MARK: - Private Properties

    private let configuration: Configuration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let workQueue: DispatchQueue
    private let deviceMetadataProvider: DeviceMetadataProviderType
    private let logger: POLogger
    private let urlRequestFormatter: UrlRequestFormatter
    private let urlResponseFormatter: UrlResponseFormatter

    // MARK: - Private Methods

    private func createUrlRequest(request: HttpConnectorRequest<some Decodable>) throws -> URLRequest {
        var components = URLComponents()
        components.path = request.path
        components.queryItems = request.query.map { item in
            URLQueryItem(name: item.key, value: item.value.description)
        }
        guard let resourceURL = components.url(relativeTo: configuration.baseUrl) else {
            throw Failure.internal
        }
        var sessionRequest = URLRequest(url: resourceURL)
        sessionRequest.httpMethod = request.method.rawValue.uppercased()
        if let body = request.body {
            if request.includesDeviceMetadata {
                let decoratedBody = HttpConnectorRequestBodyDecorator(
                    body: body,
                    deviceMetadata: deviceMetadataProvider.deviceMetadata
                )
                sessionRequest.httpBody = try encoder.encode(decoratedBody)
            } else {
                sessionRequest.httpBody = try encoder.encode(body)
            }
            sessionRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        try authorize(request: &sessionRequest, originalRequest: request)
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        let systemVersionString = [systemVersion.majorVersion, systemVersion.minorVersion, systemVersion.patchVersion]
            .map(\.description).joined(separator: ".")
        let userAgentComponents = [
            "iOS",
            "Version",
            systemVersionString,
            "ProcessOut iOS-Bindings",
            configuration.version
        ]
        let headers = [
            "Idempotency-Key": request.id,
            "User-Agent": userAgentComponents.joined(separator: "/"),
            "Accept-Language": Strings.preferredLocalization
        ]
        headers.forEach { field, value in
            sessionRequest.setValue(value, forHTTPHeaderField: field)
        }
        request.headers.forEach { field, value in
            sessionRequest.setValue(value, forHTTPHeaderField: field)
        }
        return sessionRequest
    }

    private func authorize(request: inout URLRequest, originalRequest: HttpConnectorRequest<some Decodable>) throws {
        var value = configuration.projectId + ":"
        if originalRequest.requiresPrivateKey {
            if let privateKey = configuration.privateKey {
                value += privateKey
            } else {
                logger.info("Private key is required by '\(originalRequest.id)' request but not set")
            }
        }
        let authorization = "Basic " + Data(value.utf8).base64EncodedString()
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
    }

    private func completeRequest<Value: Decodable>(
        requestId: String,
        with data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        completion: @escaping (Result<Value, Failure>) -> Void
    ) {
        if let error {
            logger.debug("Request \(requestId) did fail with error: '\(error.localizedDescription)'.")
            completeRequest(with: .failure(error), completion: completion)
        } else if let data, let urlResponse = urlResponse as? HTTPURLResponse {
            let responseDescription = urlResponseFormatter.string(from: urlResponse, data: data)
            logger.debug("Received response for \(requestId): \(responseDescription)")
            do {
                let response = try decoder.decode(HttpConnectorResponse<Value>.self, from: data)
                switch response {
                case let .success(value):
                    completeRequest(with: .success(value), completion: completion)
                case let .failure(serverFailure):
                    let failure = Failure.server(serverFailure, statusCode: urlResponse.statusCode)
                    completeRequest(with: .failure(failure), completion: completion)
                }
            } catch {
                logger.error("Did fail to decode response for \(requestId): '\(error.localizedDescription)'.")
                completeRequest(with: .failure(error), completion: completion)
            }
        } else {
            logger.error("Invalid url response for \(requestId).")
            completeRequest(with: .failure(Failure.internal), completion: completion)
        }
    }

    private func completeRequest<Value>(
        with result: Result<Value, Error>, completion: @escaping (Result<Value, Failure>) -> Void
    ) {
        let result = result.mapError { error -> Failure in
            switch error {
            case let failure as Failure:
                return failure
            case is EncodingError:
                return .coding(error)
            case is DecodingError:
                return .coding(error)
            case URLError.cancelled:
                return .cancelled
            case URLError.notConnectedToInternet, URLError.networkConnectionLost:
                return .networkUnreachable
            case URLError.timedOut:
                return .timeout
            default:
                return .internal
            }
        }
        DispatchQueue.main.async { completion(result) }
    }
}

private enum HttpConnectorResponse<Value: Decodable>: Decodable {

    case success(Value), failure(HttpConnectorFailure.Server)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decode(Bool.self, forKey: .success) {
            let value = try decoder.singleValueContainer().decode(Value.self)
            self = .success(value)
        } else {
            let failure = try decoder.singleValueContainer().decode(HttpConnectorFailure.Server.self)
            self = .failure(failure)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case success
    }
}
