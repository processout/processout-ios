//
//  SerialCustomerActionsServiceDecorator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.10.2026.
//

import Foundation

/// Decorator that handles customer actions one at a time in FIFO order.
///
/// Web authentication session is already serialized on its own, so the primary purpose of this
/// decorator is to protect `PO3DS2Service` provided by merchant from overlapping fingerprint and
/// challenge requests.
actor SerialCustomerActionsServiceDecorator: CustomerActionsService {

    init(service: CustomerActionsService) {
        self.service = service
    }

    // MARK: - CustomerActionsService

    func handle(request: CustomerActionRequest, threeDSService: PO3DS2Service) async throws -> String {
        let previousHandling = lastHandling
        let handling = Task<String, Error> {
            // Wait for the predecessor regardless of its outcome. The wait itself is not
            // cancellable, so cancellation requested while queued is observed only after
            // the predecessor completes.
            _ = await previousHandling?.result
            if Task.isCancelled {
                throw POFailure(message: "Customer action handling was cancelled.", code: .Mobile.cancelled)
            }
            return try await service.handle(request: request, threeDSService: threeDSService)
        }
        lastHandling = handling
        return try await withTaskCancellationHandler(
            operation: {
                try await handling.value
            },
            onCancel: handling.cancel
        )
    }

    // MARK: - Private Properties

    private let service: CustomerActionsService
    private var lastHandling: Task<String, Error>?
}
