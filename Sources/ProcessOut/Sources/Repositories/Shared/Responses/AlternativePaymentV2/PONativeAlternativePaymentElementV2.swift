//
//  PONativeAlternativePaymentElementV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2025.
//

import Foundation

/// Represents a display element in the native alternative payment flow.
///
/// This enum supports various types of UI elements such as input forms and customer instructions.
/// It's forward-compatible via the `unknown` case.
@_spi(PO)
public enum PONativeAlternativePaymentElementV2: Sendable {

    /// Input form.
    case form(PONativeAlternativePaymentFormV2)

    /// Customer instruction.
    case customerInstruction(PONativeAlternativePaymentCustomerInstructionV2)

    /// Group of customer instructions.
    case group(PONativeAlternativePaymentInstructionsGroupV2)

    // MARK: - Unknown Future Case

    /// Placeholder to allow adding additional payment methods while staying backward compatible.
    /// - Warning: Don't match this case directly, instead use default.
    @_spi(PO)
    case unknown(type: String)
}

extension PONativeAlternativePaymentElementV2: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "form":
            self = try .form(.init(from: decoder))
        case "instruction":
            self = try .customerInstruction(
                container.decode(PONativeAlternativePaymentCustomerInstructionV2.self, forKey: .instruction)
            )
        case "group":
            self = try .group(container.decode(PONativeAlternativePaymentInstructionsGroupV2.self, forKey: .group))
        default:
            self = .unknown(type: type)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case type, instruction, group
    }
}
