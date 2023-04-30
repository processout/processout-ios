//
//  NativeAlternativePaymentMethodCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import UIKit

protocol NativeAlternativePaymentMethodCell: UICollectionViewCell {

    /// Should return input responder if any.
    var inputResponder: UIResponder? { get }

    /// Cell delegate.
    var delegate: BetaNativeAlternativePaymentMethodCellDelegate? { get set }
}

protocol BetaNativeAlternativePaymentMethodCellDelegate: AnyObject {

    /// Should return boolean value indicating whether cells input should return ie resign first responder.
    func nativeAlternativePaymentMethodCellShouldReturn(_ cell: NativeAlternativePaymentMethodCell) -> Bool
}
