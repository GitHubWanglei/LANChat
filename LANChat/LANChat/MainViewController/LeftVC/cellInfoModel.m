//
//  cellInfoModel.m
//  LANChat
//
//  Created by lihongfeng on 16/12/29.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "cellInfoModel.h"

@implementation cellInfoModel

- (NSString *)chatLogs {
    if (!_chatLogs) {
        _chatLogs = @"";
    }
    return _chatLogs;
}

@end
