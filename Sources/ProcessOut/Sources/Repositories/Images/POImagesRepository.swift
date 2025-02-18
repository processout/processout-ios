//
//  POImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

@_spi(PO)
public protocol POImagesRepository: PORepository {

    /// Downloads image at given URL.
    func image(at url: URL, scale: CGFloat) async -> UIImage?

    /// Attempts to download images at given URLs.
    func images(at urls: [URL], scale: CGFloat) async -> [URL: UIImage]

    /// Downloads image for given resource.
    func image(resource: POImageRemoteResource) async -> UIImage?
}

extension POImagesRepository {

    /// Attempts to download images at given URLs.
    public func images(at urls: [URL]) async -> [URL: UIImage] {
        await images(at: urls, scale: 1)
    }

    /// Downloads image at given URL.
    public func image(at url: URL?, scale: CGFloat = 1) async -> UIImage? {
        let urls = [url].compactMap { $0 }
        return await images(at: urls, scale: scale).values.first
    }

    /// Downloads two images at given URLs.
    public func images(at url1: URL?, _ url2: URL?, scale: CGFloat = 1) async -> (UIImage?, UIImage?) {
        let urls = [url1, url2].compactMap { $0 }
        let images = await images(at: urls, scale: scale) as [URL?: UIImage]
        return (images[url1], images[url2])
    }
}
