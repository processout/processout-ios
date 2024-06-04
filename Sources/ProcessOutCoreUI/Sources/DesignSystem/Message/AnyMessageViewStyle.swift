//
//  AnyMessageViewStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

struct AnyMessageViewStyle: POMessageViewStyle {

    init(erasing style: any POMessageViewStyle) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }

    // MARK: - Private Properties

    private let _makeBody: (Configuration) -> AnyView
}
