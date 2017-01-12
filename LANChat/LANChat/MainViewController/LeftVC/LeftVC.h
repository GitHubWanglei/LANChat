//
//  LeftVC.h
//  LANChat
//
//  Created by lihongfeng on 16/12/28.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LeftVC : NSViewController

@property (nonatomic, strong) NSMutableArray *addressArray;

- (void)reloadView;

@end
