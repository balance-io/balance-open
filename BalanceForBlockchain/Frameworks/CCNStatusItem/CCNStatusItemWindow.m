//
//  Created by Frank Gregor on 26.12.14.
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

#import "CCNStatusItemWindow.h"
#import "CCNStatusItemWindowBackgroundView.h"
#import "CCNStatusItem.h"
#import "CCNStatusItemWindowConfiguration.h"

@interface CCNStatusItemWindow () {
    CCNStatusItemWindowConfiguration *_configuration;
}
@property (strong) NSView *userContentView;
@end

@implementation CCNStatusItemWindow(NoShadowRim)

- (id)_shadowRimInfo {
//    if (!CCNStatusItemWindowDrawBorder) return @{
//                                                 @"kCUIMeasureWindowFrameRimDensity": [NSNumber numberWithInt:0]
//                                                 };
    return nil;
}

@end

@implementation CCNStatusItemWindow

+ (instancetype)statusItemWindowWithConfiguration:(CCNStatusItemWindowConfiguration *)configuration {
    return [[[self class] alloc] initWithContentRect:NSZeroRect styleMask:NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:YES configuration:configuration];
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag configuration:(CCNStatusItemWindowConfiguration *)configuration {
    _configuration = configuration;
    self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:flag];
    if (self) {
        self.opaque = NO;
        self.hasShadow = YES;
        self.level = NSStatusWindowLevel;
        self.backgroundColor = [NSColor clearColor];
        self.collectionBehavior = (NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorIgnoresCycle);
        [self setAppearance:[NSAppearance currentAppearance]];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)setContentView:(id)contentView {
    if ([self.userContentView isEqual:contentView]) return;

    NSView *userContentView = (NSView *)contentView;
    NSRect bounds = userContentView.bounds;
    CAEdgeAntialiasingMask antialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;

    self.backgroundView = super.contentView;
    if (!self.backgroundView) {
        self.backgroundView = [[CCNStatusItemWindowBackgroundView alloc] initWithFrame:bounds windowConfiguration:_configuration];
        self.backgroundView.wantsLayer = YES;
        self.backgroundView.layer.frame = bounds;
        self.backgroundView.layer.cornerRadius = CCNDefaultCornerRadius;
        self.backgroundView.layer.masksToBounds = YES;
        self.backgroundView.layer.edgeAntialiasingMask = antialiasingMask;
        super.contentView = self.backgroundView;
    }

    if (self.userContentView) {
        [self.userContentView removeFromSuperview];
    }

    self.userContentView = userContentView;
    self.userContentView.frame = [self contentRectForFrameRect:bounds];
    self.userContentView.wantsLayer = YES;
    self.userContentView.layer.frame = bounds;
    self.userContentView.layer.cornerRadius = CCNDefaultCornerRadius;
    self.userContentView.layer.masksToBounds = YES;
    self.userContentView.layer.edgeAntialiasingMask = antialiasingMask;
    
    [self.backgroundView addSubview:self.userContentView];
    
    [self.userContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSView *subview = self.userContentView;
    [self.backgroundView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"H:|-0-[subview]-0-|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(subview)]];
    [self.backgroundView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:|-11-[subview]-0-|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(subview)]];    
}

- (id)contentView {
    return self.userContentView;
}

- (NSRect)frameRectForContentRect:(NSRect)contentRect {
    return NSMakeRect(NSMinX(contentRect), NSMinY(contentRect), NSWidth(contentRect), NSHeight(contentRect) + CCNDefaultArrowHeight);
}

//- (NSTimeInterval)animationResizeTime:(NSRect)newFrame {
//    return 0.1;
//}

@end
