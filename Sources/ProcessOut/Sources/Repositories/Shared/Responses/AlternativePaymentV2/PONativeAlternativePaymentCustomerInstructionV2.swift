//
//  PONativeAlternativePaymentCustomerInstructionV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import Foundation

/// Specifies instruction for the customer, providing additional information and/or describing required actions.
@_spi(PO)
public indirect enum PONativeAlternativePaymentCustomerInstructionV2: Sendable {

    /// Customer instruction provided via barcode.
    public struct Barcode: Sendable {

        /// Actual barcode value.
        public let value: POBarcode
    }

    /// Customer instruction provided as a markdown text.
    public struct Text: Sendable, Decodable {

        /// Text label.
        public let label: String?

        /// Text value markdown.
        public let value: String
    }

    /// Customer instruction provided as an image resource.
    public struct Image: Sendable, Decodable {

        /// Image value.
        public let value: POImageRemoteResource
    }

    /// Group of customer instructions.
    public struct Group: Sendable, Decodable {

        /// Group label if any.
        public let label: String?

        /// Grouped instructions.
        public let instructions: [PONativeAlternativePaymentCustomerInstructionV2]
    }

    case barcode(Barcode), text(Text), image(Image), group(Group)

    // MARK: - Unknown Future Case

    /// Placeholder to allow adding additional payment methods while staying backward compatible.
    /// - Warning: Don't match this case directly, instead use default.
    @_spi(PO)
    case unknown(type: String)
}

// MARK: - Decodable

extension PONativeAlternativePaymentCustomerInstructionV2: Decodable {

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
            self = .unknown(type: type)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

extension PONativeAlternativePaymentCustomerInstructionV2.Barcode: Decodable {

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
