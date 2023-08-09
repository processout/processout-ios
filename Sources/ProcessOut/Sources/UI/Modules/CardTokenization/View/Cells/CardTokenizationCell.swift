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
}
