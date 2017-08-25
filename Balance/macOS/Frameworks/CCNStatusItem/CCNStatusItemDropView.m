//
//  Created by David Sinclair on 2015-05-06.
//  Copyright (c) 2015 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2015 Frank Gregor, <phranck@cocoanaut.com>
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

#import "CCNStatusItemDropView.h"


@interface CCNStatusItemDropView ()

@property (nonatomic, copy) NSArray *privateDropTypes;

@end


@implementation CCNStatusItemDropView

- (NSArray *)dropTypes {
    return self.privateDropTypes;
}

- (void)setDropTypes:(NSArray *)dropTypes {
    self.privateDropTypes = dropTypes;
    [self registerForDraggedTypes:self.privateDropTypes];
}

- (NSString *)dropTypeInPasteboardTypes:(NSArray *)pasteboardTypes {
    for (NSString *type in self.dropTypes) {
        if ([pasteboardTypes containsObject:type]) {
            return type;
        }
    }
    return nil;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ([self dropTypeInPasteboardTypes:pboard.types]) {
        return NSDragOperationCopy;
    }
    else {
        return NSDragOperationNone;
    }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSString *type = [self dropTypeInPasteboardTypes:pboard.types];

    if (type) {
        NSArray *items = [pboard propertyListForType:type];
        if (self.dropHandler) {
            self.dropHandler(self.statusItem, type, items);
            return YES;
        }
    }
    return NO;
}

@end

