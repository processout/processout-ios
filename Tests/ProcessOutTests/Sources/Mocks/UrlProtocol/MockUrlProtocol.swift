//
//  MockUrlProtocol.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 28.03.2023.
//

import Foundation

final class MockUrlProtocol: URLProtocol {

    /// Method doesn't validate whether handler for given method/path is already registered.
    static func register(
        method: String? = nil,
        path: String,
        handler: @escaping (URLRequest) async throws -> (URLResponse, Data)
    ) {
        let route = MockUrlProtocolRoute(method: method, path: path, handler: handler)
        lock.withLock {
            routes.append(route)
        }
    }

    static func removeRegistrations() {
        lock.withLock {
            routes = []
        }
    }

    /// Implementation raises an assertion failure is given request can't be handled.
    static func handle(request: URLRequest) async throws -> (URLResponse, Data) {
        guard let urlAbsoluteString = request.url?.absoluteString else {
            fatalError("Invalid request")
        }
        var availableRoutes: [MockUrlProtocolRoute] = []
        lock.withLock {
            availableRoutes = routes
        }
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

    private static var routes: [MockUrlProtocolRoute] = []
    private static var lock = NSLock()

    // MARK: - URLProtocol

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        currentTask = Task { [weak self] in
            await self?.startLoadingAsync()
        }
    }

    override func stopLoading() {
        currentTask?.cancel()
    }

    // MARK: - Private Properties

    private var currentTask: Task<Void, Never>?

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
