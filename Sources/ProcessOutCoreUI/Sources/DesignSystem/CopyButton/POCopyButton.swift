//
//  POCopyButton.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

/// A button that adds value to the pasteboard.
@available(iOS 14.0, *)
@_spi(PO)
public struct POCopyButton: View {

    public init(value: String) {
        self.value = value
        isShowingCopiedMessage = false
    }

    // MARK: - View

    public var body: some View {
        Button {
            copyToPasteboard()
        } label: {
            Label {
                Text(isShowingCopiedMessage ? "Copied!" : "Copy")
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

    private let value: String

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
        UIPasteboard.general.string = value
    }
}

@available(iOS 14, *)
#Preview {
    POCopyButton(value: "Value")
        .buttonStyle(.secondary)
        .backport.poControlSize(.small)
        .controlWidth(.regular)
        .padding()
}
