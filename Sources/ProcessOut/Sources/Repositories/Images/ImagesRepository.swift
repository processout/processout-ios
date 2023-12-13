//
//  ImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

protocol ImagesRepository: POAutoCompletion {

    /// Attempts to download images at given URLs.
    func images(at urls: [URL]) async -> [URL: UIImage]
}

extension ImagesRepository {

    /// Downloads image at given URL and calls completion.
    func image(at url: URL?) async -> UIImage? {
        let urls = [url].compactMap { $0 }
        return await images(at: urls).values.first
    }

    /// Downloads two images at given URLs and calls completion.
    func images(at url1: URL?, _ url2: URL?) async -> (UIImage?, UIImage?) {
        let urls = [url1, url2].compactMap { $0 }
        let images = await images(at: urls) as [URL?: UIImage]
        return (images[url1], images[url2])
    }
}
