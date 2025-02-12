//
//  Environment+Sendable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.11.2024.
//

import Checkout3DS

/// Marks `Environment` as `Sendable` retroactively.
extension Environment: @retroactive @unchecked Sendable { }

/// Marks `Warning` as `Sendable` retroactively.
extension Warning: @retroactive @unchecked Sendable { }

/// Marks `AuthenticationRequestParameters` as `Sendable` retroactively.
extension AuthenticationRequestParameters: @retroactive @unchecked Sendable { }

/// Marks `AuthenticationResult` as `Sendable` retroactively.
extension AuthenticationResult: @retroactive @unchecked Sendable { }

/// Marks `ChallengeParameters` as `Sendable` retroactively.
extension ChallengeParameters: @retroactive @unchecked Sendable { }

/// Marks `AuthenticationError` as `Sendable` retroactively.
extension AuthenticationError: @retroactive @unchecked Sendable { }
