//
//  RetryPolicy.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/09/2019.
//

import Foundation

public typealias MyRequestRetryCompletion = (_ shouldRetry: Bool, _ timeDelay: TimeInterval) -> Void

protocol MyRequestRetrier {
  
  func should(_ session: URLSession, retry task: URLSessionTask, with error: Error, completion: @escaping MyRequestRetryCompletion)
  
}

class MyRetryPolicy: MyRequestRetrier {
    
    private var currentRetriedRequests: [String: Int] = [:]
    private let RETRY_INTERVAL: TimeInterval = 0.1; // Retry after .1s
    private let MAXIMUM_RETRIES = 2

  func should(_ session: URLSession, retry task: URLSessionTask, with error: Error, completion: @escaping MyRequestRetryCompletion) {
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

class MySessionDelegate: NSObject, URLSessionDelegate {
  
  var retrier: MyRequestRetrier?
  
  open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
      if let retrier = retrier, let error = error {
          retrier.should(session, retry: task, with: error) { [weak task] shouldRetry, timeDelay in
              guard shouldRetry else {
                return
              }

              DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + timeDelay) {
                  guard let request = task?.currentRequest else {
                    return
                  }
                
                session.dataTask(with: request).resume()
              }
          }
      }
  }
  
}
