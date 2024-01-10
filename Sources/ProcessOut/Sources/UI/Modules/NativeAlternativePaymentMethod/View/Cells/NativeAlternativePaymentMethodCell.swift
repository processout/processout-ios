//
//  NativeAlternativePaymentMethodCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.04.2023.
//

import UIKit

@available(*, deprecated)
protocol NativeAlternativePaymentMethodCell: UICollectionViewCell {

    /// Tells the cell that it is about to be displayed.
    func willDisplay()

    /// Tells the cell that it was removed from the collection view.
    func didEndDisplaying()

    /// Should return input responder if any.
    var inputResponder: UIResponder? { get }

    /// Cell delegate.
    var delegate: NativeAlternativePaymentMethodCellDelegate? { get set }
}

@available(*, deprecated)
protocol NativeAlternativePaymentMethodCellDelegate: AnyObject {

    /// Should return boolean value indicating whether cells input should return ie resign first responder.
    func nativeAlternativePaymentMethodCellShouldReturn(_ cell: NativeAlternativePaymentMethodCell) -> Bool
}
