//
//  CodeFieldStyle+Default.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 14.06.2024.
//

import SwiftUI

@available(iOS 14, *)
extension CodeFieldStyle where Self == DefaultCodeFieldStyle {

    /// Default style that resolves field appearance based on ``POInputStyle`` in view's environment.
    static var `default`: DefaultCodeFieldStyle {
        DefaultCodeFieldStyle()
    }
}
