//
//  main.swift
//  Bal
//
//  Created by Benjamin Baron on 5/25/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import UIKit

//let appDelegateClass: AnyClass = NSClassFromString("AppNameTests.TestingAppDelegate") ?? AppDelegate.self
let appDelegateClass: AnyClass = AppDelegate.self
UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    nil,
    NSStringFromClass(appDelegateClass)
)
