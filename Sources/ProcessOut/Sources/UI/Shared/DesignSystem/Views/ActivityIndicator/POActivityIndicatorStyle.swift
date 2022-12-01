//
//  POActivityIndicatorStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

public enum POActivityIndicatorStyle {

    /// Custom actvity indicator.
    case custom(ActivityIndicatorViewType)

    /// System activity indicator.
    case system(UIActivityIndicatorView.Style)
}
