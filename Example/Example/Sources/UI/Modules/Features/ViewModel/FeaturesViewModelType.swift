//
//  FeaturesViewModelType.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

protocol FeaturesViewModelType: ViewModelType<FeaturesViewModelState> { }

enum FeaturesViewModelState {

    struct Feature {

        /// Feature name.
        let name: String

        /// Starts feature flow.
        let start: () -> Void
    }

    struct Started {

        /// Available features.
        let features: [Feature]
    }

    case idle, started(Started)
}

extension FeaturesViewModelState.Feature: Hashable {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
