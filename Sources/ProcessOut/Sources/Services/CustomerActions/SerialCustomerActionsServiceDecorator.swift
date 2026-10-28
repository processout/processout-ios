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

    func handle(request: CustomerActionRequest, threeDSService: PO3DS2Service) async throws(POFailure) -> String {
        let previousHandling = lastHandling
        let handling = Task<Result<String, POFailure>, Never> {
            // Wait for the predecessor regardless of its outcome. The wait itself is not
            // cancellable, so cancellation requested while queued is observed only after
            // the predecessor completes.
            _ = await previousHandling?.value
            if Task.isCancelled {
                let failure = POFailure(message: "Customer action handling was cancelled.", code: .Mobile.cancelled)
                return .failure(failure)
            }
            return await Result(catching: { () async throws(POFailure) in
                try await service.handle(request: request, threeDSService: threeDSService)
            })
        }
        lastHandling = handling
        let result = await withTaskCancellationHandler(
            operation: {
                await handling.value
            },
            onCancel: handling.cancel
        )
        return try result.get()
    }

    // MARK: - Private Properties

    private let service: CustomerActionsService
    private var lastHandling: Task<Result<String, POFailure>, Never>?
}
