//
//  NetworkStatus.swift
//  Bal
//
//  Created by Benjamin Baron on 11/18/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class NetworkStatus {
    let reachability = Reachability()
    
    var checkHostTask: URLSessionDataTask?
    var checkHostTimer: Timer?
    
    var isReachable: Bool {
        if let reachability = reachability {
            return reachability.isReachable
        }
        return true
    }
    
    func startMonitoring() {
        reachability?.whenReachable = becameReachable
        reachability?.whenUnreachable = becameUnreachable
        do {
            try reachability?.startNotifier()
        } catch {
            log.error("Unable to start Reachability notifier")
        }
    }
    
    func stopMonitoring() {
        reachability?.stopNotifier()
        cancelCheckHost()
    }
    
    fileprivate func becameReachable(reachability: Reachability) {
        // Check if we can actually access the internet yet.
        // If not, retry until it either succeeds or we become unreachable
        checkHost()
    }
    
    fileprivate func becameUnreachable(reachability: Reachability) {
        cancelCheckHost()
        NotificationCenter.postOnMainThread(name: Notifications.NetworkBecameUnreachable)
    }
    
    @objc fileprivate func checkHost() {
        cancelCheckHost()
        
        async {
            let url = URL(string: "https://balance-server.appspot.com/hello")!
            let expectedResponse = "hello"
            self.checkHostTask = certValidatedSession.dataTask(with: url) { data, response, error in
                // Check if we can connect at all
                guard self.isReachable, error == nil, let data = data else {
                    self.scheduleCheckHost()
                    return
                }
                
                // Check if we get the correct response
                guard let response = String(data: data, encoding: .utf8), response == expectedResponse else {
                    self.scheduleCheckHost()
                    return
                }
                
                NotificationCenter.postOnMainThread(name: Notifications.NetworkBecameReachable)
            }
            self.checkHostTask?.resume()
        }
    }
    
    fileprivate func scheduleCheckHost() {
        cancelCheckHost()
        
        async {
            self.checkHostTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkHost), userInfo: nil, repeats: false)
        }
    }
    
    fileprivate func cancelCheckHost() {
        async {
            self.checkHostTask?.cancel()
            self.checkHostTask = nil
            
            self.checkHostTimer?.invalidate()
            self.checkHostTimer = nil
        }
    }
}
