//
//  UserInfoManager.m
//  LANChat
//
//  Created by lihongfeng on 16/12/30.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "UserInfoManager.h"

@implementation UserInfoManager

+ (instancetype)shareManager {
    static UserInfoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserInfoManager alloc] init];
    });
    return manager;
}

- (NSString *)getName {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
}

- (void)setName:(NSString *)name {
    if (name == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getAddress {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"address"];
}

- (void)setAddress:(NSString *)address {
    if (address == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"address"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"address"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray *)getAddressArray {
    return [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"addressArray"]];
}

- (void)setAddressArray:(NSMutableArray *)addressArray {
    if (addressArray == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"addressArray"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:addressArray forKey:@"addressArray"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end













