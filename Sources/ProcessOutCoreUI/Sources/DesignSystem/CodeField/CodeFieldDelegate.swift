//
//  CodeFieldDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import UIKit

@MainActor
protocol CodeFieldDelegate: AnyObject {

    /// Tells the delegate that its window object changed.
    func codeField(_ codeField: CodeFieldView, didMoveToWindow window: UIWindow?)

    /// Tells the delegate when editing begins in the specified code field.
    func codeFieldDidBeginEditing(_ codeField: CodeFieldView)

    /// Tells the delegate when editing stops for the specified code field.
    func codeFieldDidEndEditing(_ codeField: CodeFieldView)
}
