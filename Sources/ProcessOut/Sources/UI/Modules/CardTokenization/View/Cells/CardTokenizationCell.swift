//
//  CardTokenizationCell.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import UIKit

protocol CardTokenizationCell: UICollectionViewCell {

    /// Tells the cell that it is about to be displayed.
    func willDisplay()

    /// Tells the cell that it was removed from the collection view.
    func didEndDisplaying()

    /// Should return input responder if any.
    var inputResponder: UIResponder? { get }

    /// Cell delegate.
    var delegate: CardTokenizationCellDelegate? { get set }
}

protocol CardTokenizationCellDelegate: AnyObject {

    /// Should return boolean value indicating whether cells input should return ie resign first responder.
    func cardTokenizationCellShouldReturn(_ cell: CardTokenizationCell) -> Bool

    /// Should return boolean value indicating whether editing is currently allowed.
    func cardTokenizationCellShouldBeginEditing(_ cell: CardTokenizationCell) -> Bool
}
