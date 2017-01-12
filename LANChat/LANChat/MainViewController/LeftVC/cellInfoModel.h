//
//  cellInfoModel.h
//  LANChat
//
//  Created by lihongfeng on 16/12/29.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface cellInfoModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *chatLogs;
@property (nonatomic, assign) BOOL hasNewMessage;

@end
