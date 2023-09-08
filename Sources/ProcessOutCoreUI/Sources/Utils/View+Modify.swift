//
//  View+Extensions.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 04.09.2023.
//

import SwiftUI

extension View {

    func modify<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
