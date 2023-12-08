//
//  UrlSessionImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import UIKit

final class UrlSessionImagesRepository: ImagesRepository {

    init(session: URLSession) {
        self.session = session
    }

    // MARK: - ImagesRepository

    func images(at urls: [URL]) async -> [URL: UIImage] {
        let images = await withTaskGroup(of: UIImage?.self, returning: [UIImage?].self) { [session] group in
            for url in urls {
                group.addTask {
                    try? await UIImage(data: session.data(from: url).0)
                }
            }
            var images: [UIImage?] = []
            for await image in group {
                images.append(image)
            }
            return images
        }
        var groupedImages: [URL: UIImage] = [:]
        for (offset, image) in images.enumerated() {
            let url = urls[offset]
            groupedImages[url] = image
        }
        return groupedImages
    }

    // MARK: - Private Properties

    private let session: URLSession
}
