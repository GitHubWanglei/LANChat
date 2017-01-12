//
//  SocketClientManager.m
//  Socket_server
//
//  Created by lihongfeng on 17/1/5.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import "SocketClientManager.h"

#define TAG_WRITE 100
#define TAG_READ 101

@interface SocketClientManager ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) void (^receiveDataBlock)(NSDictionary *dic);
@property (nonatomic, strong) void (^connectionChanged)(BOOL isConnected);
@property (nonatomic, strong) void (^getAllAddress)(NSMutableArray<NSDictionary *> *addresses);

@end

@implementation SocketClientManager

+ (instancetype)shareManager {
    static SocketClientManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SocketClientManager alloc] init];
    });
    return manager;
}

- (void)initSocket {
    self.socketClient = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                      delegateQueue:dispatch_get_global_queue(0, 0)];
}

- (void)connectToHost {
    [self.socketClient connectToHost:_host
                              onPort:_port
                         withTimeout:-1
                               error:nil];
}

#pragma mark - Public methods

- (void)connectToHost:(NSString *)host port:(uint16_t)port {
    self.host = host;
    self.port = port;
    [self performSelectorInBackground:@selector(connectToHost) withObject:nil];
}

- (void)connectionStatusDidChanged:(void (^)(BOOL isConnected))status {
    self.connectionChanged = status;
}

- (void)sendDataWithInfo:(NSDictionary *)info {
    if (!self.socketClient.isConnected || info == nil) {
        return;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:info
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    [self.socketClient writeData:data withTimeout:-1 tag:TAG_WRITE];
}

- (void)didReceiveData:(void (^)(NSDictionary *dic))receiveData {
    self.receiveDataBlock = receiveData;
}

- (void)getAllAddressCompletion:(void (^)(NSMutableArray<NSDictionary *> *addresses))allAddresses {
    self.getAllAddress = allAddresses;
    NSDictionary *dic = @{
                           @"infoType": @"getAllAddress",
                           @"info": @{@"fromAddress": self.socketClient.localHost}
                           };
    [self sendDataWithInfo:dic];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"connect to host success.");
    if (self.connectionChanged) {
        self.connectionChanged(YES);
    }
    [self.socketClient readDataWithTimeout:-1 tag:TAG_READ];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
    if ([dic[@"infoType"] isEqualToString:@"broadcastAllAddress"]) {
        if (self.getAllAddress) {
            NSDictionary *info = dic[@"info"];
            self.getAllAddress(info[@"address"]);
        }
    }else{
        if (self.receiveDataBlock) {
            self.receiveDataBlock(dic);
        }
    }
    [self.socketClient readDataWithTimeout:-1 tag:TAG_READ];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"Disconnect error: %@", err.localizedDescription);
    if (self.connectionChanged) {
        self.connectionChanged(NO);
    }
    [NSThread sleepForTimeInterval:2];
    [self performSelectorInBackground:@selector(connectToHost) withObject:nil];
}

#pragma mark - Getter

- (BOOL)isConnected {
    return self.socketClient.isConnected;
}

- (NSString *)localHost {
    return self.socketClient.localHost;
}

- (NSString *)connectedHost {
    return self.socketClient.connectedHost;
}

@end








