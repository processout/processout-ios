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

    /// Downloads image for given resource.
    func image(resource: POImageRemoteResource, isolation: isolated (any Actor)?) async -> UIImage?
}

extension POImagesRepository {

    /// Downloads image for given resource.
    @_disfavoredOverload
    public func image(
        resource: POImageRemoteResource, isolation: isolated (any Actor)? = #isolation
    ) async -> UIImage? {
        await self.image(resource: resource, isolation: #isolation)
    }
}

extension POImagesRepository {

    /// Downloads image at given URL.
    public func image(
        at url: URL?, scale: CGFloat = 1, isolation: isolated (any Actor)? = #isolation
    ) async -> UIImage? {
        guard let url else {
            return nil
        }
        let resource = POImageRemoteResource(lightUrl: .init(raster: url, scale: scale), darkUrl: nil)
        return await image(resource: resource, isolation: isolation)
    }

    /// Downloads two images at given URLs.
    public func images(
        at url1: URL?, _ url2: URL?, scale: CGFloat = 1, isolation: isolated (any Actor)? = #isolation
    ) async -> (UIImage?, UIImage?) {
        let urls = [url1, url2].compactMap { $0 }
        let images = await images(at: urls, scale: scale, isolation: isolation) as [URL?: UIImage]
        return (images[url1], images[url2])
    }

    /// Attempts to download images at given URLs.
    public func images(
        at urls: [URL], scale: CGFloat = 1, isolation: isolated (any Actor)? = #isolation
    ) async -> [URL: UIImage] {
        await withTaskGroup(of: (URL, UIImage?).self, returning: [URL: UIImage].self) { group in
            for url in urls {
                group.addTask {
                    let image = await self.image(at: url, scale: scale, isolation: isolation)
                    return (url, image)
                }
            }
            var images: [URL: UIImage] = [:]
            for await (url, image) in group {
                images[url] = image
            }
            return images
        }
    }
}
