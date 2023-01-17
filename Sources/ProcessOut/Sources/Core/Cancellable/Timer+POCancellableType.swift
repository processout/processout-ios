//
//  Timer+POCancellableType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.01.2023.
//

import Foundation

extension Timer: POCancellableType {

    public func cancel() {
        invalidate()
    }
}
