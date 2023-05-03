//
//  PassthroughView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.05.2023.
//

import UIKit

final class PassthroughView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view !== self else {
            return nil
        }
        return view
    }
}
