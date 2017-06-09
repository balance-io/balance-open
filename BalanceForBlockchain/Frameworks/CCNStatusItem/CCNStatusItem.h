//
//  Created by Frank Gregor on 21/12/14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2014 Frank Gregor, <phranck@cocoanaut.com>
 http://cocoanaut.mit-license.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>
#import "CCNStatusItemWindowConfiguration.h"


@class CCNStatusItem;

typedef NS_ENUM(NSUInteger, CCNStatusItemPresentationMode) {
    CCNStatusItemPresentationModeUndefined = 0,
    CCNStatusItemPresentationModeImage,
    CCNStatusItemPresentationModeCustomView
};
typedef NS_ENUM(NSInteger, CCNStatusItemProximityDragStatus) {
    CCNProximityDragStatusEntered = 0,
    CCNProximityDragStatusExited
};

typedef void (^CCNStatusItemDropHandler)(CCNStatusItem *sharedItem, NSString *pasteboardType, NSArray *droppedObjects);
typedef void (^CCNStatusItemProximityDragDetectionHandler)(CCNStatusItem *sharedItem, NSPoint eventLocation, CCNStatusItemProximityDragStatus proxymityDragStatus);
typedef BOOL (^CCNStatusItemShouldShowHandler)(CCNStatusItem *sharedItem);


#pragma mark - CCNStatusItem

@interface CCNStatusItem : NSObject

#pragma mark - Initialization
/** @name Initialization */

/**
 Returns a shared `CCNStatusItem` object.
 
 If the shared `CCNStatusItem` object doesn't exist yet, it is created.

 @return The shared `CCNStatusItem` object.
 */
+ (instancetype)sharedInstance;

#pragma mark - Creating and Displaying a StatusBarItem
/** @name Creating and Displaying a StatusBarItem */

/**
 Presents the shared `CCNStatusItem` object with the given image and contentViewController for the popover window.

 @param itemImage             The image the is displayed in the status bar item. This image becomes a template image automatically.
 @param contentViewController The contentViewController that is displayed in the popover window.
 */
