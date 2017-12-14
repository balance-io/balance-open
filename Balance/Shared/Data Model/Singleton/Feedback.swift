//
//  Feedback.swift
//  Bal
//
//  Created by Benjamin Baron on 7/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

let subServerBaseUrl = debugging.useLocalSubscriptionServer ? "http://localhost:8080" : "https://balance-server-eur.appspot.com"

struct Feedback {
    fileprivate static let sendFeedbackUrl = URL(string: "\(subServerBaseUrl)/feedback/send")!
    
    fileprivate static let session = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)
    
    static func send(apiInstitution: ApiInstitution? = nil, errorType: String? = nil, errorCode: String? = nil, email: String, comment: String, completion: @escaping SuccessErrorHandler) {
        do {
            // Required parameters
            var dict: [String: Any] = ["email": email,
                                       "appVersion": appVersionAndBuildString,
                                       "osVersion": osVersionString,
                                       "hardwareVersion": hardwareModelString,
                                       "comment": comment]
            
            // Optional parameters
            dict["errorType"] = errorType
            dict["errorCode"] = errorCode
            dict["source"] = apiInstitution?.source.rawValue
            dict["sourceInstitutionId"] = apiInstitution?.sourceInstitutionId
            dict["institutionName"] = apiInstitution?.name
            if let logsZipUrl = logging.zipLogFiles(), let logsData = try? Data(contentsOf: logsZipUrl), logsData.count < 2 * 1024 * 1024 {
                dict["logs"] = logsData.base64EncodedString()
            }
            
            var request = URLRequest(url: sendFeedbackUrl)
            request.timeoutInterval = 60.0
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.httpMethod = HTTPMethod.POST
            request.httpBody = try JSONSerialization.data(withJSONObject: dict)
            
            let task = session.dataTask(with: request) { data, _, error in
                guard let data = data else {
                    log.error("Error sending feedback email, no data")
                    async {
                        completion(false, BalanceError.noData)
                    }
                    return
                }
                
                guard error == nil else {
                    log.error("Error sending feedback email, network error: \(error!)")
                    async {
                        completion(false, BalanceError.networkError)
                    }
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let jsonDict = json else {
                    log.error("Error sending feedback email, error parsing json")
                    async {
                        completion(false, BalanceError.jsonDecoding)
                    }
                    return
                }
                
                guard let code = jsonDict["code"] as? Int else {
                    log.error("Error sending feedback email, unexpected data returned")
                    async {
                        completion(false, BalanceError.unexpectedData)
                    }
                    return
                }
                
                guard code == BalanceError.success.rawValue else {
                    let error = BalanceError(rawValue: code)
                    log.error("Error sending feedback email, \(String(describing: error)): \(String(describing: jsonDict["message"]))")
                    async {
                        completion(false, error ?? BalanceError.unknownError)
                    }
                    return
                }
                
                async {
                    completion(true, nil)
                }
            }
            task.resume()
        } catch {
            log.error("Error sending email: \(error)")
            async {
                completion(false, error)
            }
        }
    }
}
