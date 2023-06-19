//
//  PickerViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.04.2023.
//

struct PickerViewModel {

    struct Option {

        /// Option title.
        let title: String

        /// Indicates whether option is currently selected.
        let isSelected: Bool

        /// Closure to invoke when option is selected.
        let select: () -> Void
    }

    /// Button's title.
    let title: String

    /// Boolean flag indicating whether input is invalid.
    let isInvalid: Bool

    /// Picker options.
    let options: [Option]
}
