//
//  Logging.swift
//  Bal
//
//  Created by Benjamin Baron on 4/20/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCGLogger

class Logging {
    fileprivate static var defaultLogFileName: String {
        let logCount = defaults.logCount
        let fileName = "log\(logCount).txt"
        defaults.logCount = logCount + 1
        return fileName
    }
    
    // 3.5MB should be approx 500KB when zipped, which is reasonable for uploading,
    // so set the max to 3MB to allow for the current log file to grow
    static let maxLogsSize = 3 * 1024 * 1024
    
    var logFileUrl: URL
    var logFilePath: String
    
    init(logFileName: String = Logging.defaultLogFileName) {
        let logFileUrl = appSupportPathUrl.appendingPathComponent(logFileName)
        self.logFileUrl = logFileUrl
        self.logFilePath = logFileUrl.path
    }
    
    func logContents() -> String {
        do {
            let logContents = try String(contentsOfFile: logFilePath, encoding: String.Encoding.utf8)
            if logContents.count > 0 {
                return logContents
            } else {
                return "Log file is empty"
            }
        } catch {
            return "Error reading log file: \(error)"
        }
    }
    
    func setupLogging() {
        // Setup the log parameters
        log.setup(level: debugging.logLevel,
                  showThreadName: true,
                  showLevel: true,
                  showFileNames: true,
                  showLineNumbers: true,
                  writeToFile: logFilePath,
                  fileLevel: debugging.logLevel)
        
        // Use GMT time zone for logging
        log.dateFormatter = {
            let customDateFormatter = DateFormatter()
            customDateFormatter.locale = Locale(identifier: "en_US")
            customDateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            customDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return customDateFormatter
        }()
        
        // Add basic app info, version info etc, to the start of the logs
        log.logAppDetails()
        
        // Purge old log files
        purgeLogFiles()
    }
    
    func zipLogFiles(zipPath: URL? = nil) -> URL? {
        let finalZipPath = zipPath ?? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("balanceLogs.zip")
        
        if FileManager.default.fileExists(atURL: finalZipPath) {
            do {
                try FileManager.default.removeItem(at: finalZipPath)
            } catch {
                log.error("Unable to remove zipped logs file at path: \(finalZipPath) error: \(error)")
                return nil
            }
        }
        
        do {
            let paths = try allLogFiles()
            try Zip.zipFiles(paths: paths, zipFilePath: finalZipPath, password: nil, progress: nil)
        } catch {
            log.error("Unable to read log files: \(error)")
            return nil
        }
        
        return finalZipPath
    }
    
    // MARK: - Log Purging -
    
    func allLogFiles() throws -> [URL] {
        // All files in app documents directory
        var files = try FileManager.default.contentsOfDirectory(at: appSupportPathUrl, includingPropertiesForKeys: [.fileSizeKey], options: .skipsHiddenFiles)
        
        // Filter only the logs
        files = files.filter({$0.pathExtension == "txt"})
        
        // Get the files sorted in reverse alphabetical order (so newest logs first)
        files = files.sorted {
            // Ensure that the order is log1, log2, etc and not log1, log10, etc
            $0.lastPathComponent.compare($1.lastPathComponent, options: [.numeric]) == .orderedDescending
        }
        
        return files
    }
    
    func logFilesToPurge() throws -> [URL] {
        // Get the files sorted in reverse alphabetical order (so newest logs first)
        let files = try allLogFiles()
        
        // Calculate total file size and mark files for removal after exceeding the max,
        // but always keep the last 3 log files (current session plus last 2) regardless of size
        var totalLogsSize = 0
        var logsProcessed = 0
        var logsToRemove = [URL]()
        for file in files {
            let resourceValues = try file.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                logsProcessed += 1
                totalLogsSize += fileSize
                
                if totalLogsSize > Logging.maxLogsSize && logsProcessed > 3 {
                    logsToRemove.append(file)
                }
            }
        }
        
        return logsToRemove
    }
    
    func purgeLogFiles() {
        do {
            let files = try logFilesToPurge()
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
            log.debug("Purged \(files.count) log files")
        } catch {
            log.error("Failed to purge log files: \(error)")
        }
    }
}
