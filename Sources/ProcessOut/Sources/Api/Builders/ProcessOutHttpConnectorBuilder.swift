//
//  ProcessOutHttpConnectorBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 29.03.2023.
//

import Foundation

/// Builds http connector suitable for communications with ProcessOut API.
final class ProcessOutHttpConnectorBuilder {

    /// Connector configuration.
    var configuration: HttpConnectorRequestMapperConfiguration?

    /// Retry strategy to use for failing requests.
    var retryStrategy: RetryStrategy? = .exponential(maximumRetries: 3, interval: 0.1, rate: 3)

    /// Logger.
    var logger: POLogger?

    /// Device metadata provider.
    var deviceMetadataProvider: DeviceMetadataProvider?

    /// Session configuration.
    lazy var sessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = Constants.requestTimeout
        return configuration
    }()

    func build() -> HttpConnector {
        guard let configuration, let logger, let deviceMetadataProvider else {
            fatalError("Unable to create connector without required parameters set.")
        }
        let requestMapper = DefaultHttpConnectorRequestMapper(
            configuration: configuration,
            encoder: encoder,
            deviceMetadataProvider: deviceMetadataProvider,
            logger: logger
        )
        var connector: HttpConnector = UrlSessionHttpConnector(
            sessionConfiguration: sessionConfiguration,
            requestMapper: requestMapper,
            decoder: decoder,
            logger: logger
        )
        if let retryStrategy {
            connector = HttpConnectorRetryDecorator(connector: connector, retryStrategy: retryStrategy)
        }
        return HttpConnectorErrorDecorator(
            connector: connector, failureMapper: DefaultHttpConnectorFailureMapper(logger: logger)
        )
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let requestTimeout: TimeInterval = 30
    }

    // MARK: - Private Properties

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()
}

extension ProcessOutHttpConnectorBuilder {

    func with(configuration: HttpConnectorRequestMapperConfiguration) -> Self {
        self.configuration = configuration
        return self
    }

    func with(sessionConfiguration: URLSessionConfiguration) -> Self {
        self.sessionConfiguration = sessionConfiguration
        return self
    }

    func with(retryStrategy: RetryStrategy?) -> Self {
        self.retryStrategy = retryStrategy
        return self
    }

    func with(deviceMetadataProvider: DeviceMetadataProvider) -> Self {
        self.deviceMetadataProvider = deviceMetadataProvider
        return self
    }

    func with(logger: POLogger) -> Self {
        self.logger = logger
        return self
    }
}
