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
    }

    // MARK: - ImagesRepository

    func images(at urls: [URL], scale: CGFloat) async -> [URL: UIImage] {
        await withTaskGroup(of: (URL, UIImage?).self, returning: [URL: UIImage].self) { [session] group in
            for url in urls {
                group.addTask {
                    let image = try? await UIImage(data: session.data(from: url).0, scale: scale)
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
}
