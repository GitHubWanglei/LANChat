//
//  SocketServerManager.m
//  Socket_server
//
//  Created by lihongfeng on 17/1/5.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import "SocketServerManager.h"

#define TAG_WRITE 101
#define TAG_READ 100
#define SearchAddress @"searchAddress"

@interface SocketServerManager ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socketServer;
@property (nonatomic, strong) GCDAsyncSocket *socketNew;
@property (nonatomic, strong) void (^receiveDataBlock)(GCDAsyncSocket *sock,  NSDictionary *dic);
@property (nonatomic, strong) void (^connectionChanged)(BOOL isConnected);
@property (nonatomic, strong) void (^acceptedSocketsChanged)(NSMutableArray<GCDAsyncSocket *> *acceptedSockets);
@property (nonatomic, strong) void (^clientsAddressDidChanged)(NSMutableArray<NSDictionary *> *address);

@end

@implementation SocketServerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.acceptedSockets = [NSMutableArray array];
        self.clientAddresses = [NSMutableArray array];
        self.socketServer = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                       delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}

#pragma mark - Public methods

- (void)acceptOnPort:(uint16_t)port {
    [self.socketServer acceptOnPort:port error:nil];
}

- (void)acceptedSocketsDidChanged:(void (^)(NSMutableArray<GCDAsyncSocket *> *acceptedSockets))acceptedSocketsChanged {
    self.acceptedSocketsChanged = acceptedSocketsChanged;
}

- (void)connectedClientsAddressDidChanged:(void (^)(NSMutableArray<NSDictionary *> *address))addressDidChanged {
    self.clientsAddressDidChanged = addressDidChanged;
}

- (void)sendDataToClientWithClientAddress:(NSString *)address info:(NSDictionary *)info {
    for (GCDAsyncSocket *sock in self.acceptedSockets) {
        if ([sock.connectedHost isEqualToString:address]) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
            [sock writeData:data withTimeout:-1 tag:TAG_WRITE];
        }
    }
}

- (void)didReceiveData:(void (^)(GCDAsyncSocket *sock,  NSDictionary *dic))receiveData {
    self.receiveDataBlock = receiveData;
}

- (void)connectionStatusDidChanged:(void (^)(BOOL isConnected))status {
    self.connectionChanged = status;
}

- (void)updateAcceptedSockets {
    for (GCDAsyncSocket *sock in self.acceptedSockets) {
        if (!sock.isConnected) {
            [sock setDelegate:nil];
            [sock disconnect];
            [self.acceptedSockets removeObject:sock];
        }
    }
}

- (void)updateClientAddresses {
    [self updateAcceptedSockets];
    NSMutableArray<NSDictionary *> *arr = [NSMutableArray array];
    for (NSDictionary *dic in self.clientAddresses) {
        NSString *address = dic[@"address"];
        for (GCDAsyncSocket *sock in self.acceptedSockets) {
            if ([address isEqualToString:sock.connectedHost]) {
                [arr addObject:dic];
                break;
            }
        }
    }
    self.clientAddresses = arr;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"accept new socket success.");
    for (GCDAsyncSocket *clientSock in self.acceptedSockets) {
        if ([clientSock.connectedHost isEqualToString:newSocket.connectedHost]) {
            [self.acceptedSockets removeObject:clientSock];
        }
    }
    [self.acceptedSockets addObject:newSocket];
    if (self.connectionChanged) {
        self.connectionChanged(YES);
    }
    if (self.acceptedSocketsChanged) {
        self.acceptedSocketsChanged(_acceptedSockets);
    }
    
    newSocket = newSocket;
    newSocket.delegate = self;
    [newSocket readDataWithTimeout:-1 tag:TAG_READ];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *infoType = dic[@"infoType"];
    if ([infoType isEqualToString:SearchAddress]) {
        NSDictionary *info = dic[@"info"];
        NSString *fromName = info[@"name"];
        NSString *fromAddress = info[@"address"];
        for (NSDictionary *dic in self.clientAddresses) {
            if ([fromAddress isEqualToString:dic[@"address"]]) {
                if ([fromName isEqualToString:dic[@"name"]]) {
                    return;
                }else{
                    [self.clientAddresses removeObject:dic];
                }
            }
        }
        [self.clientAddresses addObject:info];
        if (self.clientsAddressDidChanged) {
            self.clientsAddressDidChanged(_clientAddresses);
        }
    }else{
        if (self.receiveDataBlock) {
            self.receiveDataBlock(sock, dic);
        }
    }
    [sock readDataWithTimeout:-1 tag:TAG_READ];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"Disconnect error: %@", err.localizedDescription);
    if (self.connectionChanged) {
        self.connectionChanged(NO);
    }
    [self updateClientAddresses];
}

#pragma mark - Getter

- (BOOL)isConnected {
    return self.socketServer.isConnected;
}

@end









