//
//  Feedback.swift
//  Bal
//
//  Created by Benjamin Baron on 7/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

let subServerBaseUrl = debugging.useLocalSubscriptionServer ? "http://localhost:8080" : "https://balance-server.appspot.com"

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
                let success = data != nil && error == nil
                async {
                    completion(success, error)
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
