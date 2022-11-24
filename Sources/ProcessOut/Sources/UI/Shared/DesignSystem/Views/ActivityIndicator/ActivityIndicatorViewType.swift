//
//  ActivityIndicatorViewType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

public protocol ActivityIndicatorViewType: UIView {

    /// Changes animation state.
    func setAnimating(_ isAnimating: Bool)

    /// A Boolean value that controls whether the receiver is hidden when the animation is stopped.
    ///
    /// If the value of this property is `true`, the receiver sets its `isHidden` property to `true`
    /// when receiver is not animating. Otherwise the receiver is not hidden when animation stops.
    var hidesWhenStopped: Bool { get set }
}
