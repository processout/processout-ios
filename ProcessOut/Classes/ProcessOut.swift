
import Alamofire
import Foundation
import PassKit

public class ProcessOut {
    
    public enum ProcessOutException: Error {
        case NetworkError
        case MissingProjectId
        case BadRequest(errorMessage: String, errorCode: String)
        case InternalError
    }
    
    public struct Card {
        var CardNumber: String
        var ExpMonth: Int
        var ExpYear: Int
        var CVC: String?
        var Name: String
        
        public init(cardNumber: String, expMonth: Int, expYear: Int, cvc: String?, name: String) {
            self.CardNumber = cardNumber
            self.ExpMonth = expMonth
            self.ExpYear = expYear
            self.CVC = cvc
            self.Name = name
        }
    }

    private static var ApiUrl: String = "https://api.processout.com"
    private static var ProjectId: String?
    
    public static func Setup(projectId: String) {
        ProcessOut.ProjectId = projectId
    }
    
    public static func Tokenize(card: Card, metadata: [String: Any]?, completion: @escaping (String?, ProcessOutException?) -> Void) {
        var parameters: [String: Any] = [:]
        if let metadata = metadata {
            parameters["metadata"] = metadata
        }
        parameters["name"] = card.Name
        parameters["number"] = card.CardNumber
        parameters["exp_month"] = card.ExpMonth
        parameters["exp_year"] = card.ExpYear
        if let cvc = card.CVC {
            parameters["cvc2"] = cvc
        }
      
        HttpRequest(route: "/cards", method: .post, parameters: parameters) { (tokenResponse, error) in
            if let card = tokenResponse?["card"] as? [String: Any], let token = card["id"] as? String {
                completion(token, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    public static func UpdateCvc(cardId: String, newCvc: String, completion: @escaping (ProcessOutException?) -> Void) {
        let parameters: [String: Any] = [
            "cvc": newCvc
        ]
        
        HttpRequest(route: "/cards/" + cardId, method: .put, parameters: parameters) { (response, error) in
            completion(error)
        }
    }
    
    private static func HttpRequest(route: String, method: HTTPMethod, parameters: Parameters, completion: @escaping ([String: Any]?, ProcessOutException?) -> Void) {
        guard let projectId = ProjectId, let authorizationHeader = Request.authorizationHeader(user: projectId, password: "") else {
            completion(nil, ProcessOutException.MissingProjectId)
            return
        }
      
        var headers: HTTPHeaders = [:]
      
        headers[authorizationHeader.key] = authorizationHeader.value
        Alamofire.request(ApiUrl + route, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {(response) -> Void in
            if let data = response.result.value as? [String: Any] {
                if let success = data["success"] as? Bool, success {
                    completion(data, nil)
                } else {
                    if let errorMessage = data["message"] as? String, let errorType = data["error_type"] as? String {
                        completion(nil, ProcessOutException.BadRequest(errorMessage: errorMessage, errorCode: errorType))
                    } else {
                        completion(nil, ProcessOutException.InternalError)
                    }
                }
            } else {
                completion(nil, ProcessOutException.NetworkError)
            }
        })
    }
    
}

