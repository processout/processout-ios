//
//  POImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

@_spi(PO) public protocol POImagesRepository {

    /// Attempts to download images at given URLs.
    func images(at urls: [URL], completion: @escaping ([URL: UIImage]) -> Void)
}

extension POImagesRepository {

    /// Downloads image at given URL and calls completion.
    public func image(at url: URL?, completion: @escaping (UIImage?) -> Void) {
        let urls = [url].compactMap { $0 }
        images(at: urls) { images in
            completion(images.values.first)
        }
    }

    /// Downloads two images at given URLs and calls completion.
    public func images(at url1: URL?, _ url2: URL?, completion: @escaping (UIImage?, UIImage?) -> Void) {
        let urls = [url1, url2].compactMap { $0 }
        images(at: urls) { images in
            let images = images as [URL?: UIImage]
            completion(images[url1], images[url2])
        }
    }
}
