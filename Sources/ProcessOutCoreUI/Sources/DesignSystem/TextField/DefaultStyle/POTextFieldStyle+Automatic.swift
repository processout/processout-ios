//
//  POTextFieldStyle+Automatic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

@available(iOS 14, *)
extension POTextFieldStyle where Self == PODefaultTextFieldStyle {

    /// The default text field style that resolves its appearance based on current input style.
    public static var automatic: PODefaultTextFieldStyle {
        PODefaultTextFieldStyle()
    }
}
