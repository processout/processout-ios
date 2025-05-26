//
//  PONativeAlternativePaymentNextStepV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import Foundation

// swiftlint:disable nesting file_length

/// Specifies the next required step in the payment flow.
@_spi(PO)
public enum PONativeAlternativePaymentNextStepV2: Sendable {

    /// Indicates that the next required step is submitting data.
    public struct SubmitData: Sendable, Decodable {

        public struct Parameters: Sendable, Decodable {

            public let parameterDefinitions: [Parameter]
        }

        /// Payment parameter definition.
        public enum Parameter: Sendable {

            /// Text parameter.
            public struct Text: Sendable, Decodable {

                /// Parameter key.
                public let key: String

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool

                /// Min length.
                public let minLength: Int?

                /// Max length.
                public let maxLength: Int?
            }

            /// Single selection parameter.
            public struct SingleSelect: Sendable, Decodable {

                /// Available parameter value.
                public struct AvailableValue: Sendable, Decodable {

                    /// Value.
                    public let value: String

                    /// Value display label.
                    public let label: String

                    /// Indicates whether value should be preselected.
                    @_spi(PO)
                    public let preselected: Bool
                }

                /// Parameter key.
                public let key: String

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool

                /// Available values.
                public let availableValues: [AvailableValue]

                public var preselectedValue: AvailableValue? {
                    availableValues.first(where: \.preselected)
                }
            }

            /// Boolean parameter.
            public struct Boolean: Sendable, Decodable {

                /// Parameter key.
                public let key: String

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool
            }

            /// Digits only parameter.
            public struct Digits: Sendable, Decodable {

                /// Parameter key.
                public let key: String

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool

                /// Min length.
                public let minLength: Int?

                /// Max length.
                public let maxLength: Int?
            }

            /// Phone number parameter.
            public struct PhoneNumber: Sendable, Decodable {

                public struct DialingCode: Sendable, Decodable {

                    /// Country code ID.
                    public let id: String

                    /// Dialing code value.
                    public let value: String
                }

                /// Parameter key.
                public let key: String

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool

                /// Supported dialing codes.
                public let dialingCodes: [DialingCode]?
            }

            /// Email parameter.
            public struct Email: Sendable, Decodable {

                /// Parameter key.
                public let key: String

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool
            }

            /// Card number parameter.
            public struct Card: Sendable, Decodable {

                /// Parameter key.
                public let key: String

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool

                /// Min length.
                public let minLength: Int?

                /// Max length.
                public let maxLength: Int?
            }

            /// One-Time Password (OTP) parameter.
            public struct Otp: Sendable, Decodable {

                /// One-Time Password (OTP) subtype.
                public struct Subtype: RawRepresentable, Sendable, Hashable {

                    /// The string value representing the type of OTP..
                    public let rawValue: String

                    public init(rawValue: String) {
                        self.rawValue = rawValue
                    }
                }

                /// Parameter key.
                public let key: String

                /// One-Time Password (OTP) subtype.
                public let subtype: Subtype

                /// Parameter display label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool

                /// Min length.
                public let minLength: Int?

                /// Max length.
                public let maxLength: Int?
            }

            /// Text parameter.
            case text(Text)

            /// Single selection parameter.
            case singleSelect(SingleSelect)

            /// Boolean parameter.
            case boolean(Boolean)

            /// Digits only parameter.
            case digits(Digits)

            /// Phone number parameter.
            case phoneNumber(PhoneNumber)

            /// Email parameter.
            case email(Email)

            /// Card number parameter.
            case card(Card)

            /// One-Time Password (OTP) parameter.
            case otp(Otp)

            // MARK: - Unknown Future Cases

            @_spi(PO)
            public struct Unknown: Sendable, Decodable {

                /// Unknown instruction type.
                public let type: String

                /// Parameter key.
                public let key: String

                /// Parameter label.
                public let label: String

                /// Indicates whether parameter is required.
                public let required: Bool
            }

            /// Placeholder to allow adding additional payment methods while staying backward compatible.
            /// - Warning: Don't match this case directly, instead use default.
            @_spi(PO)
            case unknown(Unknown)
        }

        public let parameters: Parameters
    }

    public struct Redirect: Sendable, Decodable {

        /// Redirect URL.
        public let url: URL
    }

    case submitData(SubmitData), redirect(Redirect)

    // MARK: - Unknown Future Case

    /// Placeholder to allow adding additional payment methods while staying backward compatible.
    /// - Warning: Don't match this case directly, instead use default.
    @_spi(PO)
    case unknown(type: String)
}

// MARK: - Decodable

extension PONativeAlternativePaymentNextStepV2: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "submit_data":
            self = try .submitData(.init(from: decoder))
        case "redirect":
            self = try .redirect(.init(from: decoder))
        default:
            self = .unknown(type: type)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

extension PONativeAlternativePaymentNextStepV2.SubmitData.Parameter: Decodable {

    // MARK: - Decodable

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            self = try .text(.init(from: decoder))
        case "single_select":
            self = try .singleSelect(.init(from: decoder))
        case "boolean":
            self = try .boolean(.init(from: decoder))
        case "digits":
            self = try .digits(.init(from: decoder))
        case "phone":
            self = try .phoneNumber(.init(from: decoder))
        case "email":
            self = try .email(.init(from: decoder))
        case "card":
            self = try .card(.init(from: decoder))
        case "otp":
            self = try .otp(.init(from: decoder))
        default:
            self = try .unknown(.init(from: decoder))
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

extension PONativeAlternativePaymentNextStepV2.SubmitData.Parameter.Otp.Subtype: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// MARK: -

extension PONativeAlternativePaymentNextStepV2.SubmitData.Parameter {

    /// Parameter key.
    public var key: String {
        switch self {
        case .text(let parameter):
            parameter.key
        case .singleSelect(let parameter):
            parameter.key
        case .boolean(let parameter):
            parameter.key
        case .digits(let parameter):
            parameter.key
        case .phoneNumber(let parameter):
            parameter.key
        case .email(let parameter):
            parameter.key
        case .card(let parameter):
            parameter.key
        case .otp(let parameter):
            parameter.key
        case .unknown(let parameter):
            parameter.key
        }
    }

    /// Parameter label.
    public var label: String {
        switch self {
        case .text(let parameter):
            parameter.label
        case .singleSelect(let parameter):
            parameter.label
        case .boolean(let parameter):
            parameter.label
        case .digits(let parameter):
            parameter.label
        case .phoneNumber(let parameter):
            parameter.label
        case .email(let parameter):
            parameter.label
        case .card(let parameter):
            parameter.label
        case .otp(let parameter):
            parameter.label
        case .unknown(let parameter):
            parameter.label
        }
    }

    /// Indicates whether parameter is required.
    public var required: Bool {
        switch self {
        case .text(let parameter):
            parameter.required
        case .singleSelect(let parameter):
            parameter.required
        case .boolean(let parameter):
            parameter.required
        case .digits(let parameter):
            parameter.required
        case .phoneNumber(let parameter):
            parameter.required
        case .email(let parameter):
            parameter.required
        case .card(let parameter):
            parameter.required
        case .otp(let parameter):
            parameter.required
        case .unknown(let parameter):
            parameter.required
        }
    }
}

extension PONativeAlternativePaymentNextStepV2.SubmitData.Parameter.Otp.Subtype {

    /// Text OTP.
    public static let text = Self(rawValue: "text")

    /// Digits only OTP.
    public static let digits = Self(rawValue: "digits")
}

// swiftlint:enable nesting file_length
