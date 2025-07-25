//
//  NativeAlternativePaymentResolvedElement.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import UIKit
@_spi(PO) import ProcessOut

// swiftlint:disable nesting

enum NativeAlternativePaymentResolvedElement {

    enum Instruction: Sendable {

        struct Barcode: Sendable {

            /// Barcode image.
            let image: UIImage

            /// Actual barcode value.
            let type: POBarcode.BarcodeType
        }

        struct Message: Sendable {

            /// Message label.
            let label: String?

            /// Message value markdown.
            let value: String
        }

        case barcode(Barcode), message(Message), image(UIImage)
    }

    struct Group: Sendable {

        /// Group label if any.
        let label: String?

        /// Grouped instructions.
        let instructions: [Instruction]
    }

    /// Original input form.
    case form(PONativeAlternativePaymentFormV2)

    /// Resolved instruction.
    case instruction(Instruction)

    /// Group of customer instructions.
    case group(Group)
}

// swiftlint:enable nesting
