//
//  ProcessOutApi.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.10.2022.
//

import Foundation

public final class ProcessOutApi: ProcessOutApiType {

    /// Shared instance.
    public private(set) static var shared: ProcessOutApiType! // swiftlint:disable:this implicitly_unwrapped_optional

    public static func configure(configuration: ProcessOutApiConfiguration) {
        assert(Thread.isMainThread)
        guard shared == nil else {
            assertionFailure("Already configured.")
            return
        }
        let connector = createHttpConnector(configuration: configuration)
        let failureFactory = RepositoryFailureFactory()
        shared = ProcessOutApi(
            gatewayConfigurations: GatewayConfigurationsRepository(
                connector: connector, failureFactory: failureFactory
            ),
            invoicesRepository: InvoicesRepository(connector: connector, failureFactory: failureFactory)
        )
    }

    // MARK: - ProcessOutApiType

    public let gatewayConfigurations: POGatewayConfigurationsRepositoryType
    public let invoicesRepository: POInvoicesRepositoryType

    // MARK: -

    private init(
        gatewayConfigurations: POGatewayConfigurationsRepositoryType,
        invoicesRepository: POInvoicesRepositoryType
    ) {
        self.gatewayConfigurations = gatewayConfigurations
        self.invoicesRepository = invoicesRepository
    }

    // MARK: - Private Methods

    private static func createHttpConnector(configuration: ProcessOutApiConfiguration) -> HttpConnectorType {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.urlCache = nil
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.waitsForConnectivity = true
        sessionConfiguration.timeoutIntervalForRequest = 30
        let baseUrlString: String
        switch configuration.environment {
        case .production:
            baseUrlString = "https://api.processout.com"
        case .staging:
            baseUrlString = "https://api.processout.ninja"
        }
        let connector = HttpConnector(
            configuration: .init(
                baseUrl: URL(string: baseUrlString)!, // swiftlint:disable:this force_unwrapping
                projectId: configuration.projectId,
                version: Self.version
            ),
            sessionConfiguration: sessionConfiguration,
            decoder: createDecoder(),
            encoder: createEncoder()
        )
        let retryStrategy = RetryStrategy.exponential(maximumRetries: 3, interval: 0.1, rate: 3)
        return HttpConnectorRetryDecorator(connector: connector, retryStrategy: retryStrategy)
    }

    private static func createDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(createDateFormatter())
        return decoder
    }

    private static func createEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .formatted(createDateFormatter())
        return encoder
    }

    private static func createDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }
}
