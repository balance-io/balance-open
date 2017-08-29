//
//  InstitutionsDatabase.swift
//  Bal
//
//  Created by Benjamin Baron on 9/27/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation

class InstitutionsDatabase {
    fileprivate let bundlePath = Bundle.main.path(forResource: "institutions.db", ofType: "zip")!
    fileprivate let databasePath = appSupportPathUrl.appendingPathComponent("institutions.db").path
    fileprivate let updateUrl = URL(string: "https://balancemy.money/institutions/v2/institutionsUpdate.json")!
    fileprivate let session = URLSession(configuration: .default, delegate: certValidator, delegateQueue: nil)
    
    fileprivate var read: FMDatabasePool?
    
    fileprivate var databaseVersion: Int {
        var version = 0
        if let read = read {
            read.inDatabase { db in
                version = db.intForQuery("PRAGMA user_version")
            }
        }
        
        return version
    }
    
    fileprivate let lockObject = NSObject()
    
    // Keyed on institution.key
    fileprivate var institutionCache = [String: Institution]()
    
    init() {
        reloadDatabase()
    }
    
    fileprivate func reloadDatabase() {
        if debugging.disableSubscription {
            return
        }
        
        objc_sync_enter(lockObject)
        if let read = read, read.countOfCheckedOutDatabases() > 0 {
            // Try again
            async(after: 0.25) {
                self.reloadDatabase()
            }
        } else {
            if !FileManager.default.fileExists(atPath: databasePath) {
                do {
                    let zipUrl = URL(fileURLWithPath: bundlePath)
                    try unzipDatabase(zipUrl: zipUrl, checkHash: false)
                } catch {
                    log.severe("Unable to copy institution database from bundle")
                }
            }
            
            if FileManager.default.fileExists(atPath: databasePath) {
                read = FMDatabasePool(path: databasePath)
                read?.maximumNumberOfDatabasesToCreate = 20
            }
            
            // Cache institutions for fast searching
            institutionCache = allInstitutions()
        }
        objc_sync_exit(lockObject)
    }
    
    func primarySourceInstitutionId(source: Source, sourceInstitutionId: String) -> String? {
        if debugging.disableSubscription {
            return nil
        }
        
        objc_sync_enter(lockObject)
        var primaryInstitutionId: String?
        read?.inDatabase { db in
            do {
                let statement = "SELECT isPrimary, primaryType FROM modifications WHERE source = ? AND sourceInstitutionId = ?"
                let result = try db.executeQuery(statement, source.rawValue, sourceInstitutionId)
                if result.next() {
                    let isPrimary = result.bool(forColumnIndex: 0)
                    let primaryType = result.string(forColumnIndex: 1)
                    primaryInstitutionId = isPrimary ? sourceInstitutionId : primaryType
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        objc_sync_exit(lockObject)
        
        return primaryInstitutionId
    }
    
    func color(source: Source, sourceInstitutionId: String) -> PXColor? {
        if debugging.disableSubscription {
            return nil
        }
        
        objc_sync_enter(lockObject)
        var color: PXColor?
        read?.inDatabase { db in
            let statement = "SELECT color FROM modifications WHERE source = ? AND sourceInstitutionId = ?"
            let colorHex = db.stringForQuery(statement, source.rawValue, sourceInstitutionId)
            if let colorHex = colorHex {
                color = PXColor(hexString: colorHex)
            }
        }
        objc_sync_exit(lockObject)
        
        return color
    }
    
    func isHidden(source: Source, sourceInstitutionId: String) -> Bool {
        if debugging.disableSubscription {
            return false
        }
        
        objc_sync_enter(lockObject)
        var hidden = false
        read?.inDatabase { db in
            let statement = "SELECT hide FROM modifications WHERE source = ? AND sourceInstitutionId = ?"
            hidden = db.boolForQuery(statement, source.rawValue, sourceInstitutionId)
        }
        objc_sync_exit(lockObject)
        return hidden
    }
    
    func checkForUpdate(completion: (() -> Void)? = nil) {
        if debugging.disableSubscription {
            async { completion?() }
            return
        }
        
        var request = URLRequest(url: updateUrl)
        request.timeoutInterval = 240.0
        request.httpMethod = HTTPMethod.GET
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request) { data, _, error in
            do {
                // Make sure there's data
                guard let data = data, error == nil else {
                    log.debug("Failed to check for updated institutions database. Error: \(String(describing: error))")
                    async { completion?() }
                    return
                }
 
                // Try to parse the JSON
                guard var JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    log.debug("Failed to check for updated institutions database. Failed to parse the JSON.")
                    async { completion?() }
                    return
                }
                
                // Process the response
                let userVersion = JSONResult["userVersion"] as? Int
                let urlString = JSONResult["url"] as? String
                let sha1 = JSONResult["sha1"] as? String
                
                if let userVersion = userVersion, let urlString = urlString {
                    if userVersion > self.databaseVersion, let url = URL(string: urlString), let sha1 = sha1 {
                        async {
                            self.downloadDatabase(url: url, sha1: sha1, completion: completion)
                        }
                    } else {
                        async { completion?() }
                    }
                } else {
                    // Some kind of connection error
                    log.debug("Failed to check for updated institutions database. The JSON parsed, but data was missing.")
                    async { completion?() }
                }
            } catch {
                // Some kind of connection error
                log.debug("Failed to check for updated institutions database. Error: \(error)")
                async { completion?() }
            }
        }
        
        task.resume()
    }
    
    func downloadDatabase(url: URL, sha1: String, completion: (() -> Void)? = nil) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 240.0
        request.httpMethod = HTTPMethod.GET
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request) { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    log.debug("Failed to download updated institutions database. Error: \(String(describing: maybeError))")
                    completion?()
                    return
                }
                
