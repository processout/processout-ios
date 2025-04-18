//
//  POSystemContentUnavailableViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

/// The content unavailable view style that uses system `ContentUnavailableView`.
@available(iOS 17, *)
public struct POSystemContentUnavailableViewStyle: POContentUnavailableViewStyle {

    public func makeBody(configuration: Configuration) -> some View {
        ContentUnavailableView {
            configuration.label
        } description: {
            configuration.description
        }
    }
}

@available(iOS 17, *)
extension POContentUnavailableViewStyle where Self == POSystemContentUnavailableViewStyle {

    /// The content unavailable view style that uses system `ContentUnavailableView`.
    public static var system: POSystemContentUnavailableViewStyle {
        POSystemContentUnavailableViewStyle()
    }
}
