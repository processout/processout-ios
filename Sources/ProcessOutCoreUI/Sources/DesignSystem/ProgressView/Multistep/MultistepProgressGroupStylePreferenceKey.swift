//
//  MultistepProgressGroupStylePreferenceKey.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.04.2025.
//

import SwiftUI

struct MultistepProgressGroupStylePreferenceKey: PreferenceKey {

    struct ProgressViewProxy {

        /// The completed fraction of the task represented by the progress view.
        let fractionCompleted: Double?

        /// Connector anchor rectangle.
        let connectorAnchor: Anchor<CGRect>
    }

    // MARK: - PreferenceKey

    static var defaultValue: [ProgressViewProxy] = []

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}
