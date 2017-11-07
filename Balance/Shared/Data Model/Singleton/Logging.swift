//
//  Logging.swift
//  Bal
//
//  Created by Benjamin Baron on 4/20/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCGLogger

#if DEBUG
let logLevel = XCGLogger.Level.debug
#else
let logLevel = XCGLogger.Level.info
#endif

class Logging {
    fileprivate static var defaultLogFileName: String {
        let logCount = defaults.logCount
        let fileName = "log\(logCount).txt"
        defaults.logCount = logCount + 1
        return fileName
    }
    
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
        log.setup(level: logLevel,
                  showThreadName: true,
                  showLevel: true,
                  showFileNames: true,
                  showLineNumbers: true,
                  writeToFile: logFilePath,
                  fileLevel: logLevel)
        
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
            let files = try FileManager.default.contentsOfDirectory(at: appSupportPathUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let logFiles = files.filter({$0.pathExtension == "txt"})
            try Zip.zipFiles(paths: logFiles, zipFilePath: finalZipPath, password: nil, progress: nil)
        } catch {
            log.error("Unable to read log files: \(error)")
            return nil
        }
        
        return finalZipPath
    }
}
