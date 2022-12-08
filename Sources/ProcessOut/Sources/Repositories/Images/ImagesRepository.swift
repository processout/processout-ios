//
//  ImagesRepository.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.12.2022.
//

import Foundation
import class UIKit.UIImage

final class ImagesRepository: POImagesRepositoryType {

    init(session: URLSession) {
        self.session = session
    }

    // MARK: - POImagesRepositoryType

    func image(url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, _, _ in
            let image = data.flatMap(UIImage.init)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }

    // MARK: - Private Properties

    private let session: URLSession
}
