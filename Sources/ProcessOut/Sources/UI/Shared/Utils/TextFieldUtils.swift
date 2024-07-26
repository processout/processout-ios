//
//  TextFieldUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.08.2023.
//

import Foundation
import UIKit

@MainActor
enum TextFieldUtils {

    static func changeText(
        in range: NSRange, replacement string: String, textField: UITextField, formatter: Formatter
    ) -> Bool {
        // swiftlint:disable legacy_objc_type
        let originalString = (textField.text ?? "") as NSString
        var updatedString = originalString.replacingCharacters(in: range, with: string) as NSString
        // swiftlint:enable legacy_objc_type
        var proposedSelectedRange = NSRange(location: updatedString.length, length: 0)
        let isReplacementValid = formatter.isPartialStringValid(
            &updatedString,
            proposedSelectedRange: &proposedSelectedRange,
            originalString: originalString as String,
            originalSelectedRange: range,
            errorDescription: nil
        )
        guard isReplacementValid else {
            return false
        }
        textField.text = updatedString as String
        // swiftlint:disable:next line_length
        if let position = textField.position(from: textField.beginningOfDocument, offset: proposedSelectedRange.lowerBound) {
            // fixme(andrii-vysotskyi): when called as a result of paste system changes our selection to wrong value
            // based on length of `replacementString` after call textField(:shouldChangeCharactersIn:replacementString:)
            // returns, even if this method returns false.
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
        textField.sendActions(for: .editingChanged)
        return false
    }
}
