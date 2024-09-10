//
//  Picker+Data.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

import SwiftUI

struct PickerData<T, Id: Hashable> {

    /// Available sources.
    let sources: [T]

    /// The key path to the provided data’s identifier.
    let id: KeyPath<T, Id>

    /// Current selection.
    var selection: Id
}

extension Picker {

    /// Creates picker with given data.
    init<T, C: View>(
        data: Binding<PickerData<T, SelectionValue>>,
        @ViewBuilder content: @escaping (T) -> C,
        @ViewBuilder label: () -> Label
    ) where Content == ForEach<[T], SelectionValue, C> {
        self.init(selection: data.selection) {
            ForEach(data.wrappedValue.sources, id: data.wrappedValue.id) { element in
                content(element)
            }
        } label: {
            label()
        }
    }
}
