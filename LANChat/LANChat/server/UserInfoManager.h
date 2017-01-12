//
//  UserInfoManager.h
//  LANChat
//
//  Created by lihongfeng on 16/12/30.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoManager : NSObject

+ (instancetype)shareManager;

- (NSString *)getName;
- (void)setName:(NSString *)name;

- (NSString *)getAddress;
- (void)setAddress:(NSString *)address;

- (NSMutableArray *)getAddressArray;
- (void)setAddressArray:(NSMutableArray *)addressArray;

@end
