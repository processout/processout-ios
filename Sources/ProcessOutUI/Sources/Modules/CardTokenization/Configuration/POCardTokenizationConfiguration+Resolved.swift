//
//  POCardTokenizationConfiguration+Resolved.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.04.2025.
//

extension POCardTokenizationConfiguration.PreferredScheme {

    /// Returns resolved configuration.
    func resolved(defaultTitle: @autoclosure () -> String?) -> POCardTokenizationConfiguration.PreferredScheme {
        let resolvedTitle: String? = if title?.isEmpty == true {
            nil
        } else {
            title ?? defaultTitle()
        }
        return .init(title: resolvedTitle, prefersInline: prefersInline)
    }
}
