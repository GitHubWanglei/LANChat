//
//  LeftVCTableRowView.m
//  LANChat
//
//  Created by lihongfeng on 16/12/28.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "LeftVCTableRowView.h"

@implementation LeftVCTableRowView

// 客製化 row 被选中的背景色
-(void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
        [[NSColor colorWithRed:217/255.0 green:244/255.0 blue:254/255.0 alpha:0.6] setFill];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(self.bounds, 0, 0)];
        [path fill];
        [path stroke];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
