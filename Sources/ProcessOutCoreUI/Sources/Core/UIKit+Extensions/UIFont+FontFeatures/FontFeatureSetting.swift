//
//  FontFeatureSetting.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

protocol FontFeatureSetting {

    /// Indicates a general class of effect (e.g., ligatures).
    var featureType: Int { get }

    /// Indicates the specific effect (e.g., rare ligature).
    var featureSelector: Any { get }
}
