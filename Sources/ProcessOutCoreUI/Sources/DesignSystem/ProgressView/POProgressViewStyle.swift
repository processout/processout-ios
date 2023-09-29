//
//  POProgressViewStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

/// Possible progress view styles.
public enum POProgressViewStyle: Hashable {

    /// Custom actvity indicator.
    case custom(POProgressViewProvider)

    /// System progress view indicator.
    case system(UIActivityIndicatorView.Style = .medium, color: UIColor? = nil)
}

public struct POProgressViewProvider: Hashable {

    /// Provider identifier.
    public let id: AnyHashable

    /// Creates
    public let makeView: () -> UIView

    public init(id: AnyHashable, makeView: @escaping () -> UIView) {
        self.id = id
        self.makeView = makeView
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
