//
//  RetryPolicy.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/09/2019.
//

import Foundation
import Alamofire

class RetryPolicy: RequestRetrier {
    
    private var currentRetriedRequests: [String: Int] = [:]
    private let RETRY_INTERVAL: TimeInterval = 0.1; // Retry after .1s
    private let MAXIMUM_RETRIES = 2

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard request.task?.response == nil, let url = request.request?.url?.absoluteString else {
            clearRetriedForUrl(url: request.request?.url?.absoluteString)
            completion(false, 0.0) // Shouldn't retry
            return
        }
        
        guard let retryCount = currentRetriedRequests[url] else {
            // Should retry
            currentRetriedRequests[url] = 1
            completion(true, RETRY_INTERVAL)
            return
        }
        
        if retryCount <= MAXIMUM_RETRIES {
            // Should retry
            currentRetriedRequests[url] = retryCount + 1
            completion(true, RETRY_INTERVAL)
        } else {
            // Shouldn't retry
            clearRetriedForUrl(url: url)
            completion(false, 0.0)
        }
    }
    
    private func clearRetriedForUrl(url: String?) {
        guard let url = url else {
            return
        }

        currentRetriedRequests.removeValue(forKey: url)
    }
}
