//
//  Institution.swift
//  Bal
//
//  Created by Benjamin Baron on 2/25/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import Locksmith

final class Institution {
    let repository: InstitutionRepository
    
    let institutionId: Int
    let source: Source
    let sourceInstitutionId: String
    
    let name: String
    let nameBreak: Int?
    
    let primaryColor: PXColor?
    let secondaryColor: PXColor?
    
    let logoData: Data?
    
    var passwordInvalid: Bool
    
    let dateAdded: Date
    
    required init(result: FMResultSet, repository: ItemRepository = InstitutionRepository.si) {
        self.repository = repository as! InstitutionRepository
        
        self.institutionId = result.long(forColumnIndex: 0)
        self.source = Source(rawValue: result.long(forColumnIndex: 1))!
        self.sourceInstitutionId = result.string(forColumnIndex: 2)
        
        self.name = result.string(forColumnIndex: 3)
        self.nameBreak = result.object(forColumnIndex: 4) as? Int
        
        if let primaryColorString = result.object(forColumnIndex: 5) as? String {
            self.primaryColor = PXColor(hexString: primaryColorString)
        } else {
            self.primaryColor = nil
        }
        
        if let secondaryColorString = result.object(forColumnIndex: 6) as? String {
            self.secondaryColor = PXColor(hexString: secondaryColorString)
        } else {
            self.secondaryColor = nil
        }
        
        self.logoData = result.object(forColumnIndex: 7) as? Data
        
        self.passwordInvalid = result.bool(forColumnIndex: 8)
        
        self.dateAdded = result.date(forColumnIndex: 9)
    }
    
    // Since we allow duplicate institutions, never check if they exist first
    init(institutionId: Int, source: Source, sourceInstitutionId: String, name: String, nameBreak: Int? = nil, primaryColor: PXColor? = nil, secondaryColor: PXColor? = nil, logoData: Data? = nil, dateAdded: Date = Date(), repository: InstitutionRepository = InstitutionRepository.si) {
        self.repository = repository
        
        self.institutionId = institutionId
        self.source = source
        self.sourceInstitutionId = sourceInstitutionId
        
        self.name = name
        self.nameBreak = nameBreak
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        
        self.logoData = logoData
        
        self.passwordInvalid = false
        
        self.dateAdded = dateAdded
    }
}

extension Institution: Item, Equatable {
    var itemId: Int { return institutionId }
    var itemName: String { return name }
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

extension Institution {
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
    
    fileprivate static let initialsExcludedWords = Set(["OF", "THE", "AND", "AN"])
    var initials: String {
        let words = name.uppercased().components(separatedBy: " ").filter{!Institution.initialsExcludedWords.contains($0)}
        
        var initials = ""
        for word in words {
            initials += String(word.characters.first!)
            if initials.length == 2 {
                break
            }
        }
        
        return initials
    }
    
    var displayName: String {
        return source == .plaid ? name.capitalizedStringIfAllCaps : name
    }
    
    var displayColor: PXColor {
        if let color = institutionsDatabase.color(source: source, sourceInstitutionId: sourceInstitutionId) {
            return color
        }
        if let primaryColor = primaryColor {
            return primaryColor
        }
        if let colorIndex = defaults.institutionColors[sourceInstitutionId] {
            return defaultInstitutionColorForIndex(colorIndex)
        }
        return .gray
    }
    
    #if os(OSX)
    var logoImage: NSImage? {
        if let logoData = self.logoData, let image = NSImage(data: logoData) {
            return image
        }
        return nil
    }
    #endif
}
