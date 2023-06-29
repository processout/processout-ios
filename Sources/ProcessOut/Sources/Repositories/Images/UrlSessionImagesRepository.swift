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

    // MARK: - POImagesRepository

    func images(at urls: [URL], completion: @escaping ([URL: UIImage]) -> Void) {
        let lock = NSLock()
        let dispatchGroup = DispatchGroup()
        var images: [URL: UIImage] = [:]
        urls.forEach { url in
            dispatchGroup.enter()
            let request = URLRequest(url: url)
            let task = session.dataTask(with: request) { data, _, _ in
                let image = data.flatMap(UIImage.init)
                lock.withLock {
                    images[url] = image
                }
                dispatchGroup.leave()
            }
            task.resume()
        }
        dispatchGroup.notify(queue: .main) { completion(images) }
    }

    // MARK: - Private Properties

    private let session: URLSession
}
