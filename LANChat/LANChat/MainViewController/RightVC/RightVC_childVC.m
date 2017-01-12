//
//  RightVC_childVC.m
//  LANChat
//
//  Created by lihongfeng on 16/12/29.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "RightVC_childVC.h"
#import "Masonry.h"
#import "SocketClientManager.h"
#import "UserInfoManager.h"
#import "cellInfoModel.h"

@interface RightVC_childVC ()<NSTextViewDelegate>

@property (nonatomic, strong) NSSplitView *splitView;
@property (nonatomic, strong) NSView *top_View;
@property (nonatomic, strong) NSView *bottom_View;
@property (nonatomic, strong) NSTextView *top_textView;
@property (nonatomic, strong) NSTextView *bottom_textView;
@property (nonatomic, strong) SocketClientManager *socketManager;
@property (nonatomic, strong) UserInfoManager *userInfo;
@property (nonatomic, strong) NSString *sendName;
@property (nonatomic, strong) NSString *sendAddress;

@end

@implementation RightVC_childVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.splitView];
    [self.splitView addSubview:self.top_View];
    [self.splitView addSubview:self.bottom_View];
    
    [self.top_View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@(420));
        make.height.lessThanOrEqualTo(@(421));
    }];
    [self.bottom_View mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@(560-421));
        make.height.lessThanOrEqualTo(@(560-420));
    }];
    
    self.socketManager = [SocketClientManager shareManager];
    self.userInfo = [UserInfoManager shareManager];
    [self addObserver];
}

- (void)sendChatLogsChangedNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RightVC_childVC_chatLogsChanged"
                                                        object:@{@"address": self.sendAddress, @"chatLog": self.top_textView.string}];
}

#pragma mark - NSTextViewDelegate

- (BOOL)textShouldBeginEditing:(NSText *)textObject {
    return YES;
}

- (BOOL)textShouldEndEditing:(NSText *)textObject {
    return YES;
}

- (void)textDidBeginEditing:(NSNotification *)notification{
    NSLog(@"%s", __FUNCTION__);
}

- (void)textDidEndEditing:(NSNotification *)notification{
    NSLog(@"%s", __FUNCTION__);
}

- (void)textDidChange:(NSNotification *)notification {
    NSLog(@"%s", __FUNCTION__);
    
    NSTextView *textView = notification.object;
    if (self.bottom_textView == textView) {
        self.bottom_textView = textView;
        NSLog(@"~~~~~~~~~~~%@", self.bottom_textView.string);
        NSString *inputString = self.bottom_textView.string;
        NSRange r = [inputString rangeOfString:@"\n"];
        if (r.length > 0) {
            NSString *str = [NSString stringWithFormat:@"\n%@: %@", [self.userInfo getName], inputString];
            NSLog(@"______sendLog: %@", str);
            self.top_textView.string = [self.top_textView.string stringByAppendingString:str];
            [self sendChatLogsChangedNotification];
            self.bottom_textView.string = @"";
            if (self.socketManager.isConnected) {
                NSDictionary *info = @{
                                       @"infoType": @"chatToServer",
                                       @"info": @{@"name": [self.userInfo getName],
                                                  @"address": self.socketManager.localHost,
                                                  @"sendToAddress": self.sendAddress,
                                                  @"chatString": str}
                                       };
                [self.socketManager sendDataWithInfo:info];
            }
        }
    }
}

- (void)dealloc {
    [self removeObserver];
}

#pragma mark - Observer selected row

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelctedRowNotification:)
                                                 name:@"LeftVC_didSelectRow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveChatLog:)
                                                 name:@"MainWindowController_receiveChatLog"
                                               object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LeftVC_didSelectRow" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MainWindowController_receiveChatLog" object:nil];
}

- (void)didSelctedRowNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    NSLog(@"_______dic: %@", dic[@"info"]);
    cellInfoModel *model = dic[@"info"];
    NSLog(@"name: %@, address: %@", model.name, model.address);
    if (model != nil) {
        self.sendName = model.name;
        self.sendAddress = model.address;
        if (model.chatLogs.length > 0) {
            self.top_textView.string = [self.top_textView.string stringByAppendingString:model.chatLogs];
        }
    }
}

- (void)receiveChatLog:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    NSLog(@"chatLogs: %@", dic);
    NSDictionary *info = dic[@"info"];
    if ([info[@"fromAddress"] isEqualToString:self.sendAddress]) {
        NSString *str = [NSString stringWithFormat:@"%@", info[@"chatString"]];
        self.top_textView.string = [self.top_textView.string stringByAppendingString:str];
        [self sendChatLogsChangedNotification];
    }
}

#pragma mark - Lazy load

- (NSSplitView *)splitView {
    if (!_splitView) {
        _splitView = [[NSSplitView alloc] initWithFrame:self.view.bounds];
        _splitView.vertical = NO;
        _splitView.dividerStyle = NSSplitViewDividerStyleThin;
    }
    return _splitView;
}

- (NSView *)top_View {
    if (!_top_View) {
        _top_View = [[NSView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 420)];
        self.top_textView = [[NSTextView alloc] initWithFrame:_top_View.bounds];
        self.top_textView.backgroundColor = [NSColor whiteColor];
        self.top_textView.editable = NO;
        [_top_View addSubview:self.top_textView];
    }
    return _top_View;
}

- (NSView *)bottom_View {
    if (!_bottom_View) {
        _bottom_View = [[NSView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
        self.bottom_textView = [[NSTextView alloc] initWithFrame:_bottom_View.bounds];
        self.bottom_textView.backgroundColor = [NSColor whiteColor];
        _bottom_textView.delegate = self;
        [_bottom_View addSubview:self.bottom_textView];
    }
    return _bottom_View;
}

@end









