//
//  SocketServerManager.h
//  Socket_server
//
//  Created by lihongfeng on 17/1/5.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface SocketServerManager : NSObject

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) NSMutableArray<GCDAsyncSocket *> *acceptedSockets;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *clientAddresses;

- (void)acceptOnPort:(uint16_t)port;
- (void)acceptedSocketsDidChanged:(void (^)(NSMutableArray<GCDAsyncSocket *> *acceptedSockets))acceptedSocketsChanged;
- (void)connectedClientsAddressDidChanged:(void (^)(NSMutableArray<NSDictionary *> *address))addressDidChanged;
- (void)sendDataToClientWithClientAddress:(NSString *)address info:(NSDictionary *)info;
- (void)didReceiveData:(void (^)(GCDAsyncSocket *sock,  NSDictionary *dic))receiveData;
- (void)connectionStatusDidChanged:(void (^)(BOOL isConnected))status;
- (void)updateClientAddresses;

@end
