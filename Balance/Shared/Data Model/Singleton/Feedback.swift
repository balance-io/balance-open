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
    fileprivate static let emailIssueUrl  = subServerBaseUrl + "/emailConnectionIssue"
    fileprivate static let emailFeedbackUrl  = subServerBaseUrl + "/emailFeedback"
    
    fileprivate static let session = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)
    
    static func email(apiInstitution: ApiInstitution?, errorType: String? = nil, errorCode: String? = nil, email: String, comment: String, completion: @escaping SuccessErrorHandler) {
        do {
            var dict: [String: Any] = ["email": email,
                                       "balanceBuild": appVersionAndBuildString,
                                       "macOSBuild": osVersionString,
                                       "hardwareVersion": hardwareModelString,
                                       "comment": comment]
            dict["source"] = apiInstitution?.source.rawValue
            dict["sourceInstitutionId"] = apiInstitution?.sourceInstitutionId
            dict["institutionName"] = apiInstitution?.name
            dict["errorType"] = errorType
            dict["errorCode"] = errorCode
            if let logsZipUrl = logging.zipLogFiles(), let logsData = try? Data(contentsOf: logsZipUrl), logsData.count < 2 * 1024 * 1024 {
                dict["logs"] = logsData.base64EncodedString()
            }
            
            let isConnectionIssue = apiInstitution != nil
            let url = isConnectionIssue ? URL(string: emailIssueUrl)! : URL(string: emailFeedbackUrl)!
            var request = URLRequest(url: url)
            request.timeoutInterval = 60.0
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.httpMethod = HTTPMethod.POST
            request.httpBody = try JSONSerialization.data(withJSONObject: dict)
            
            let task = session.dataTask(with: request) { data, _, error in
                let success = data != nil && error == nil
                async { completion(success, error) }
            }
            task.resume()
        } catch {
            log.error("Error sending email: \(error)")
            async { completion(false, error) }
        }
    }
}
