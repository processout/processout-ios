//
//  MockUrlProtocolResponseBuilder.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 28.03.2023.
//

import Foundation
import UniformTypeIdentifiers

final class MockUrlProtocolResponseBuilder {

    init() {
        statusCode = Constants.successStatusCode
        headers = [:]
        data = { .init() }
    }

    func with(url: URL?) -> Self {
        self.url = url
        return self
    }

    func with(headers: [String: String]) -> MockUrlProtocolResponseBuilder {
        self.headers = headers
        return self
    }

    func with(statusCode: Int) -> MockUrlProtocolResponseBuilder {
        self.statusCode = statusCode
        return self
    }

    func with(content: String, mimeType: String = "application/json") -> MockUrlProtocolResponseBuilder {
        data = { Data(content.utf8) }
        headers["Content-Type"] = mimeType
        return self
    }

    func with(contentsOf resource: String, extension resourceExtension: String) -> MockUrlProtocolResponseBuilder {
        data = {
            let bundle = Bundle(for: BundleToken.self)
            guard let url = bundle.url(forResource: resource, withExtension: resourceExtension) else {
                fatalError("Invalid resource")
            }
            return try Data(contentsOf: url)
        }
        headers["Content-Type"] = UTType(filenameExtension: resourceExtension)?.preferredMIMEType
        return self
    }

    func build() throws -> (URLResponse, Data) {
        guard let url = url,
              let response = HTTPURLResponse(
                url: url, statusCode: statusCode, httpVersion: Constants.httpVersion, headerFields: headers
              ) else {
            fatalError("Unable to create response")
        }
        let data = try self.data()
        return (response, data)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let httpVersion = "HTTP/1.1"
        static let successStatusCode = 200
    }

    // MARK: - Private Properties

    /// Original request url.
    private var url: URL?

    /// Response status code.
    private var statusCode: Int

    /// Response headers.
    private var headers: [String: String]

    /// Response data provider.
    private var data: () throws -> Data
}

private final class BundleToken { }