- (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController;

/**
 Presents the shared `CCNStatusItem` object with the given image and contentViewController for the popover window.

 @param itemImage             The image the is displayed in the status bar item. This image becomes a template image automatically.
 @param contentViewController The contentViewController that is displayed in the popover window.
 @param dropHandler           A handler to be called when a drop occurs on the status bar item.
 */
- (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler;

/**
 Presents the shared `CCNStatusItem` object with the given custom view and contentViewController for the popover window.

 @param itemView              A view to be presented as the status item view.
 @param contentViewController The contentViewController that is displayed in the popover window.
 */
- (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController;

/**
 Presents the shared `CCNStatusItem` object with the given custom view and contentViewController for the popover window.

 @param itemView              A view to be presented as the status item view.
 @param contentViewController The contentViewController that is displayed in the popover window.
 @param dropHandler           A handler to be called when a drop occurs on the status bar item.
 */
- (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler;

/**
 Update the contentViewController for the popover window.
 
 @param contentViewController The contentViewController that is displayed in the popover window.
 */
- (void)updateContentViewController:(NSViewController *)contentViewController;

/**
 Removes the status item.
 */
- (void)removeStatusItem;

/**
 Property that represents the underlying `NSStatusItem` to be displayed in the statusbar.
 */
@property (strong, readonly) NSStatusItem *statusItem;

/**
 Property that represents the dropHandler to be executed if not nil.
 */
@property (copy, nonatomic) CCNStatusItemDropHandler dropHandler;

/**
 Property that represents the shouldShowHandler to be executed when the status item is clicked, if not nil.
 */
@property (copy, nonatomic) CCNStatusItemShouldShowHandler shouldShowHandler;


#pragma mark - StatusBarItem and Popover presentation
/** @name StatusBarItem and Popover presentation */

/**
 Boolean property that determines whether the system, thus the status item is in dark (dark menu bar) or light mode.
 */
@property (readonly, nonatomic) BOOL isDarkMode;

/**
 Boolean property that determines whether the status item appears disabled or normal.
 
 Appearing disabled doesn't mean the status item itself is disabled too. This behaviour is often used for indicating network reachability e.g.
 */
@property (assign, nonatomic) BOOL appearsDisabled;

/**
 Boolean property that determines whether the status item is enabled or not.
 
 @value YES The status item is enable.
 @value NO The status item is disabled.
 */
@property (assign, nonatomic) BOOL enabled;

/**
 Boolean property that determines whether the status item popover is currently visible or not.
 
 @value YES The popover is visible.
 @value NO The popover is not visible.
 */
@property (readonly, nonatomic) BOOL isStatusItemWindowVisible;

/**
 Presents the popover window.
 
 If the `contentViewController` isn't set nothing will happen.
 */
- (void)showStatusItemWindow;

/**
 Dismisses the popover window.
 
 Since this popover is a subclass of `NSPanel` it won't released when it's closed.
 */
- (void)dismissStatusItemWindow;

/**
 Resizes the popover window.
 
 Does some NSRect origin magic to keep it aligned properly
 */
- (void)resizeStatusItemWindow:(NSSize)size animated:(BOOL)animated;
- (void)resizeStatusItemWindowHeight:(CGFloat)height animated:(BOOL)animated;


# pragma mark - Handling Drag Events and Proximity Drag Detection
/** @name Handling Drag Events and Proximity Drag Detection */

/**
 Boolean property that determines whether the status item is sensitive for advances or not.
 */
@property (assign, nonatomic, getter=isProximityDragDetectionEnabled) BOOL proximityDragDetectionEnabled;
@property (assign, nonatomic) NSInteger proximityDragZoneDistance;
@property (copy, nonatomic) CCNStatusItemProximityDragDetectionHandler proximityDragDetectionHandler;
@property (copy, nonatomic) NSArray *dropTypes;


#pragma mark - Handling StatusItem Popover Layout
/** @name Handling StatusItem Popover Layout */

/**
 Property that holds an window configuration object.
 
 @see `CCNStatusItemWindowConfiguration`.
 */
@property (strong, nonatomic) CCNStatusItemWindowConfiguration *windowConfiguration;

@property (strong, nonatomic) NSColor *arrowColor;

@property (nonatomic) BOOL drawBorder;

@end

extern BOOL CCNStatusItemWindowDrawBorder;

#pragma mark - Deprecated

@interface CCNStatusItem (CCNStatusItemDeprecated)

+ (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController __attribute__((deprecated("Please use the instance method instead!")));
+ (void)presentStatusItemWithImage:(NSImage *)itemImage contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler __attribute__((deprecated("Please use the instance method instead!")));
+ (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController __attribute__((deprecated("Please use the instance method instead!")));
+ (void)presentStatusItemWithView:(NSView *)itemView contentViewController:(NSViewController *)contentViewController dropHandler:(CCNStatusItemDropHandler)dropHandler __attribute__((deprecated("Please use the instance method instead!")));
+ (void)setWindowConfiguration:(CCNStatusItemWindowConfiguration *)configuration __attribute__((deprecated("Please use the property instead!")));

@end




// Each notification has the statusItemWindow as notification object. The userInfo dictionary is nil.
FOUNDATION_EXPORT NSString *const CCNStatusItemWindowWillShowNotification;
FOUNDATION_EXPORT NSString *const CCNStatusItemWindowDidShowNotification;
FOUNDATION_EXPORT NSString *const CCNStatusItemWindowWillDismissNotification;
FOUNDATION_EXPORT NSString *const CCNStatusItemWindowDidDismissNotification;
FOUNDATION_EXPORT NSString *const CCNSystemInterfaceThemeChangedNotification;			// sent every time when system theme toggles between dark menu mode and mormal menu mode
