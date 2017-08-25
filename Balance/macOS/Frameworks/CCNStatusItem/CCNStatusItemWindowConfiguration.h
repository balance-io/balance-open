//
//  Created by Frank Gregor on 27.12.14.
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
#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, CCNPresentationTransition) {
    CCNPresentationTransitionNone = 0,
    CCNPresentationTransitionFade,
    CCNPresentationTransitionSlideAndFade
};

static const CGFloat CCNDefaultArrowHeight  = 11.0;                                 //8.0
static const CGFloat CCNDefaultArrowWidth   = 42.0;                                 //34.0
static const CGFloat CCNDefaultCornerRadius = 8.0;                                  //7.0


@interface CCNStatusItemWindowConfiguration : NSObject

+ (instancetype)defaultConfiguration;

// status item window
@property (assign, nonatomic) CGFloat windowToStatusItemMargin;                     // default: 2.0
@property (assign, nonatomic) NSTimeInterval animationDuration;                     // default: 0.21
@property (strong, nonatomic) NSColor *backgroundColor;								// default: [NSColor windowBackgroundColor]
@property (assign, nonatomic) CCNPresentationTransition presentationTransition;     // default: CCNPresentationTransitionFade
                                                                                    // On setting the 'presentationTranstion' to case 'CCNPresentationTransitionNone' property 'animationDuration' will be set to 0
                                                                                    // status item
@property (strong, nonatomic) NSString *toolTip;
@property (assign, nonatomic, getter=isPinned) BOOL pinned;							// default: NO; Normally if the window loses its key window status it will be dismissed automatically. Setting this property to YES keeps the window visible.

@end
