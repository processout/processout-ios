//
//  UrlSessionImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

final class UrlSessionImagesRepository: POImagesRepository, @unchecked Sendable {

    init(session: URLSession) {
        self.session = session
        cache = .init()
    }

    // MARK: - ImagesRepository

    func image(at url: URL, scale: CGFloat) async -> UIImage? {
        let cacheKey = CacheKey(url: url, scale: scale)
        if let image = cache.object(forKey: cacheKey) {
            return image
        }
        if let image = try? await UIImage(data: session.data(from: url).0, scale: scale) {
            cache.setObject(image, forKey: cacheKey)
            return image
        }
        return nil
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

    // MARK: - Private Properties

    private let session: URLSession
    private let cache: NSCache<CacheKey, UIImage>
}

private final class CacheKey: NSObject {

    init(url: URL, scale: CGFloat) {
        self.url = url
        self.scale = scale
    }

    let url: URL, scale: CGFloat

    // MARK: - NSObject

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CacheKey else {
            return false
        }
        return url == other.url && scale == other.scale
    }

    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(url)
        hasher.combine(scale)
        return hasher.finalize()
    }
}
