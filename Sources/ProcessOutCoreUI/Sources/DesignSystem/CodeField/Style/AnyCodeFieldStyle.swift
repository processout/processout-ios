//
//  AnyCodeFieldStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

struct AnyCodeFieldStyle: CodeFieldStyle {

    init(erasing style: some CodeFieldStyle) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: CodeFieldStyleConfiguration) -> some View {
        _makeBody(configuration)
    }

    // MARK: - Private Properties

    private let _makeBody: (CodeFieldStyleConfiguration) -> AnyView
}
