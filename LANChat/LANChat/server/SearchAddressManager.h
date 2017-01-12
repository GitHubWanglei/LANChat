//
//  SearchAddressManager.h
//
//  Created by wanglei on 16/12/23.
//  Copyright © 2016年 wanglei. All rights reserved.
//  UPD廣播尋址

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

typedef NS_OPTIONS(NSUInteger, ConnectionStatus) {
    ConnectionStatusConnected,
    ConnectionStatusDisConnected
};

@interface SearchAddressManager : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *addressArray;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

+ (instancetype)shareManager;

/**
 搜尋到address有更新時會進行回調
 */
- (void)addressArrayUpdate:(void (^)(NSMutableArray *addressArray))addressUpdateHandler;

/**
 連接狀態的回調
 */
- (void)connectStatusUpdate:(void (^)(ConnectionStatus connectStatus))connectStatus;

/**
 開始搜尋
 @param interval 搜尋持續時間(必須大於5s, 小於5s時無時間限制)
 */
- (void)startSearchAddressWithTimeInterval:(NSTimeInterval)interval;

/**
 開始搜尋, 調用此方法會持續不停搜尋(無時間限制)
 */
- (void)startSearchAddress;

/**
 停止搜尋
 */
- (void)closeUdpSocket;

@end









