//
//  ProgressView.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.10.2023.
//

import SwiftUI

@available(iOS, deprecated: 14)
extension POBackport where Wrapped == Any {

    @_spi(PO) public struct ProgressView: View {

        public var body: some View {
            style.makeBody()
        }

        // MARK: - Private Properties

        @Environment(\.backportProgressViewStyle) private var style
    }
}
