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
let logLevel = XCGLogger.Level.debug
#endif

class Logging {
    fileprivate static var defaultLogFileName: String {
        let logCount = defaults.logCount
        let fileName = "log\(logCount).txt"
        defaults.logCount = logCount + 1
        return fileName
    }
    fileprivate static var defaultPlaidRawLogFileName: String {
        let logCount = defaults.logCount
        let fileName = "plaidRawLog\(logCount).txt"
        defaults.logCount = logCount + 1
        return fileName
    }
    
    var logFileUrl: URL
    var logFilePath: String
    
    var plaidRawLogFileUrl: URL?
    var plaidRawLogFilePath: String?
    
    init(logFileName: String = Logging.defaultLogFileName) {
        let logFileUrl = appSupportPathUrl.appendingPathComponent(logFileName)
        self.logFileUrl = logFileUrl
        self.logFilePath = logFileUrl.path
    }
    
    func logContents() -> String {
        do {
            let logContents = try String(contentsOfFile: logFilePath, encoding: String.Encoding.utf8)
            if logContents.length > 0 {
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
}
