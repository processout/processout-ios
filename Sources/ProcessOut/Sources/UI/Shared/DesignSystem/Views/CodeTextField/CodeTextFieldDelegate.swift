//
//  CodeTextFieldDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 29.11.2022.
//

import UIKit

protocol CodeTextFieldDelegate: AnyObject {

    /// Asks the delegate whether to begin editing in the specified text field.
    ///
    /// - Returns: `true` if editing should begin or `false` if it should not.
    func codeTextFieldShouldBeginEditing(_ textField: CodeTextField) -> Bool

    /// Asks the delegate whether to change the specified text.
    func codeTextField(
        _ textField: CodeTextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool

    /// Asks the delegate whether to process the pressing of the Return button for the text field.
    ///
    /// - Returns: `true` if the text field should implement its default behavior for the return button;
    /// otherwise, `false`.
    func codeTextFieldShouldReturn(_ textField: CodeTextField) -> Bool
}
