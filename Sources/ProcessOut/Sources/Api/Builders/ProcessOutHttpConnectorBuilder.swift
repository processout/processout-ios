//
//  ProcessOutHttpConnectorBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 29.03.2023.
//

import Foundation

/// Builds http connector suitable for communications with ProcessOut API.
final class ProcessOutHttpConnectorBuilder {

    func build(
        configuration: HttpConnectorConfiguration,
        deviceMetadataProvider: DeviceMetadataProvider,
        logger: POLogger
    ) -> HttpConnector {
        let requestMapper = DefaultHttpConnectorRequestMapper(
            configuration: configuration,
            encoder: encoder,
            deviceMetadataProvider: deviceMetadataProvider,
            logger: logger
        )
        let connector = HttpConnectorErrorDecorator(
            connector: HttpConnectorRetryDecorator(
                connector: UrlSessionHttpConnector(
                    sessionConfiguration: sessionConfiguration,
                    requestMapper: requestMapper,
                    decoder: decoder,
                    logger: logger
                ),
                retryStrategy: .exponential(maximumRetries: 3, interval: 0.1, rate: 3)
            ),
            failureMapper: DefaultHttpConnectorFailureMapper(logger: logger),
            logger: logger
        )
        return connector
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let requestTimeout: TimeInterval = 30
    }

    // MARK: - Private Properties

    private var sessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = Constants.requestTimeout
        return configuration
    }

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }
}