                // Save the zip data and unzip it
                let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
                let zipUrl = tempUrl.appendingPathComponent("institutions.db.zip")
                try data.write(to: zipUrl)
                try self.unzipDatabase(zipUrl: zipUrl, checkHash: true, sha1: sha1)
                try FileManager.default.removeItem(at: zipUrl)
                
                self.reloadDatabase()
                completion?()
            } catch {
                // Some kind of connection error
                objc_sync_exit(self.lockObject)
                log.debug("Failed to download updated institutions database. Error: \(error)")
                completion?()
            }
        }
        
        task.resume()
    }
    
    func unzipDatabase(zipUrl: URL, checkHash: Bool, sha1: String? = nil) throws {
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        let dbUrl = tempUrl.appendingPathComponent("institutions.db")
        
        try Zip.unzipFile(zipUrl, destination: tempUrl, overwrite: true, password: nil, progress: nil)
        
        // Check the hash and save the data atomically
        let dbData = try Data(contentsOf: dbUrl)
        if !checkHash || sha1 == dbData.sha1.lowercased() {
            let pathUrl = URL(fileURLWithPath: databasePath)
            objc_sync_enter(self.lockObject)
            try dbData.write(to: pathUrl, options: [.atomic])
            objc_sync_exit(self.lockObject)
        }
        
        // Delete the temp file
        try FileManager.default.removeItem(at: dbUrl)
    }
    
    func allInstitutions() -> [String: Institution] {
        var institutions = [String: Institution]()
        
        objc_sync_enter(lockObject)
        read?.inDatabase { db in
            do {
                let statement = "SELECT institutions.*, modifications.displayName, modifications.isPrimary, modifications.color, modifications.rank " +
                                "FROM institutions LEFT JOIN modifications " +
                                "ON institutions.source = modifications.source, institutions.institutionId = modifications.institutionId"
                let result = try db.executeQuery(statement)
                while result.next() {
                    if let institution = self.institution(fromResult: result) {
                        institutions[institution.key] = institution
                    }
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        objc_sync_exit(lockObject)
        
        return institutions
    }
    
    func search(name: String) -> [Institution] {
        var institutions = [Institution]()
        
        objc_sync_enter(lockObject)
        var institutionKeys = [String]()
        read?.inDatabase { db in
            do {
                let statement = "SELECT institutions.* " +
                                "FROM institutions LEFT JOIN modifications " +
                                "ON institutions.source = modifications.source, institutions.institutionId = modifications.institutionId " +
                                "WHERE modifications.hide IS NOT 1 AND COALESCE(modifications.displayName, institutions.name) LIKE ? COLLATE NOCASE " +
                                "ORDER BY COALESCE(rank, 100000), (CASE WHEN COALESCE(modifications.displayName, institutions.name) = ? THEN 1 WHEN COALESCE(modifications.displayName, institutions.name) LIKE ? THEN 2 ELSE 3 END), COALESCE(modifications.displayName, institutions.name)"
                let result = try db.executeQuery(statement, "%\(name)%", name, "\(name)%")
                while result.next() {
                    let sourceId = result.long(forColumnIndex: 0)
                    if let sourceInstitutionId = result.string(forColumnIndex: 1) {
                        let key = Institution.key(sourceId: sourceId, sourceInstitutionId: sourceInstitutionId)
                        institutionKeys.append(key)
                    }
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        
        for key in institutionKeys {
            if let institution = institutionCache[key] {
                institutions.append(institution)
            }
        }
        
        objc_sync_exit(lockObject)
        
        return institutions
    }
    
    func search(source: Source, sourceInstitutionId: String) -> Institution? {
        var institution: Institution?
        
        objc_sync_enter(lockObject)
        read?.inDatabase { db in
            do {
                let statement = "SELECT institutions.*, modifications.displayName, modifications.isPrimary, modifications.color, modifications.rank " +
                                "FROM institutions LEFT JOIN modifications " +
                                "ON institutions.source = modifications.source, institutions.institutionId = modifications.institutionId " +
                                "WHERE institutions.source = ? AND institutions.sourceInstitutionId = ?"
                let result = try db.executeQuery(statement, source.rawValue, sourceInstitutionId)
                if result.next() {
                    institution = self.institution(fromResult: result)
                }
                result.close()
            } catch {
                log.severe("DB Error: " + db.lastErrorMessage())
            }
        }
        objc_sync_exit(lockObject)
        
        return institution
    }
    
    fileprivate func institution(fromResult result: FMResultSet) -> Institution? {
        let source = Source(rawValue: result.long(forColumnIndex: 0))
        let institutionId = result.string(forColumnIndex: 1)
        let name = result.string(forColumnIndex: 2)
        let displayName = result.string(forColumnIndex: 2)
        let isPrimary = result.bool(forColumnIndex: 3)
        let rank = result.object(forColumnIndex: 4) as? Int
        let colorHex = result.string(forColumnIndex: 5)
        
        if let source = source, let institutionId = institutionId, let nameToUse = displayName ?? name {
            let institution = Institution(institutionId: -1, source: source, sourceInstitutionId: institutionId, name: nameToUse)
            institution.isPrimary = isPrimary
            institution.rank = rank
            institution.color = colorHex == nil ? nil : PXColor(hexString: colorHex!)
            return institution
        }
        
        return nil
    }
}

extension Institution {
    // Set of types that are primary
    fileprivate static var isPrimaryStorage = Set<String>()
    
    // Rank cache
    fileprivate static var rankStorage = [String: Int]()
    
    // Color cache
    fileprivate static var colorStorage = [String: PXColor]()
    
    static func key(sourceId: Int, sourceInstitutionId: String) -> String {
        return "\(sourceId):|:|:\(sourceInstitutionId)"
    }
    
    var key: String {
        return Institution.key(sourceId: source.rawValue, sourceInstitutionId: sourceInstitutionId)
    }
    
    var isPrimary: Bool {
        get {
            return Institution.isPrimaryStorage.contains(key)
        } set {
            if newValue {
                Institution.isPrimaryStorage.insert(key)
            } else {
                Institution.isPrimaryStorage.remove(key)
            }
        }
    }
    
    var rank: Int? {
        get {
            return Institution.rankStorage[key]
        } set {
            Institution.rankStorage[key] = newValue
        }
    }
    
    var color: PXColor? {
        get {
            return Institution.colorStorage[key]
        } set {
            Institution.colorStorage[key] = newValue
        }
    }
}
