//
//  AlternativePaymentsView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import SwiftUI

@MainActor
struct AlternativePaymentsView: View {

    // MARK: - View

    var body: some View {
        List(selection: $selectedItemId) {
            ForEach(viewModel.state.sections) { section in
                Section {
                    ForEach(section.items) { item in
                        switch item {
                        case .configuration(let item):
                            HStack {
                                Text(item.name)
                                    .contentShape(.rect)
                                    .onTapGesture(perform: item.select)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        case .error(let item):
                            Label {
                                Text(item.errorMessage)
                            } icon: {
                                Image(systemName: "exclamationmark.octagon").foregroundColor(.red)
                            }
                        }
                    }
                } header: {
                    if let title = section.title {
                        Text(title)
                    }
                }
            }
        }
        .animation(.default, value: viewModel.state.sections.flatMap(\.id))
        .listStyle(.insetGrouped)
        .onChange(of: selectedItemId) {
            selectedItemId = nil
        }
        .refreshable {
            await viewModel.restart()
        }
        .onAppear(perform: viewModel.start)
        .navigationTitle(String(localized: .AlternativePayments.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @State
    private var selectedItemId: String?

    @State
    private var viewModel = AlternativePaymentsViewModel()
}
