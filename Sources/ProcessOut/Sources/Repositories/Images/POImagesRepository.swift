//
//  POImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

@_spi(PO)
public protocol POImagesRepository: PORepository { // sourcery: AutoCompletion

    /// Attempts to download images at given URLs.
    func images(at urls: [URL], scale: CGFloat) async -> [URL: UIImage]
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

    /// Downloads image for given resource.
    @MainActor
    public func image(resource: POImageRemoteResource) async -> UIImage? {
        async let lightImage = image(at: resource.lightUrl.raster, scale: resource.lightUrl.scale)
        async let darkImage  = image(at: resource.darkUrl?.raster, scale: resource.darkUrl?.scale ?? 1)
        return await UIImage.dynamic(lightImage: lightImage, darkImage: darkImage)
    }
}
