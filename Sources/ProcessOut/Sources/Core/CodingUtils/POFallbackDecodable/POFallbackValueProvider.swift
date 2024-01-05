//
//  POFallbackValueProvider.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2023.
//

import Foundation

/// Contract for providing a default value of a Type.
public protocol POFallbackValueProvider<Value> {

    associatedtype Value

    /// Default value.
    static var defaultValue: Value { get }
}

/// Provides empty string as a fallback.
public struct POEmptyStringProvider: POFallbackValueProvider {

    public static let defaultValue = ""
}
