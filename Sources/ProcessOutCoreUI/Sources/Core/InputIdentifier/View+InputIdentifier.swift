//
//  View+InputIdentifier.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.10.2023.
//

import SwiftUI

struct InputIdentifierPreferenceKey: PreferenceKey, Equatable {

    static var defaultValue: String?

    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}

extension View {

    func inputIdentifier(_ identifier: String) -> some View {
        preference(key: InputIdentifierPreferenceKey.self, value: identifier)
    }
}
