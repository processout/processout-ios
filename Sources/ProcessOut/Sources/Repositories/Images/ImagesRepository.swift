//
//  ImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

protocol ImagesRepository {

    /// Downloads image at given URL and calls completion. Completion is called with `nil` if
    /// some error happens.
    func image(url: URL, completion: @escaping (UIImage?) -> Void)
}
