//
//  Shape+ConstrainedRectangle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

import SwiftUI

extension Shape where Self == ConstrainedRectangle {

    /// A rectangle shape with a minimum size of 44x44 points, ensuring it meets the standard
    /// clickable area requirements according to Human Interface Guidelines (HIG).
    static var standardHittableRect: ConstrainedRectangle {
        ConstrainedRectangle(minSize: CGSize(width: 44, height: 44))
    }
}
