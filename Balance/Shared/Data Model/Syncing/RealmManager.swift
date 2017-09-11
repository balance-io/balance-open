//
//  RealmManager.swift
//  Bal
//
//  Created by Benjamin Baron on 3/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import RealmSwift

fileprivate let authUrl = URL(string: debugging.useLocalRealmServer ? "http://localhost:9080" : "https://sync.balancemy.money")!
fileprivate let prefsUrl = URL(string: debugging.useLocalRealmServer ? "realm://localhost:9080/~/prefs" : "realms://sync.balancemy.money/~/prefs")!
fileprivate let modsUrl = URL(string: debugging.useLocalRealmServer ? "realm://localhost:9080/~/mods" : "realms://sync.balancemy.money/~/mods")!

class RealmManager {
    var hasCredentials: Bool {
        return subscriptionManager.realmUser != nil && subscriptionManager.realmPass != nil
    }
    
    var isLoggedIn: Bool {
        return SyncUser.current != nil
    }
    
    var prefsRealm: Realm? {
        return openRealm(url: prefsUrl)
    }
    
    var modsRealm: Realm? {
        return openRealm(url: modsUrl)
    }
    
    fileprivate func openRealm(url: URL) -> Realm? {
        if let user = SyncUser.current {
            let config = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: url))
            do {
                let realm = try Realm(configuration: config)
                return realm
            } catch {
                log.severe("Failed to open realm for url: \(url)  error: \(error)")
            }
        }
        
        return nil
    }
    
    func writePrefs(withoutNotifying tokens: [NotificationToken] = [], writeOperation: (Realm) -> Void) {
        if let realm = prefsRealm {
            write(realm: realm, withoutNotifying: tokens, writeOperation: writeOperation)
        }
    }
    
    func writeMods(withoutNotifying tokens: [NotificationToken] = [], writeOperation: (Realm) -> Void) {
        if let realm = modsRealm {
            write(realm: realm, withoutNotifying: tokens, writeOperation: writeOperation)
        }
    }
    
    fileprivate func write(realm: Realm, withoutNotifying tokens: [NotificationToken], writeOperation: (Realm) -> Void) {
        do {
            realm.beginWrite()
            writeOperation(realm)
            try realm.commitWrite(withoutNotifying: tokens)
        } catch {
            log.error("Failed to write to realm: \(String(describing: realm.configuration.syncConfiguration?.realmURL))  error: \(error)")
        }
    }
    
    // NOTE: User authentication is cached to the keychain. User's only need to technically be authenticated once, then after that
    // the stored user credentials can be used. If for some reason those are missing, then authentation must be performed again
    func authenticate(force: Bool = false, completion: @escaping (Bool, Error?) -> Void) {
        if !force && isLoggedIn {
            // If we already have a cached SyncUser, no need to authenticate
            log.debug("Already logged into Realm")
            completion(true, nil)
            return
        }
        
        guard let realmUser = subscriptionManager.realmUser, let realmPass = subscriptionManager.realmPass else {
            // Missing credentials
            log.error("Tried to authenticate to Realm, but missing credentials")
            completion(false, nil)
            return
        }
        
        // If we don't have a cached SyncUser, it's more likely that this is a new install than a second install, 
        // so attempt to register first.
        // NOTE: Even though there is an error value in the SDK for userAlreadyExists, it appears that at some point they realized
        // that was bad security and started using the invalidCredential with a message indicating it could possibly be invalid credentials.
        // Makes no real sense when registering (because how can the credentials be invalid?), but they do the same thing for userDoesNotExist
        // when doing a regular login. So we check for both, but expect to see invalidCredential to actually mean we're already registered.
        let credentials = SyncCredentials.usernamePassword(username: realmUser, password: realmPass, register: true)
        SyncUser.logIn(with: credentials, server: authUrl) { user, error in
            if let error = error as? SyncAuthError, error.code == SyncAuthError.invalidCredential || error.code == SyncAuthError.userAlreadyExists {
                // Do a regular login
                log.debug("Already registered with Realm, trying a regular sign in")
                let credentials = SyncCredentials.usernamePassword(username: realmUser, password: realmPass, register: false)
                SyncUser.logIn(with: credentials, server: authUrl) { user, error in
                    if let error = error {
                        log.severe("Error authenticating to Realm Object Server: \(error)")
                        completion(false, error)
                    } else {
                        // Successfully logged in as existing user
                        log.debug("Successfully signed into Realm")
                        completion(true, nil)
                    }
                }
            } else if let error = error {
                // Some error registering the user (server is probably down)
                log.severe("Error authenticating to Realm Object Server: \(error)")
                completion(false, error)
            } else {
                // Successfully registered and created a user
                log.debug("Successfully registered with Realm")
                completion(true, nil)
            }
        }
    }
}
