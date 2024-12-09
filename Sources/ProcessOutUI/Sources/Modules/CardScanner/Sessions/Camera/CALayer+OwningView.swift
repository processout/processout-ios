//
//  CALayer+OwningView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

import UIKit

extension CALayer {

    @MainActor
    var owningView: UIView? {
        var currentLayer: CALayer? = self
        while let current = currentLayer {
            if let view = current.delegate as? UIView {
                return view
            }
            currentLayer = current.superlayer
        }
        return nil
    }
}
