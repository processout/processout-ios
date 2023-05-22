//
//  NativeAlternativePaymentMethodSeparatorView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.05.2023.
//

import UIKit

final class NativeAlternativePaymentMethodSeparatorView: UICollectionReusableView {

    func configure(color: UIColor?) {
        backgroundColor = color ?? Constants.defaultColor
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let defaultColor = Asset.Colors.New.Border.subtle.color
    }
}
