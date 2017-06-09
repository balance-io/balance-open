//
//  ServerMessage.swift
//  Bal
//
//  Created by Benjamin Baron on 12/12/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

private let messageUrl = URL(string: "https://balancemy.money/institutions/message.json")!

class ServerMessage {
    func checkForMessage() {
        var request = URLRequest(url: messageUrl)
        request.timeoutInterval = 240.0
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = URLSession.shared.dataTask(with: request) { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil, let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    return
                }
                
                // Process the response
                let id = JSONResult["id"] as? Int
                let expiration = JSONResult["expiration"] as? Int
                let title = JSONResult["title"] as? String
                let message = JSONResult["message"] as? String
                let okButtonTitle = JSONResult["okButtonTitle"] as? String ?? "OK"
                
                var readMessageIds = defaults.serverMessageReadIds
                if let id = id, let expiration = expiration, let title = title, let message = message {
                    if !readMessageIds.contains(id) {
                        readMessageIds.append(id)
                        defaults.serverMessageReadIds = readMessageIds
                        
                        // Check if it's expired
                        let expirationDate = Date(timeIntervalSince1970: Double(expiration))
                        if Date().timeIntervalSince(expirationDate) < 0 {
                            let userInfo = Notifications.userInfoForServerMessage(title: title, content: message, okButton: okButtonTitle)
                            NotificationCenter.postOnMainThread(name: Notifications.DisplayServerMessage, object: nil,  userInfo: userInfo)
                        }
                    }
                 }
            } catch {
                // Some kind of connection error
            }
        }
        
        task.resume()
    }
}
