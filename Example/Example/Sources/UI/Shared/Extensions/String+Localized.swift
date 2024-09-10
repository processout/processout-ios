//
//  String+Localized.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

import Foundation

extension String {

    @_disfavoredOverload
    init(localized resource: LocalizedStringResource, replacements: any CVarArg...) {
        var options = String.LocalizationOptions()
        options.replacements = replacements
        self.init(localized: resource, options: options)
    }
}
