//
//  CardTokenizationInlineControlView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.07.2025.
//

@_spi(PO) import ProcessOutCoreUI
import SwiftUI

struct CardTokenizationInlineControlGroupView: View {

    let configuration: CardTokenizationViewModelControlGroup

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.space12) {
            ForEach(configuration.buttons) { button in
                Button.create(with: button).buttonStyle(
                    forPrimaryRole: style.actionsContainer.primary, fallback: style.actionsContainer.secondary
                )
            }
        }
        .padding(.top, POSpacing.space8)
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style
}
