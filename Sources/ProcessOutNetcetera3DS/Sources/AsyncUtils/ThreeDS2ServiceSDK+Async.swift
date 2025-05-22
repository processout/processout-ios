//
//  ThreeDS2ServiceSDK+Async.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

import ThreeDS_SDK

extension ThreeDS2ServiceSDK {

    /// Initializes the 3DS SDK instance.
    func initialize(
        _ configParameters: ConfigParameters,
        locale: String?,
        uiCustomizationMap: [String: UiCustomization]?
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            initialize(
                configParameters,
                locale: locale,
                uiCustomizationMap: uiCustomizationMap,
                success: continuation.resume,
                failure: continuation.resume(throwing:)
            )
        }
    }
}
