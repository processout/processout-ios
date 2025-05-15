//
//  PONativeAlternativePaymentAuthorizationResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.05.2025.
//

import Foundation

// swiftlint:disable nesting file_length

@_spi(PO)
public struct PONativeAlternativePaymentAuthorizationResponse: Sendable, Decodable {

    public enum State: String, Sendable, Codable {

        /// Next step is required to proceed.
        case nextStepRequired = "NEXT_STEP_REQUIRED"

        /// Payment is ready to be captured.
        case pendingCapture = "PENDING_CAPTURE"

        /// Payment is captured.
        case captured = "CAPTURED"
    }

    public enum NextStep: Sendable, Decodable {

        public struct SubmitData: Sendable, Decodable {

            public enum Parameter: Sendable, Decodable {

                public struct Text: Sendable, Decodable {

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool

                    /// Min length.
                    public let minLength: Int?

                    /// Max length.
                    public let maxLength: Int?
                }

                public struct SingleSelect: Sendable, Decodable {

                    public struct AvailableValue: Sendable, Decodable {

                        /// Value key.
                        public let key: String

                        /// Value display label.
                        public let label: String

                        /// Indicates whether value should be preselected.
                        let preselected: Bool
                    }

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool

                    /// Available values.
                    public let availableValues: [AvailableValue]

                    public var preselectedValue: AvailableValue? {
                        availableValues.first(where: \.preselected)
                    }
                }

                public struct Boolean: Sendable, Decodable {

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool
                }

                public struct Digits: Sendable, Decodable {

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool

                    /// Min length.
                    public let minLength: Int?

                    /// Max length.
                    public let maxLength: Int?
                }

                public struct PhoneNumber: Sendable, Decodable {

                    public struct DialingCode: Sendable, Decodable {

                        /// Country code ID.
                        public let id: String

                        /// Dialing code value.
                        public let value: String
                    }

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool

                    /// Supported dialing codes.
                    public let dialingCodes: [DialingCode]
                }

                public struct Email: Sendable, Decodable {

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool
                }

                public struct Card: Sendable, Decodable {

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool

                    /// Min length.
                    public let minLength: Int?

                    /// Max length.
                    public let maxLength: Int?
                }

                public struct Otp: Sendable, Decodable {

                    /// Represents the type of barcode (e.g., QR code, UPC, etc.).
                    public struct Subtype: RawRepresentable, Sendable {

                        /// The string value representing the type of barcode.
                        public let rawValue: String

                        public init(rawValue: String) {
                            self.rawValue = rawValue
                        }
                    }

                    /// OTP subtype.
                    public let subtype: Subtype

                    /// Parameter key.
                    public let key: String

                    /// Parameter label.
                    public let label: String

                    /// Indicates whether parameter is required.
                    public let required: Bool

                    /// Min length.
                    public let minLength: Int?

                    /// Max length.
                    public let maxLength: Int?
                }

                // swiftlint:disable:next line_length
                case text(Text), singleSelect(SingleSelect), boolean(Boolean), digits(Digits), phoneNumber(PhoneNumber), email(Email), card(Card), otp(Otp)

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

            public let parameters: [Parameter]
        }

        public struct Redirect: Sendable, Decodable {

            /// Redirect URL.
            public let url: URL
        }

        case submitData(SubmitData), redirect(Redirect)

        // MARK: - Unknown Future Cases

        @_spi(PO)
        public struct Unknown: Sendable {

            /// Unknown instruction type.
            public let type: String
        }

        /// Placeholder to allow adding additional payment methods while staying backward compatible.
        /// - Warning: Don't match this case directly, instead use default.
        @_spi(PO)
        case unknown(Unknown)

        // MARK: - Decodable

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case "submit_data":
                self = try .submitData(.init(from: decoder))
            case "redirect":
                self = try .redirect(.init(from: decoder))
            default:
                self = .unknown(.init(type: type))
            }
        }

        // MARK: - Private Nested Types

        private enum CodingKeys: String, CodingKey {
            case type
        }
    }

    public indirect enum CustomerInstruction: Sendable, Decodable {

        public struct Barcode: Sendable, Decodable {

            /// Actual barcode value.
            public let value: POBarcode

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let subtype = try container.decode(String.self, forKey: .subtype)
                let value = try container.decode(Data.self, forKey: .value)
                self.value = POBarcode(type: .init(rawValue: subtype), value: value)
            }

            // MARK: - Private Nested Types

            private enum CodingKeys: String, CodingKey {
                case subtype, value
            }
        }

        public struct Text: Sendable, Decodable {

            /// Text label.
            public let label: String?

            /// Text value markdown.
            public let value: String
        }

        public struct Image: Sendable, Decodable {

            /// Image value.
            public let value: POImageRemoteResource

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let url = try container.decode(URL.self, forKey: .value)
                self.value = .init(lightUrl: .init(raster: url, scale: 1), darkUrl: nil)
            }

            // MARK: - Private Nested Types

            private enum CodingKeys: String, CodingKey {
                case value
            }
        }

        public struct Group: Sendable, Decodable {

            /// Group label if any.
            public let label: String?

            /// Grouped instructions.
            public let instructions: [CustomerInstruction]
        }

        case barcode(Barcode), text(Text), image(Image), group(Group)

        // MARK: - Unknown Future Cases

        @_spi(PO)
        public struct Unknown: Sendable {

            /// Unknown instruction type.
            public let type: String
        }

        /// Placeholder to allow adding additional payment methods while staying backward compatible.
        /// - Warning: Don't match this case directly, instead use default.
        @_spi(PO)
        case unknown(Unknown)

        // MARK: - Decodable

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case "barcode":
                self = try .barcode(.init(from: decoder))
            case "text":
                self = try .text(.init(from: decoder))
            case "group":
                self = try .group(.init(from: decoder))
            case "image_url":
                self = try .image(.init(from: decoder))
            default:
                self = .unknown(.init(type: type))
            }
        }

        // MARK: - Private Nested Types

        private enum CodingKeys: String, CodingKey {
            case type
        }
    }

    /// Gateway configuration ID.
    public let gatewayConfigurationId: String

    /// Payment state.
    public let state: State

    /// Next step if any.
    public let nextStep: NextStep?

    /// Instructions providing additional information to customer and/or describing additional actions.
    public let customerInstructions: [CustomerInstruction]
}

// swiftlint:enable nesting

extension PONativeAlternativePaymentAuthorizationResponse.NextStep.SubmitData.Parameter {

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

extension PONativeAlternativePaymentAuthorizationResponse.NextStep.SubmitData.Parameter.Otp.Subtype: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension PONativeAlternativePaymentAuthorizationResponse.NextStep.SubmitData.Parameter.Otp.Subtype: Hashable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

extension PONativeAlternativePaymentAuthorizationResponse.NextStep.SubmitData.Parameter.Otp.Subtype {

    /// Text OTP.
    public static let text = Self(rawValue: "text")

    /// Digits only OTP.
    public static let digits = Self(rawValue: "digits")
}

// swiftlint:enable file_length
