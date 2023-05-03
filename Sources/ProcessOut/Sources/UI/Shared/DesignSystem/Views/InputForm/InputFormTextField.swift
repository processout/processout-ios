//
//  InputFormTextField.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 29.11.2022.
//

import UIKit

protocol InputFormTextField: UIView {

    /// It's not mandatory for view that implement this protocol to be text field control directly
    /// instead it could be just a wrapper. So implementation must return actual control from
    /// here.
    var control: UIControl { get }

    /// Configures text field appearance.
    func configure(style: POTextFieldStyle, animated: Bool)
}

extension InputFormTextField where Self: UIControl {

    var control: UIControl {
        self
    }
}
