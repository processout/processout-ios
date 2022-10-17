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

        /// SDK version.
        let version: String
    }

    // MARK: -

    init(
        configuration: Configuration,
        sessionConfiguration: URLSessionConfiguration,
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) {
        self.configuration = configuration
        self.session = URLSession(configuration: sessionConfiguration)
        self.decoder = decoder
        self.encoder = encoder
        workQueue = DispatchQueue(label: "process-out.http-connector", attributes: .concurrent)
    }

    // MARK: - HttpConnectorType

    func execute<Value>(request: HttpConnectorRequest<Value>, completion: @escaping (Result<Value, Failure>) -> Void) {
        workQueue.async {
            do {
                let sessionRequest = try self.createUrlRequest(request: request)
                let dataTask = self.session.dataTask(with: sessionRequest) { data, response, error in
                    self.completeRequest(with: data, urlResponse: response, error: error, completion: completion)
                }
                dataTask.resume()
            } catch {
                self.completeRequest(with: .failure(error), completion: completion)
            }
        }
    }

    // MARK: - Private Properties

    private let configuration: Configuration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let workQueue: DispatchQueue

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
            sessionRequest.httpBody = try encoder.encode(body)
            sessionRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        authorize(request: &sessionRequest)
        let userAgentComponents = [
            "iOS",
            "Version",
            ProcessInfo.processInfo.operatingSystemVersionString,
            "ProcessOut iOS-Bindings",
            configuration.version
        ]
        let headers = [
            "Idempotency-Key": request.id,
            "User-Agent": userAgentComponents.joined(separator: "/")
        ]
        headers.forEach { field, value in
            sessionRequest.setValue(value, forHTTPHeaderField: field)
        }
        request.headers.forEach { field, value in
            sessionRequest.setValue(value, forHTTPHeaderField: field)
        }
        return sessionRequest
    }

    private func authorize(request: inout URLRequest) {
        let value = configuration.projectId + ":"
        let authorization = "Basic " + Data(value.utf8).base64EncodedString()
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
    }

    private func completeRequest<Value: Decodable>(
        with data: Data?,
        urlResponse: URLResponse?,
        error: Error?,
        completion: @escaping (Result<Value, Failure>) -> Void
    ) {
        if let error {
            completeRequest(with: .failure(error), completion: completion)
        } else if let data, let urlResponse = urlResponse as? HTTPURLResponse {
            do {
                let response = try decoder.decode(HttpConnectorResponse<Value>.self, from: data)
                switch response {
                case let .success(value):
                    completeRequest(with: .success(value), completion: completion)
                case let .failure(externalFailure):
                    throw Failure.external(externalFailure, statusCode: urlResponse.statusCode)
                }
            } catch {
                completeRequest(with: .failure(error), completion: completion)
            }
        } else {
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
            case URLError.notConnectedToInternet, URLError.networkConnectionLost, URLError.timedOut:
                return .networkUnreachable
            default:
                return .internal
            }
        }
        DispatchQueue.main.async { completion(result) }
    }
}

private enum HttpConnectorResponse<Value: Decodable>: Decodable {

    case success(Value), failure(HttpConnectorFailure.External)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decode(Bool.self, forKey: .success) {
            let value = try decoder.singleValueContainer().decode(Value.self)
            self = .success(value)
        }
        let failure = try decoder.singleValueContainer().decode(HttpConnectorFailure.External.self)
        self = .failure(failure)
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case success
    }
}
