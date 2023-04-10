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

    // MARK: - POImagesRepository

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
