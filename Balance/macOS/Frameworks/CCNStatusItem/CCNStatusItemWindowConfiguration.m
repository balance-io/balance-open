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


#import "CCNStatusItemWindowConfiguration.h"


static const CGFloat CCNDefaultStatusItemMargin         = 2.0;
static const NSTimeInterval CCNDefaultAnimationDuration = 0.21;


@implementation CCNStatusItemWindowConfiguration

+ (instancetype)defaultConfiguration {
    return [[[self class] alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.windowToStatusItemMargin = CCNDefaultStatusItemMargin;
        self.animationDuration        = CCNDefaultAnimationDuration;
        self.presentationTransition   = CCNPresentationTransitionFade;
        self.toolTip                  = nil;
        self.backgroundColor          = [NSColor windowBackgroundColor];
        self.pinned                   = NO;
    }
    return self;
}

#pragma mark - Custom Accessors

- (void)setPresentationTransition:(CCNPresentationTransition)presentationTransition {
    if (_presentationTransition != presentationTransition) {
        _presentationTransition = presentationTransition;
        if (_presentationTransition == CCNPresentationTransitionNone) {
            self.animationDuration = 0;
        }
        else {
            self.animationDuration = CCNDefaultAnimationDuration;
        }
    }
}

@end
