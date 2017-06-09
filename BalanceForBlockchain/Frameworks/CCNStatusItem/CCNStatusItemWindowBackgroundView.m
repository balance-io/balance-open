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


#import "CCNStatusItemWindowBackgroundView.h"


@interface CCNStatusItemWindowBackgroundView ()
@property (strong) CCNStatusItemWindowConfiguration *windowConfiguration;
@end

@implementation CCNStatusItemWindowBackgroundView

- (instancetype)initWithFrame:(NSRect)frameRect windowConfiguration:(CCNStatusItemWindowConfiguration *)configuration {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.windowConfiguration = configuration;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    CGFloat arrowHeight   = CCNDefaultArrowHeight;
    CGFloat arrowWidth    = CCNDefaultArrowWidth;
    CGFloat cornerRadius  = CCNDefaultCornerRadius;
    NSRect backgroundRect = NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), NSHeight(self.bounds) - arrowHeight);

    NSBezierPath *windowPath     = [NSBezierPath bezierPath];
    NSBezierPath *arrowPath      = [NSBezierPath bezierPath];
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:backgroundRect xRadius:cornerRadius yRadius:cornerRadius];

    NSPoint leftPoint  = {NSWidth(backgroundRect) / 2 - arrowWidth / 2, NSMaxY(backgroundRect)};
    NSPoint topPoint   = {NSWidth(backgroundRect) / 2, NSMaxY(backgroundRect) + arrowHeight};
    NSPoint rightPoint = {NSWidth(backgroundRect) / 2 + arrowWidth / 2, NSMaxY(backgroundRect)};

    [arrowPath moveToPoint:leftPoint];
    [arrowPath curveToPoint:topPoint
              controlPoint1:NSMakePoint(NSWidth(backgroundRect) / 2 - arrowWidth / 4, NSMaxY(backgroundRect))
              controlPoint2:NSMakePoint(NSWidth(backgroundRect) / 2 - arrowWidth / 7, NSMaxY(backgroundRect) + arrowHeight)];
    [arrowPath curveToPoint:rightPoint
              controlPoint1:NSMakePoint(NSWidth(backgroundRect) / 2 + arrowWidth / 7, NSMaxY(backgroundRect) + arrowHeight)
              controlPoint2:NSMakePoint(NSWidth(backgroundRect) / 2 + arrowWidth / 4, NSMaxY(backgroundRect))];
    [arrowPath lineToPoint:leftPoint];
    [arrowPath closePath];

    [windowPath appendBezierPath:arrowPath];
    [windowPath appendBezierPath:backgroundPath];

    [self.windowConfiguration.backgroundColor setFill];
    [windowPath fill];
    
    if (_arrowColor) {
        [_arrowColor setFill];
        [arrowPath fill];
    }
}

- (void)setArrowColor:(NSColor *)arrowColor {
    _arrowColor = arrowColor;
    [self setNeedsDisplay:YES];
}

#pragma mark - Custom Accessors

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay:YES];
}

@end
