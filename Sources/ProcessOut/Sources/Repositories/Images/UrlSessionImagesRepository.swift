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

    func image(resource: POImageRemoteResource, isolation: isolated (any Actor)?) async -> UIImage? {
        if let image = cache.value(forKey: resource) {
            return image
        }
        async let lightImage = image(at: resource.lightUrl), darkImage = image(at: resource.darkUrl)
        guard let image = await UIImage.dynamic(lightImage: lightImage, darkImage: darkImage) else {
            return nil
        }
        cache.insert(image, forKey: resource)
        return image
    }

    // MARK: - Private Properties

    private let session: URLSession
    private let cache: Cache<POImageRemoteResource, UIImage>

    // MARK: - Private Methods

    private func image(at resourceUrl: POImageRemoteResource.ResourceUrl?) async -> UIImage? {
        guard let resourceUrl else {
            return nil
        }
        do {
            let data = try await session.data(from: resourceUrl.raster).0
            return UIImage(data: data, scale: resourceUrl.scale)?.rescaledToMatchDeviceScale()
        } catch {
            return nil
        }
    }
}
