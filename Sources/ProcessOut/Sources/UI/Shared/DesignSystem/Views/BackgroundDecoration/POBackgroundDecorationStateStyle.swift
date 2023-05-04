//
//  POBackgroundDecorationStateStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.12.2022.
//

import UIKit

public enum POBackgroundDecorationStateStyle: Equatable {

    /// Completly hidden decoration style.
    case hidden

    /// Visible decoration style rendered with specified colors.
    case visible(primaryColor: UIColor, secondaryColor: UIColor)
}
