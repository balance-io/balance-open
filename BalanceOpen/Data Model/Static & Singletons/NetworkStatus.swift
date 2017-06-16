//
//  NetworkStatus.swift
//  Bal
//
//  Created by Benjamin Baron on 11/18/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Reachability

class NetworkStatus {
    // Hostname reachability does not work correctly right now, it always shows unreachable
    //let reachability = Reachability(hostname: "https://api.plaid.com")
    
    let reachability = Reachability()
    
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
    }
    
    fileprivate func becameReachable(reachability: Reachability) {
        NotificationCenter.postOnMainThread(name: Notifications.NetworkBecameReachable)
    }
    
    fileprivate func becameUnreachable(reachability: Reachability) {
        NotificationCenter.postOnMainThread(name: Notifications.NetworkBecameUnreachable)
    }
}
