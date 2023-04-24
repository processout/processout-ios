//
//  PONativeAlternativePaymentMethodParameter.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodParameter: Decodable {

    public enum ParameterType: String, Decodable, Hashable {

        /// For numeric only fields.
        case numeric

        /// For any alphanumeric fields.
        case text

        /// For email fields.
        case email

        /// For phone fields.
        case phone

        /// For fields where user needs to select one of available values.
        case singleChoice = "single-choice"
    }

    /// Describes available value.
    public struct AvailableValue: Decodable, Hashable {

        /// Display name of value.
        let displayName: String

        /// Indicates whether value is selected by default.
        let `default`: Bool?
    }

    /// Name of the field that needs to be collected for the request e.g. blik_code.
    public let key: String

    /// Parameter type.
    public let type: ParameterType

    /// Boolean value indicating whether parameter is required or optional.
    public let required: Bool

    /// Expected length of the field (for validation purposes).
    /// - NOTE: If the length field is null, that means there is no length requirement for that specific
    /// parameter and no length validation will be performed.
    public let length: Int?

    /// Parameter's localized name that could be displayed to user.
    public let displayName: String

    /// This property should be non-empty array of available values when `type` is `singleChoice`.
    public let availableValues: [AvailableValue]?
}
