//
//  SearchAddressManager.m
//
//  Created by wanglei on 16/12/23.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "SearchAddressManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <net/if.h>
#import "GCDAsyncUdpSocket.h"

@interface SearchAddressManager ()<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) void (^addressUpdateHandler)(NSMutableArray *addressArray);
@property (nonatomic, strong) void (^connectStatus)(ConnectionStatus status);
@property (nonatomic, assign) NSTimeInterval searchTimeInterval;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL timeOver;

@end

@implementation SearchAddressManager

+ (instancetype)shareManager {
    static SearchAddressManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SearchAddressManager alloc] init];
        manager.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:manager delegateQueue:dispatch_get_global_queue(0, 0)];
        manager.addressArray = [NSMutableArray array];
        manager.searchTimeInterval = 0.0;
        manager.timeOver = NO;
    });
    return manager;
}

- (void)broadcastSearchAddressWithInfo:(NSString *)info {
    NSError *enableBroadcastError = nil;
    [self.udpSocket enableBroadcast:YES error:&enableBroadcastError];
    if (enableBroadcastError) {
        NSLog(@"enableBroadcast error: %@", enableBroadcastError.localizedDescription);
        return;
    }
    NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
    //發送廣播
    NSLog(@"searching address......");
    [self.udpSocket sendData:data
                      toHost:@"255.255.255.255"
                        port:8000
                 withTimeout:-1
                         tag:100];
    //開始監聽
    [self.udpSocket receiveOnce:nil];
}

- (void)closeUdpSocket{
    [self.udpSocket setDelegate:nil];
    [self.udpSocket close];
    [self.timer invalidate];
    self.timer = nil;
    _timeOver = YES;
}

#pragma mark - Public method

- (void)startSearchAddress {
    _searchTimeInterval = 0.0;
    _timeOver = NO;
    [self.udpSocket bindToPort:8000 error:nil];
    [self broadcastSearchAddressWithInfo:self.name];
}

- (void)addressArrayUpdate:(void (^)(NSMutableArray *addressArray))addressUpdateHandler {
    _addressUpdateHandler = addressUpdateHandler;
}

- (void)connectStatusUpdate:(void (^)(ConnectionStatus connectStatus))connectStatus {
    _connectStatus = connectStatus;
}

- (void)startSearchAddressWithTimeInterval:(NSTimeInterval)interval{
    if (interval > 5.0) {
        _searchTimeInterval = interval;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:_searchTimeInterval target:self selector:@selector(closeUdpSocket) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
    [self startSearchAddress];
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *fromName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *fromAddress = [[GCDAsyncUdpSocket hostFromAddress:address] stringByReplacingOccurrencesOfString:@"::ffff:" withString:@""];
    NSArray *exceptAddressArray = @[@"169.254.126.109"];//此處填寫本地局域網保留地址, 將其過濾屏蔽
    for (NSString *exceptAddress in exceptAddressArray) {
        if ([fromAddress isEqualToString:exceptAddress]) {
            return;
        }
    }
    for (NSDictionary *dic in self.addressArray) {
        if ([fromAddress isEqualToString:dic[@"address"]]) {
            if ([fromName isEqualToString:dic[@"name"]]) {
                return;
            }else{
                [self.addressArray removeObject:dic];
            }
        }
    }
    [self.addressArray addObject:@{@"name": fromName, @"address": fromAddress}];
    if (self.addressUpdateHandler) {
        self.addressUpdateHandler(_addressArray);
    }
    if (self.connectStatus) {
        self.connectStatus(ConnectionStatusConnected);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    if (_timeOver) {
        return;
    }
    sleep(2);
    [self broadcastSearchAddressWithInfo:_name];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    if (self.connectStatus) {
        self.connectStatus(ConnectionStatusDisConnected);
    }
    if (_timeOver) {
        return;
    }
    sleep(2);
    self.addressArray = [NSMutableArray array];
    [self.udpSocket bindToPort:8000 error:nil];
    [self broadcastSearchAddressWithInfo:_name];
}

@end
