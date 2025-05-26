//
//  CustomerInstruction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.05.2025.
//

import UIKit
import ProcessOut

// swiftlint:disable:next type_name
enum NativeAlternativePaymentResolvedCustomerInstruction: Sendable {

    struct Barcode: Sendable {

        /// Barcode image.
        let image: UIImage

        /// Actual barcode value.
        let type: POBarcode.BarcodeType
    }

    struct Text: Sendable {

        /// Text label.
        let label: String?

        /// Text value markdown.
        let value: String
    }

    struct Group: Sendable {

        /// Group label if any.
        let label: String?

        /// Grouped instructions.
        let instructions: [NativeAlternativePaymentResolvedCustomerInstruction]
    }

    case barcode(Barcode), text(Text), image(UIImage), group(Group)
}
