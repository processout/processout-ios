//
//  ThreeDSServiceFactory.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.09.2025.
//

/// A factory responsible for creating `ThreeDSService` instances.
protocol ThreeDSServiceFactory: Sendable {

    /// Creates a new `ThreeDSService` using the specified input.
    ///
    /// - Parameters:
    ///   - input: The input data required to create and configure the service.
    /// - Returns: A configured instance of `ThreeDSService`.
    func make3DSService(with input: ThreeDSServiceFactoryInput) throws(POFailure) -> PO3DS2Service
}
