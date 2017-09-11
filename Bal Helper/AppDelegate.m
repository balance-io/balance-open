//
//  AppDelegate.m
//  Bal
//
//  Created by Benjamin Baron on 12/15/16.
//  Copyright © 2016 Balanced Software, Inc. All rights reserved.
//

#import "AppDelegate.h"

#define mainAppId @"software.balanced.balancemac"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Check if main app is already running
    BOOL alreadyRunning = NO;
    NSArray *runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in runningApplications) {
        if ([app.bundleIdentifier isEqualToString:mainAppId]) {
            alreadyRunning = YES;
            break;
        }
    }
    
    NSLog(@"Balance helper alreadyRunning: %i", alreadyRunning);
    if (!alreadyRunning) {
        // Calculate the path to Balance
        NSArray *pathComponents = [[[NSBundle mainBundle] bundleURL] pathComponents];
        NSMutableArray *subComponents = [[pathComponents subarrayWithRange:NSMakeRange(0, pathComponents.count - 3)] mutableCopy];
        [subComponents addObject:@"MacOS"];
        [subComponents addObject:@"Balance"];
        NSString *path = [NSString pathWithComponents:subComponents];
        NSLog(@"Balance helper launching Balance at path: %@", path);
        
        // Launch Balance
        [[NSWorkspace sharedWorkspace] launchApplication:path];
        
        // Terminate after 10 seconds
        sleep(10);
        [NSApp terminate:nil];
    }
}

@end
