//
//  AppDelegate.m
//  TransmitInfoServer
//
//  Created by lihongfeng on 17/1/5.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import "AppDelegate.h"
#import "SocketServerManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) SocketServerManager *serverManager;

@property (weak) IBOutlet NSView *view;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (unsafe_unretained) IBOutlet NSTextView *infoView;
@property (nonatomic, strong) NSString *log;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    [self configServerManager];
    
    //客户端发送自己的地址给服务器
//    NSDictionary *dic1 = @{
//                           @"infoType": @"searchAddress",
//                           @"info": @{@"name": @"John",
//                                      @"address": @"0.0.0.0"}
//                           };
    //客户端向服务器请求全部在线用户地址
//    NSDictionary *dic2 = @{
//                           @"infoType": @"getAllAddress",
//                           @"info": @{@"fromAddress": @"0.0.0.0"}
//                           };
    //服务器将搜索到的在线用户地址发送给客户端
//    NSDictionary *dic3 = @{@"infoType": @"broadcastAllAddress",
//                           @"info": @{@"address": clientAddresses}};
    //客户端发送给服务器(聊天)
//    NSDictionary *dic4 = @{
//                           @"infoType": @"chatToServer",
//                           @"info": @{@"name": @"Tom",
//                                      @"address": @"0.0.0.0",
//                                      @"sendToAddress": @"0.0.0.0",
//                                      @"chatString": @"Hello, John!"}
//                           };
    //服务器发送给客户端(聊天)
//    NSDictionary *dic5 = @{
//                          @"infoType": @"chatToClient",
//                          @"info": @{@"fromName": @"Tom",
//                                     @"fromAddress": @"0.0.0.0",
//                                     @"chatString": @"Hello, John!"}
//                          };
    
    self.log = @"";
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor blackColor].CGColor;
    self.scrollView.autohidesScrollers = YES;
    self.infoView.textColor = [NSColor lightGrayColor];
    [self configServerManager];
    
}

- (void)configServerManager {
    self.serverManager = [[SocketServerManager alloc] init];
    __weak __block typeof(self) weakSelf = self;
    [self.serverManager didReceiveData:^(GCDAsyncSocket *sock, NSDictionary *dic) {
        NSDictionary *info = dic[@"info"];
        if ([dic[@"infoType"] isEqualToString:@"chatToServer"]) {
            NSDictionary *sendInfo = @{
                                       @"infoType": @"chatToClient",
                                       @"info": @{@"fromName": info[@"name"],
                                                  @"fromAddress": info[@"address"],
                                                  @"chatString": info[@"chatString"]}
                                       };
            [self updateChatInfoWithFromAddress:info[@"address"] to:info[@"sendToAddress"]];
            [weakSelf.serverManager sendDataToClientWithClientAddress:info[@"sendToAddress"] info:sendInfo];
        }else if ([dic[@"infoType"] isEqualToString:@"getAllAddress"]){
            [weakSelf.serverManager updateClientAddresses];
            NSDictionary *sendInfo = @{@"infoType": @"broadcastAllAddress",
                                   @"info": @{@"address": weakSelf.serverManager.clientAddresses}};
            [weakSelf.serverManager sendDataToClientWithClientAddress:info[@"fromAddress"] info:sendInfo];
        }
    }];
    [self.serverManager connectedClientsAddressDidChanged:^(NSMutableArray<NSDictionary *> *address) {
        [weakSelf updateClientsInfo];
    }];
    [self.serverManager acceptOnPort:8000];
}

- (void)broadcastAllAddressToClients {
    for (GCDAsyncSocket *sock in self.serverManager.acceptedSockets) {
        NSDictionary *info = @{@"infoType": @"broadcastAllAddress",
                               @"info": @{@"address": self.serverManager.clientAddresses}};
        NSData *data = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:nil];
        [sock writeData:data withTimeout:-1 tag:100];
    }
}

- (void)updateClientsInfo {
    NSString *info = @"";
    for (NSInteger i = 0; i < self.serverManager.clientAddresses.count; i++) {
        NSDictionary *dic = self.serverManager.clientAddresses[i];
        if (i == 0) {
            info = [info stringByAppendingString:[NSString stringWithFormat:@"\n客户端信息有更新:\n                 %@    %@", dic[@"address"], dic[@"name"]]];
        }else{
            info = [info stringByAppendingString:[NSString stringWithFormat:@"\n                 %@    %@", dic[@"address"], dic[@"name"]]];
        }
    }
    if (info.length == 0) {
        return;
    }
    self.log = info;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoView.string = info;
    });
    
}

- (void)updateChatInfoWithFromAddress:(NSString *)from to:(NSString *)to {
    NSString *str = [NSString stringWithFormat:@"\n聊天:\n              %@ ---> %@", from, to];
    if (str.length == 0) {
        return;
    }
    self.log = [self.log stringByAppendingString:str];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoView.string = self.log;
    });
}

@end












