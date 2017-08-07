//
//  main.swift
//  Bal
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import AppKit

let isRunningTests =  ProcessInfo.processInfo
    .environment["XCTestConfigurationFilePath"] != nil
let appDelegate = isRunningTests ? TestingAppDelegate() : AppDelegate()
NSApplication.shared.delegate = appDelegate as? NSApplicationDelegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

