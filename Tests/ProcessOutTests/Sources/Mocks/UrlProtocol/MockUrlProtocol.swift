//
//  MockUrlProtocol.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 28.03.2023.
//

import Foundation
@_spi(PO) import ProcessOut

final class MockUrlProtocol: URLProtocol, @unchecked Sendable {

    /// Method doesn't validate whether handler for given method/path is already registered.
    static func register(
        method: String? = nil,
        path: String,
        handler: @escaping (URLRequest) async throws -> (URLResponse, Data)
    ) {
        let route = MockUrlProtocolRoute(method: method, path: path, handler: handler)
        routes.withLock { $0.append(route) }
    }

    static func removeRegistrations() {
        routes.withLock { $0 = [] }
    }

    /// Implementation raises an assertion failure is given request can't be handled.
    static func handle(request: URLRequest) async throws -> (URLResponse, Data) {
        guard let urlAbsoluteString = request.url?.absoluteString else {
            fatalError("Invalid request")
        }
        let availableRoutes = routes.wrappedValue
        for route in availableRoutes {
            if let method = route.method, method != request.httpMethod {
                continue
            }
            let pathRegex = try NSRegularExpression(pattern: route.path)
            let matches = pathRegex.matches(
                in: urlAbsoluteString,
                range: NSRange(urlAbsoluteString.startIndex ..< urlAbsoluteString.endIndex, in: urlAbsoluteString)
            )
            guard !matches.isEmpty else {
                continue
            }
            return try await route.handler(request)
        }
        fatalError("No handler for given request")
    }

    // MARK: - Private Properties

    private static let routes = POUnfairlyLocked<[MockUrlProtocolRoute]>(wrappedValue: [])

    // MARK: - URLProtocol

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let task = Task { [weak self] in
            await self?.startLoadingAsync()
        }
        currentTask.withLock { $0 = task }
    }

    override func stopLoading() {
        currentTask.withLock { $0?.cancel() }
    }

    // MARK: - Private Properties

    private let currentTask = POUnfairlyLocked<Task<Void?, Never>?>(wrappedValue: nil)

    // MARK: - Private Methods

    private func startLoadingAsync() async {
        do {
            let (response, data) = try await Self.handle(request: request)
            guard !Task.isCancelled else {
                return
            }
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
