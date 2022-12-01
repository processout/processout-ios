//
//  TextFieldType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 29.11.2022.
//

import UIKit

protocol TextFieldType: UIControl, UIKeyInput {

    var text: String? { get set }

    /// The keyboard type for the text object.
    var keyboardType: UIKeyboardType { get set }

    /// The visible title of the Return key.
    var returnKeyType: UIReturnKeyType { get set }

    /// The semantic meaning for a text input area.
    var textContentType: UITextContentType! { get set } // swiftlint:disable:this implicitly_unwrapped_optional
}

extension UITextField: TextFieldType { }
extension CodeTextField: TextFieldType { }
