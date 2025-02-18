//
//  UrlSessionImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

final class UrlSessionImagesRepository: POImagesRepository {

    init(session: URLSession) {
        self.session = session
        cache = .init()
    }

    // MARK: - ImagesRepository

    func image(at url: URL, scale: CGFloat) async -> UIImage? {
        let cacheKey = ImageResource.url(url, scale: scale)
        if let image = cache.value(forKey: cacheKey) {
            return image
        }
        guard let image = try? await UIImage(data: session.data(from: url).0, scale: scale) else {
            return nil
        }
        let scaledImage = image.rescaledToMatchDeviceScale()
        cache.insert(scaledImage, forKey: cacheKey)
        return scaledImage
    }

    func images(at urls: [URL], scale: CGFloat) async -> [URL: UIImage] {
        await withTaskGroup(of: (URL, UIImage?).self, returning: [URL: UIImage].self) { group in
            for url in urls {
                group.addTask {
                    let image = await self.image(at: url, scale: scale)
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

    func image(resource: POImageRemoteResource) async -> UIImage? {
        if let image = cache.value(forKey: .remote(resource)) {
            return image
        }
        async let lightImage = image(at: resource.lightUrl.raster, scale: resource.lightUrl.scale)
        async let darkImage  = image(at: resource.darkUrl?.raster, scale: resource.darkUrl?.scale ?? 1)
        guard let image = await UIImage.dynamic(lightImage: lightImage, darkImage: darkImage) else {
            return nil
        }
        cache.insert(image, forKey: .remote(resource))
        return image
    }

    // MARK: - Private Nested Types

    private enum ImageResource: Sendable, Hashable {
        case url(URL, scale: CGFloat), remote(POImageRemoteResource)
    }

    // MARK: - Private Properties

    private let session: URLSession
    private let cache: Cache<ImageResource, UIImage>
}
