//
//  POActivityIndicatorStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

/// Possible activity indicator styles.
@available(*, deprecated, message: "Use ProcessOutUI module.")
public enum POActivityIndicatorStyle {

    /// Custom activity indicator.
    case custom(POActivityIndicatorView)

    /// System activity indicator.
    case system(UIActivityIndicatorView.Style, color: UIColor? = nil)
}
