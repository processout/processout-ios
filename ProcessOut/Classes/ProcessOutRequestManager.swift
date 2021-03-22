//
//  ProcessOutRequest.swift
//  ProcessOut
//
//  Created by Mauro Vime Castillo on 15/2/21.
//

import Foundation

final class ProcessOutRequestManager {
    
    let apiUrl: String
    let apiVersion: String
    let defaultUserAgent: String
    
    let sessionDelegate: SessionDelegate
    let retryPolicy: RetryPolicy
    let urlSession: URLSession
    
    init(apiUrl: String, apiVersion: String, defaultUserAgent: String) {
        self.apiUrl = apiUrl
        self.apiVersion = apiVersion
        self.defaultUserAgent = defaultUserAgent
        
        let retryPolicy = RetryPolicy()
        self.retryPolicy = retryPolicy
        
        let sessionDelegate = SessionDelegate()
        sessionDelegate.retrier = retryPolicy
        self.sessionDelegate = sessionDelegate
        
        self.urlSession = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: .main)
    }
    
    func HttpRequest(route: String, method: HTTPMethod, parameters: [String: Any]?, completion: @escaping (Data?, ProcessOutException?) -> Void) {
        guard let projectId = ProcessOut.ProjectId, let authorizationHeader = self.authorizationHeader(user: projectId, password: "") else {
            completion(nil, ProcessOutException.MissingProjectId)
            return
        }
        
        do {
            guard let url = NSURL(string: self.apiUrl + route) else {
                completion(nil, ProcessOutException.InternalError)
                return
            }
            
            var request = URLRequest(url: url as URL)
            request.httpMethod = method.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(authorizationHeader.value, forHTTPHeaderField: authorizationHeader.key)
            request.setValue(self.defaultUserAgent + " ProcessOut iOS-Bindings/" + self.apiVersion, forHTTPHeaderField: "User-Agent")
            request.setValue(UUID().uuidString, forHTTPHeaderField: "Idempotency-Key")
            request.timeoutInterval = 15
            
            if let body = parameters {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            }
            
            
            self.urlSession.dataTask(with: request) { [weak self] (data, _, _) in
                guard let data = data else {
                    completion(nil, ProcessOutException.NetworkError)
                    return
                }
                
                self?.handleNetworkResult(data: data, completion: completion)
            }
            .resume()
        } catch {
            completion(nil, ProcessOutException.InternalError)
        }
    }
    
    private func handleNetworkResult(data: Data, completion: @escaping (Data?, ProcessOutException?) -> Void) {
        do {
            let result = try JSONDecoder().decode(ApiResponse.self, from: data)
            if result.success {
                completion(data, nil)
                return
            }
            
            if let message = result.message, let errorType = result.errorType {
                completion(nil, ProcessOutException.BadRequest(errorMessage: message, errorCode: errorType))
                return
            }
            
            completion(nil, ProcessOutException.NetworkError)
        } catch {
            completion(nil, ProcessOutException.InternalError)
        }
    }
    
    private func authorizationHeader(user: String, password: String) -> (key: String, value: String)? {
        guard let data = "\(user):\(password)".data(using: .utf8) else { return nil }
        
        let credential = data.base64EncodedString(options: [])
        
        return (key: "Authorization", value: "Basic \(credential)")
    }
    
}

final class SessionDelegate: NSObject, URLSessionDelegate {
    
    var retrier: RequestRetrier?
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
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
