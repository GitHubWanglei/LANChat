//
//  SocketClientManager.h
//  Socket_server
//
//  Created by lihongfeng on 17/1/5.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SocketClientManager : NSObject

@property (nonatomic, strong) GCDAsyncSocket *socketClient;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, readonly) NSString *localHost;//local host
@property (nonatomic, readonly) NSString *connectedHost;//remote host

+ (instancetype)shareManager;
- (void)initSocket;
- (void)connectToHost:(NSString *)host port:(uint16_t)port;
- (void)connectionStatusDidChanged:(void (^)(BOOL isConnected))status;
- (void)sendDataWithInfo:(NSDictionary *)info;
- (void)didReceiveData:(void (^)(NSDictionary *dic))receiveData;
- (void)getAllAddressCompletion:(void (^)(NSMutableArray<NSDictionary *> *addresses))allAddresses;

@end
