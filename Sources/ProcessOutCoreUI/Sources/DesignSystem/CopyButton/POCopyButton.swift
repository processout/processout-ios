//
//  POCopyButton.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

/// A button that adds a value to the pasteboard.
@available(iOS 14.0, *)
@_spi(PO)
public struct POCopyButton: View {

    /// Configuration for `POCopyButton`, allowing customization of the copied value and displayed text.
    public struct Configuration {

        /// Creates a new configuration for `POCopyButton`.
        ///
        /// - Parameters:
        ///   - value: The string to be copied to the pasteboard.
        ///   - copyTitle: The text shown before the copy action. Default is `"Copy"`.
        ///   - copiedTitle: The text shown after the value has been copied. Default is `"Copied!"`.
        public init(value: String, copyTitle: String, copiedTitle: String) {
            self.value = value
            self.copyTitle = copyTitle
            self.copiedTitle = copiedTitle
        }

        /// The string value to be copied to the pasteboard when the button is tapped.
        let value: String

        /// The text shown on the button before the value is copied.
        let copyTitle: String

        /// The text shown on the button after the value has been copied.
        let copiedTitle: String
    }

    public init(configuration: Configuration) {
        self.configuration = configuration
        isShowingCopiedMessage = false
    }

    // MARK: - View

    public var body: some View {
        Button {
            copyToPasteboard()
        } label: {
            Label {
                Text(isShowingCopiedMessage ? configuration.copiedTitle : configuration.copyTitle)
            } icon: {
                Image(poResource: isShowingCopiedMessage ? .check : .docOnDoc)
                    .resizable()
                    .renderingMode(.template)
            }
        }
        .onDisappear {
            messageInvalidationTimer?.invalidate()
        }
        .animation(.default, value: isShowingCopiedMessage)
    }

    // MARK: - Private Properties

    private let configuration: Configuration

    @State
    private var messageInvalidationTimer: Timer?

    @State
    private var isShowingCopiedMessage: Bool

    // MARK: - Private Methods

    private func copyToPasteboard() {
        messageInvalidationTimer?.invalidate()
        messageInvalidationTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            isShowingCopiedMessage = false
        }
        isShowingCopiedMessage = true
        UIPasteboard.general.string = configuration.value
    }
}
