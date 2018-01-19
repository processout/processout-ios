
import Alamofire
import Foundation

public class ProcessOut {
    
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

    private static var ApiUrl: String = "https://api.processout.ninja"
    private static var ProjectId: String?
    
    
    public static func Setup(projectId: String) {
        ProcessOut.ProjectId = projectId
    }
    
    public static func Tokenize(card: Card, metadata: [String: Any]?, completion: @escaping (String?, POError?) -> Void) {
        var parameters: [String: Any] = [:]
        parameters["number"] = card.CardNumber
        GenerateToken(card: card, metadata: metadata, completion: {(tokenResponse, error) -> Void in
            if error != nil || tokenResponse == nil {
                completion(nil, error)
            } else {
                if let card = tokenResponse!["card"] as? [String: Any], let token = card["id"] as? String {
                    completion(token, nil)
                } else {
                    completion(nil, POError.InternalError)
                }
            }
        })
    }
    
    public static func UpdateCvc(cardId: String, newCvc: String, completion: @escaping (POError?) -> Void) {
        let parameters: [String: Any] = [
            "cvc": newCvc
        ]
        
        HttpRequest(route: "/cards/" + cardId, method: .put, parameters: parameters) { (response, error) in
            completion(error)
        }
    }
    
    private static func GenerateToken(card: Card, metadata: [String: Any]?, completion: @escaping ([String: Any]?, POError?) -> Void) {
        var parameters: [String: Any] = [:]
        if metadata != nil {
            parameters["metadata"] = metadata!
        }
        parameters["name"] = card.Name
        parameters["number"] = card.CardNumber
        parameters["exp_month"] = card.ExpMonth
        parameters["exp_year"] = card.ExpYear
        if card.CVC != nil {
            parameters["cvc2"] = card.CVC!
        }
    
        
        HttpRequest(route: "/cards", method: .post, parameters: parameters, completion: completion)

    }
    
    private static func HttpRequest(route: String, method: HTTPMethod, parameters: Parameters, completion: @escaping ([String: Any]?, POError?) -> Void) {
        var headers: HTTPHeaders = [:]
        if let projectId = ProjectId, let authorizationHeader = Request.authorizationHeader(user: projectId, password: "") {
            headers[authorizationHeader.key] = authorizationHeader.value
            Alamofire.request(ApiUrl + route, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: {(response) -> Void in
                if let data = response.result.value as? [String: Any] {
                    if let success = data["success"] as? Bool, success {
                        completion(data, nil)
                    } else {
                        if let errorType = data["error_type"] as? String {
                            completion(nil, POError.BadRequest(error: errorType))
                        } else {
                            completion(nil, POError.NetworkError)
                        }
                    }
                } else {
                    completion(nil, POError.NetworkError)
                }
            })
        } else {
            completion(nil, POError.MissingProjectId)
        }
    }

    public enum POError: Error {
        case NetworkError
        case MissingProjectId
        case BadRequest(error: String)
        case InternalError
    }

    
}

