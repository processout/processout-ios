//
//  View+GeometryGroup.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 25.10.2023.
//

import SwiftUI

extension POBackport where Wrapped: View {

    /// Isolates the geometry (e.g. position and size) of the view from its parent view.
    @available(iOS, deprecated: 17, message: "Use View/geometryGroup() directly.")
    @ViewBuilder
    public func geometryGroup() -> some View {
        if #available(iOS 17, *) {
            wrapped.geometryGroup()
        } else {
            // Based on the answer of Apple engineer at WWDC Digital Lounge, transformEffect(.identity) modifier
            // applied to the container, causes layout animations to occur at the level of the container. So using
            // it allows to achieve an effect similar to geometryGroup but on older iOS version.
            wrapped.transformEffect(.identity)
        }
    }
}
