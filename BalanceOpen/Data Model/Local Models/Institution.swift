//
//  Institution.swift
//  Bal
//
//  Created by Benjamin Baron on 2/25/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith

func ==(lhs: Institution, rhs: Institution) -> Bool {
    return lhs.institutionId == rhs.institutionId
}

private func arrayFromResult(_ result: FMResultSet) -> [AnyObject] {
    var array = [Any]()
    
    array.append(result.long(forColumnIndex: 0))                  // institutionId
    array.append(result.long(forColumnIndex: 1))                  // sourceId
    array.append(result.string(forColumnIndex: 2))                // sourceInstitutionId
    
    array.append(result.string(forColumnIndex: 3))                // name
    array.append(n2N(result.object(forColumnIndex: 4) as? Int))   // nameBreak
    
    array.append(n2N(result.string(forColumnIndex: 5)))           // primaryColor
    array.append(n2N(result.string(forColumnIndex: 6)))           // secondaryColor
    
    array.append(n2N(result.data(forColumnIndex: 7)))             // logoData
    
    array.append(result.bool(forColumnIndex: 8))                  // passwordInvalid
    
    array.append(result.date(forColumnIndex: 9))                  // dateAdded
    
    return array as [AnyObject]
}

class Institution {
    
    var institutionId: Int
    var sourceId: Source
    var sourceInstitutionId: String
    
    var name: String
    var nameBreak: Int?
    
    var primaryColor: NSColor?
    var secondaryColor: NSColor?
    var displayColor: NSColor {
//        if let color = institutionsDatabase.colorForSourceInstitutionId(sourceInstitutionId) {
//            return color
//        }
//        if let primaryColor = primaryColor {
//            return primaryColor
//        }
//        if let colorIndex = defaults.institutionColors[sourceInstitutionId] {
//            return defaultInstitutionColorForIndex(colorIndex)
//        }
        return .gray
    }
    
    var logoData: Data?
    var logoImage: NSImage? {
        if let logoData = self.logoData, let image = NSImage(data: logoData) {
            return image
        }
        return nil
    }
    
    var passwordInvalid: Bool
    
    var dateAdded: Date
    
    var isNewInstitution: Bool {
        return Date().timeIntervalSince(dateAdded) <= Date.dayInterval
    }
    
    fileprivate var accessTokenKey: String {
        return "institutionId: \(institutionId)"
    }
        
