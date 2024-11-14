//
//  ThreeDSServiceAdapter.swift
//  ProcessOutCheckout3DS
//
//  Created by Andrii Vysotskyi on 13.11.2024.
//

import ProcessOut

@available(*, deprecated)
final class ThreeDSServiceAdapter: PO3DSService {

    init(service: PO3DS2Service) {
        self.service = service
    }

    // MARK: - PO3DSService

    func authenticationRequest(
        configuration: PO3DS2Configuration,
        completion: @escaping (Result<PO3DS2AuthenticationRequestParameters, POFailure>) -> Void
    ) {
        invoke(completion: completion) { [service] in
            try await service.authenticationRequestParameters(configuration: configuration)
        }
    }

    func handle(challenge: PO3DS2ChallengeParameters, completion: @escaping (Result<Bool, POFailure>) -> Void) {
        invoke(completion: completion) { [service] in
            try await service.performChallenge(with: challenge).transactionStatus == "Y"
        }
    }

    func clean() async {
        await service.clean()
    }

    // MARK: - Private Properties

    private let service: PO3DS2Service

    // MARK: - Private Methods

    private func invoke<T>(
        completion: @escaping (Result<T, POFailure>) -> Void,
        after operation: @escaping @isolated(any) () async throws -> T
    ) {
        Task { @MainActor in
            do {
                let returnValue = try await operation()
                completion(.success(returnValue))
            } catch let failure as POFailure {
                completion(.failure(failure))
            } catch {
                let failure = POFailure(message: "Something went wrong.", code: .internal(.mobile), underlyingError: error) // swiftlint:disable:this line_length
                completion(.failure(failure))
            }
        }
    }
}
