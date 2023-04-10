//
//  POImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

@available(*, deprecated, renamed: "POImagesRepository")
public typealias POImagesRepositoryType = POImagesRepository

public protocol POImagesRepository {

    /// Downloads image at given URL and calls completion. Completion is called with `nil` if
    /// some error happens.
    func image(url: URL, completion: @escaping (UIImage?) -> Void)
}
