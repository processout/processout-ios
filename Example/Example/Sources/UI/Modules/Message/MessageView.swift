//
//  MessageView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

import SwiftUI

struct MessageView: View {

    let viewModel: MessageViewModel

    // MARK: - View

    var body: some View {
        let imageName: String, foregroundColor: Color
        switch viewModel.severity {
        case .success:
            imageName = "checkmark.circle.fill"
            foregroundColor = .green
        case .error:
            imageName = "xmark.circle.fill"
            foregroundColor = .red
        }
        return HStack {
            Image(systemName: imageName)
            Text(viewModel.text)
        }
        .foregroundStyle(foregroundColor)
    }
}
