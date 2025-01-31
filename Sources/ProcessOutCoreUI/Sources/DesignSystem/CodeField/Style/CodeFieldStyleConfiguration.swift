//
//  CodeFieldStyleConfiguration.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

struct CodeFieldStyleConfiguration {

    /// Text.
    let text: String

    /// Code field maximum length
    let length: Int

    /// Current index.
    @Binding
    var insertionPoint: String.Index?

    /// Boolean value indicating whether code field is currently being edited.
    let isEditing: Bool

    init(text: String, length: Int, insertionPoint: Binding<String.Index?>, isEditing: Bool) {
        self.text = text
        self.length = length
        self._insertionPoint = insertionPoint
        self.isEditing = isEditing
    }
}
