//
//  RetryPolicy.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/09/2019.
//

import Foundation

typealias RequestRetryCompletion = (_ shouldRetry: Bool, _ timeDelay: TimeInterval) -> Void

protocol RequestRetrier {
    
    func should(_ session: URLSession, retry task: URLSessionTask, with error: Error, completion: @escaping RequestRetryCompletion)
}

final class RetryPolicy: RequestRetrier {
    
    private var currentRetriedRequests: [String: Int] = [:]
    private let RETRY_INTERVAL: TimeInterval = 0.1 // Retry after .1s
    private let MAXIMUM_RETRIES = 2
    
    func should(_ session: URLSession, retry task: URLSessionTask, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard task.response == nil, let url = task.currentRequest?.url?.absoluteString else {
            clearRetriedForUrl(url: task.currentRequest?.url?.absoluteString)
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
            return
        }
        
        // Shouldn't retry
        clearRetriedForUrl(url: url)
        completion(false, 0.0)
    }
    
    private func clearRetriedForUrl(url: String?) {
        guard let url = url else {
            return
        }
        
        currentRetriedRequests.removeValue(forKey: url)
    }
}
