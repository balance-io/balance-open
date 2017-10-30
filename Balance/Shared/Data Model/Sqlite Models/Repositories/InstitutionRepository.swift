//
//  InstitutionRepository.swift
//  Balance
//
//  Created by Benjamin Baron on 8/16/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct InstitutionRepository: ItemRepository {
    static let si = InstitutionRepository()
    fileprivate let gr = GenericItemRepository.si
    
    let table = "institutions"
    let itemIdField = "institutionId"
    
    func institution(institutionId: Int) -> Institution? {
        return gr.item(repository: self, itemId: institutionId)
    }
    
    // Since we allow duplicate institutions, never check if they exist first
    @discardableResult func institution(institutionId: Int? = nil, source: Source, sourceInstitutionId: String, name: String, nameBreak: Int? = nil, primaryColor: PXColor? = nil, secondaryColor: PXColor? = nil, logoData: Data? = nil, dateAdded: Date = Date(), accessToken: String? = nil) -> Institution? {
        if let institutionId = institutionId {
            let institution = Institution(institutionId: institutionId, source: source, sourceInstitutionId: sourceInstitutionId, name: name, nameBreak: nameBreak, primaryColor: primaryColor, secondaryColor: secondaryColor, logoData: logoData, dateAdded: dateAdded, repository: self)
            institution.replace()
            return institution
        } else {
            var generatedId: Int?
            database.write.inDatabase { db in
                do {
                    let query = "INSERT INTO institutions " +
                                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                    try db.executeUpdate(query, NSNull(), source.rawValue, sourceInstitutionId, name, n2N(nameBreak), n2N(primaryColor?.hexString), n2N(secondaryColor?.hexString), n2N(logoData), false, dateAdded)
                    
                    generatedId = Int(db.lastInsertRowId())
                } catch {
                    log.severe("DB Error: " + db.lastErrorMessage())
                }
            }
            
            if let institutionId = generatedId {
                let institution = Institution(institutionId: institutionId, source: source, sourceInstitutionId: sourceInstitutionId, name: name, nameBreak: nameBreak, primaryColor: primaryColor, secondaryColor: secondaryColor, logoData: logoData, dateAdded: dateAdded, repository: self)
                if let accessToken = accessToken {
                    institution.accessToken = accessToken
                }
                defaults.institutionColors[sourceInstitutionId] = nextAvailableDefaultInstitutionColorIndex()
                return institution
            } else {
                // TODO: Handle this error better, this means a serious DB problem
                // Something went really wrong and we didn't get an accountId id
                log.severe("Failed to create accountId for institution \(name)")
                return nil
            }
        }
    }
    
    func isPersisted(institution: Institution) -> Bool {
        return gr.isPersisted(repository: self, item: institution)
    }
    
    func isPersisted(institutionId: Int) -> Bool {
        return gr.isPersisted(repository: self, itemId: institutionId)
    }
    
    @discardableResult func replace(institution: Institution) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                let query = "INSERT OR REPLACE INTO institutions " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                
                // Hack for compile time speed
                let institutionId: Any = institution.institutionId
                let source: Any = institution.source.rawValue
                let sourceInstitutionId: Any = institution.sourceInstitutionId
                let name: Any = institution.name
                let nameBreak: Any = n2N(institution.nameBreak)
                let primaryColor: Any = n2N(institution.primaryColor?.hexString)
                let secondaryColor: Any = n2N(institution.secondaryColor?.hexString)
                let logoData: Any = n2N(institution.logoData)
                let passwordInvalid: Any = institution.passwordInvalid
                let dateAdded: Any = institution.dateAdded
                
                try db.executeUpdate(query, institutionId, source, sourceInstitutionId, name, nameBreak, primaryColor, secondaryColor, logoData, passwordInvalid, dateAdded)
            } catch {
                log.severe("Error replacing institution \(institution): " + db.lastErrorMessage())
                success = false
            }
        }
        return success
    }
    
    var hasInstitutions: Bool {
        return institutionsCount > 0
    }
    
    var institutionsCount: Int {
        var count = 0
        database.read.inDatabase { db in
            let statement = "SELECT count(*) FROM institutions"
            count = db.intForQuery(statement)
        }
        return count
    }
    
    func allInstitutions(sorted: Bool = false) -> [Institution] {
        var unsortedInstitutions = [Institution]()
        
        database.read.inDatabase { db in
            do {
                let statement = "SELECT * FROM institutions ORDER BY institutionId"
                let result = try db.executeQuery(statement)
                while result.next() {
                    unsortedInstitutions.append(Institution(result: result, repository: self))
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
    
    func allNewInstitutions(sorted: Bool = false) -> [Institution] {
        return allInstitutions(sorted: sorted).filter({$0.isNewInstitution})
    }
    
    @discardableResult func delete(institution: Institution, notify: Bool = true) -> Bool {
        var success = true
        database.write.inDatabase { db in
            do {
                // Begin transaction
                try db.executeUpdate("BEGIN")
                
                // Delete transaction records
                let statement1 = "DELETE FROM transactions WHERE accountId IN (SELECT accountId FROM accounts WHERE institutionId = ?)"
                try db.executeUpdate(statement1, institution.institutionId)
                
                // Delete account records
                let statement2 = "DELETE FROM accounts WHERE institutionId = ?"
                try db.executeUpdate(statement2, institution.institutionId)
                
                // Delete institution record
                let statement3 = "DELETE FROM institutions WHERE institutionId = ?"
                try db.executeUpdate(statement3, institution.institutionId)
                
                // End transaction
                try db.executeUpdate("COMMIT")
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
                success = false
            }
        }
        
        if success {
            // Delete the accessToken
            institution.accessToken = nil
            
            defaults.institutionColors[institution.sourceInstitutionId] = nil
            
            if notify {
                let userInfo = Notifications.userInfoForInstitution(institution)
                NotificationCenter.postOnMainThread(name: Notifications.InstitutionRemoved, object: nil, userInfo: userInfo)
            }
        }
        
        return success
    }
    
    @discardableResult func delete(institutionId: Int, notify: Bool = true) -> Bool {
        if let institution = institution(institutionId: institutionId) {
            return delete(institution: institution, notify: notify)
        }
        return false
    }
    
    func institutionsWithInvalidPasswords() -> [Institution] {
        if debugging.showAllInstitutionsAsIncorrectPassword {
            return allInstitutions()
        }
        
        let invalidPasswordInstitutions = allInstitutions().filter({$0.passwordInvalid})
        return invalidPasswordInstitutions
    }
}

extension Institution: PersistedItem {
    class func item(itemId: Int, repository: ItemRepository = InstitutionRepository.si) -> Item? {
        return (repository as? InstitutionRepository)?.institution(institutionId: itemId)
    }
    
    var isPersisted: Bool {
        return repository.isPersisted(institution: self)
    }
    
    @discardableResult func replace() -> Bool {
        return repository.replace(institution: self)
    }
    
    @discardableResult func delete() -> Bool {
        let transactions = TransactionRepository.si.transactions(institutionId: self.institutionId)
        for transaction in transactions
        {
            transaction.delete()
        }
        
        return repository.delete(institution: self, notify: true)
    }
}
