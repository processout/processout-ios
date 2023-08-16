//
//  CollectionViewRadioViewModel.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.08.2023.
//

struct CollectionViewRadioViewModel: Hashable {

    /// Current value.
    let value: String

    /// Indicates whether radio button is selected.
    let isSelected: Bool

    /// Boolean value indicating whether value is valid.
    let isInvalid: Bool

    /// Radio button's accessibility identifier.
    let accessibilityIdentifier: String

    /// Closure to invoke when radio button is selected.
    @ImmutableNullHashable
    var select: () -> Void
}