    var accessToken: String? {
        get {
            var accessToken: String? = nil
            if let dictionary = Locksmith.loadDataForUserAccount(userAccount: accessTokenKey) {
                accessToken = dictionary["accessToken"] as? String
            }
            
            print("get accessTokenKey: \(accessTokenKey)  accessToken: \(String(describing: accessToken))")
            if accessToken == nil {
                // We should always be getting an access token becasuse we never read it until after it's been written
                log.severe("Tried to read access token for institution [\(self)] but it didn't work! We must not have keychain access")
            }
            
            return accessToken
        }
        set {
            print("set accessTokenKey: \(accessTokenKey)  newValue: \(String(describing: newValue))")
            if let accessToken = newValue {
                do {
                    try Locksmith.updateData(data: ["accessToken": accessToken], forUserAccount: accessTokenKey)
                } catch {
                    log.severe("Couldn't update accessToken keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it saved correctly
                if accessToken != self.accessToken {
                    log.severe("Saved access token for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            } else {
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: accessTokenKey)
                } catch {
                    log.severe("Couldn't delete accessToken keychain data for institution [\(self)]: \(error)")
                }
                
                // Double check that it deleted correctly
                let dictionary = Locksmith.loadDataForUserAccount(userAccount: accessTokenKey)
                if dictionary != nil {
                    log.severe("Deleted access token for institution [\(self)] but it didn't work! We must not have keychain access")
                }
            }
        }
    }
    
    fileprivate let initialsExcludedWords = Set(["OF", "THE", "AND", "AN"])
    var initials: String {
        let words = name.uppercased().components(separatedBy: " ").filter{!initialsExcludedWords.contains($0)}
        
        var initials = ""
        for word in words {
            initials += String(word.characters.first!)
            if initials.length == 2 {
                break
            }
        }
        
        return initials
    }
    
    convenience init?(institutionId: Int) {
        var resultArray: [AnyObject]?
        database.readDbPool.inDatabase { db in
            do {
                let statement = "SELECT * FROM institutions WHERE institutionId = ?"
                let result = try db.executeQuery(statement, institutionId)
                if result.next() {
                    resultArray = arrayFromResult(result)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        if let resultArray = resultArray {
            self.init(resultArray)
        } else {
            return nil
        }
    }
    
    init(_ resultArray: [AnyObject]) {
        self.institutionId = resultArray[0] as! Int
        self.sourceId = Source(rawValue: resultArray[1] as! Int)!
        self.sourceInstitutionId = resultArray[2] as! String
        
        self.name = resultArray[3] as! String
        self.nameBreak = resultArray[4] as? Int
        
        if let primaryColorString = resultArray[5] as? String {
            self.primaryColor = NSColor(hexString: primaryColorString)
        }
        if let secondaryColorString = resultArray[6] as? String {
            self.secondaryColor = NSColor(hexString: secondaryColorString)
        }
        
        self.logoData = resultArray[7] as? Data
        
        self.passwordInvalid = resultArray[8] as! Bool
        
        self.dateAdded = resultArray[9] as! Date
    }
    
    // Since we allow duplicate institutions, never check if they exist first
    init?(sourceId: Source, sourceInstitutionId: String, name: String, nameBreak: Int?, primaryColor: NSColor?, secondaryColor: NSColor?, logoData: Data?, accessToken: String, dateAdded: Date = Date()) {
        
        self.sourceId = sourceId
        self.sourceInstitutionId = sourceInstitutionId
        
        self.name = name
        self.nameBreak = nameBreak
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        
        self.logoData = logoData
        
        self.passwordInvalid = false
        
        self.dateAdded = dateAdded

        var generatedId: Int?
        database.writeDbQueue.inDatabase { db in
            do {
                let insert = "INSERT INTO institutions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                try db.executeUpdate(insert, NSNull(), sourceId.rawValue, sourceInstitutionId, name, n2N(nameBreak), n2N(primaryColor?.hexString), n2N(secondaryColor?.hexString), n2N(logoData), false, dateAdded)
                
                generatedId = Int(db.lastInsertRowId())
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        if let institutionId = generatedId {
            self.institutionId = institutionId
            self.accessToken = accessToken            
        } else {
            // TODO: Handle this error better, this means a serious DB problem
            // Something went really wrong and we didn't get an accountId id
            log.severe("Failed to create accountId for institution \(name)")
            return nil
        }
    }
    
    // Update an existing model
    func updateModel() {
        database.writeDbQueue.inDatabase { db in
            do {
                let insert = "INSERT OR REPLACE INTO institutions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                try db.executeUpdate(insert, self.institutionId, self.sourceId.rawValue, self.sourceInstitutionId, self.name, n2N(self.nameBreak), n2N(self.primaryColor?.hexString), n2N(self.secondaryColor?.hexString), n2N(self.logoData), self.passwordInvalid, self.dateAdded)
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
    }
    
    static var hasInstitutions: Bool {
        return institutionsCount > 0
    }
    
    static var institutionsCount: Int {
        var count = 0
        database.readDbPool.inDatabase { db in
            let statement = "SELECT count(*) FROM institutions"
            count = db.longForQuery(statement)
        }
        return count
    }
    
    static func allInstitutions(sorted: Bool = false) -> [Institution] {
        var unsortedInstitutions = [Institution]()
        
        database.readDbPool.inDatabase { db in
            do {
                let statement = "SELECT * FROM institutions ORDER BY institutionId"
                let result = try db.executeQuery(statement)
                while result.next() {
                    let resultArray = arrayFromResult(result)
                    unsortedInstitutions.append(Institution(resultArray))
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        var institutions = [Institution]()
        if sorted {
            if let institutionsOrder = defaults.accountsViewInstitutionsOrder {
                for institutionId in institutionsOrder {
                    if let index = unsortedInstitutions.index(where: {$0.institutionId == institutionId}) {
                        let institution = unsortedInstitutions[index]
                        institutions.append(institution)
                        unsortedInstitutions.remove(at: index)
                    }
                }
                institutions.append(contentsOf: unsortedInstitutions)
            } else {
                institutions = unsortedInstitutions
            }
        } else {
            institutions = unsortedInstitutions
        }
        
        return institutions
    }
    
    static func allNewInstitutions(sorted: Bool = false) -> [Institution] {
        return allInstitutions(sorted: sorted).filter({$0.isNewInstitution})
    }
    
    func remove(notify: Bool = true) {
        // Delete the accessToken
        accessToken = nil
        refreshToken = nil
        
        database.writeDbQueue.inDatabase { db in
            do {
                // Begin transaction
                try db.executeUpdate("BEGIN")
                
                // Delete account records
                let statement2 = "DELETE FROM accounts WHERE institutionId = ?"
                try db.executeUpdate(statement2, self.institutionId)
                
                // Delete institution record
                let statement3 = "DELETE FROM institutions WHERE institutionId = ?"
                try db.executeUpdate(statement3, self.institutionId)
                
                // End transaction
                try db.executeUpdate("COMMIT")
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
                
        if notify {
            let userInfo = Notifications.userInfoForInstitution(self)
            NotificationCenter.postOnMainThread(name: Notifications.InstitutionRemoved, object: nil, userInfo: userInfo)
        }
    }
    
    static func removeInstitution(institutionId: Int) {
        if let institution = Institution(institutionId: institutionId) {
           institution.remove()
        }
    }
    
    static func institutionsWithInvalidPasswords() -> [Institution] {
        let invalidPasswordInstitutions = Institution.allInstitutions().filter({$0.passwordInvalid})
        return invalidPasswordInstitutions
    }
}

extension Institution: Hashable {
    var hashValue: Int {
        return institutionId.hashValue
    }
}

extension Institution: CustomStringConvertible {
    var description: String {
        return "\(institutionId) (\(sourceInstitutionId)): \(name)"
    }
}
