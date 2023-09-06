//
//  POActivityIndicatorStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

/// Possible activity indicator styles.
public enum POActivityIndicatorStyle {

    public typealias ViewFactory = () -> UIView

    /// Custom actvity indicator.
    case custom(ViewFactory)

    /// System activity indicator.
    case system(UIActivityIndicatorView.Style = .medium, color: UIColor? = nil)
}
