//
//  Institution.swift
//  Bal
//
//  Created by Benjamin Baron on 2/25/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

final class Institution {
    
    let repository: InstitutionRepository
    let institutionId: Int
    let source: Source
    let sourceInstitutionId: String
    let name: String
    let nameBreak: Int?
    let logoData: Data?
    let dateAdded: Date
    let primaryColor: PXColor?
    let secondaryColor: PXColor?
    
    var passwordInvalid: Bool
    var onValidate: Bool = false
    
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
            return keychain[accessTokenKey, "accessToken"]
        }
        set {
            log.debug("set accessTokenKey: \(accessTokenKey)  newValue: \(String(describing: newValue))")
            keychain[accessTokenKey, "accessToken"] = newValue
        }
    }
    
    var displayName: String {
        return name
    }
    
    var displayColor: PXColor {
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
