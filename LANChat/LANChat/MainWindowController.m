//
//  MainWindowController.m
//  LANChat
//
//  Created by lihongfeng on 16/12/26.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "MainWindowController.h"
#import "SearchAddressManager.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "UserInfoManager.h"
#import "SocketClientManager.h"

@interface MainWindowController ()

@property (nonatomic, strong) UserInfoManager *userInfo;
@property (nonatomic, strong) NSMutableArray *addressArray;
@property (nonatomic, strong) SocketClientManager *socketManager;

@property (strong) IBOutlet NSToolbar *toolbar;
@property (strong) IBOutlet NSToolbarItem *settingItem;
@property (strong) IBOutlet NSPanel *settingPanel;
@property (strong) IBOutlet NSView *userInfoView;
@property (strong) IBOutlet NSTextField *userNameLable;
@property (strong) IBOutlet NSButton *statusButton;
@property (strong) IBOutlet NSMenu *ChangeStatusMenu;
@property (strong) IBOutlet NSMenuItem *onlineItem;
@property (strong) IBOutlet NSMenuItem *offlineItem;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) MainViewController *MainVC;
@property (nonatomic, strong) SettingViewController *settingVC;
@property (nonatomic, strong) NSPopover *popover;

@property (nonatomic, strong) NSString *inputName;
@property (nonatomic, assign) BOOL needInputName;
@property (nonatomic, assign) BOOL needRefreshAddress;

@end

@implementation MainWindowController

#pragma Life cycle

- (NSString *)windowNibName {
    return @"MainWindowController";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshAddressNotification:)
                                                 name:@"RefreshAddressViewController_refreshAddress"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userNameUpdateNotification:)
                                                 name:@"PersonalInfoViewController_userNameUpdate"
                                               object:nil];
    
    self.needRefreshAddress = NO;
    self.userInfoView.wantsLayer = YES;
    self.userInfoView.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.MainVC =[[MainViewController alloc] init];
    self.window.contentViewController = self.MainVC;
    
    //test
    self.userInfo = [UserInfoManager shareManager];
    [self.userInfo setName:nil];
    [self.userInfo setAddressArray:nil];
    
    NSString *name = [self.userInfo getName];
    if (name == nil) {//須輸入姓名
        self.needInputName = YES;
        self.settingItem.enabled = NO;
        self.statusButton.enabled = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startActionNotification:)
                                                     name:@"MainViewController_startAction"
                                                   object:nil];
        return;
    }else{//正常使用
        self.needInputName = NO;
        self.userName = name;
        self.userNameLable.stringValue = self.userName;
        self.addressArray = [self.userInfo getAddressArray];
        self.MainVC.userName = self.userName;
        self.MainVC.addressArray = self.addressArray;
        [self.MainVC removeInputUserNameView];
        self.settingPanel.contentViewController = self.settingVC;
        [self initSocketManager];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PersonalInfoViewController_userNameUpdate"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"RefreshAddressViewController_refreshAddress"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"MainViewController_startAction"
                                                  object:nil];
}

- (void)initSocketManager {
    __weak __block typeof(self) weakSelf = self;
    [self.socketManager initSocket];
    
    [self.socketManager connectionStatusDidChanged:^(BOOL isConnected) {
        NSLog(@"___________isConnected: %d", isConnected);
        if (isConnected) {//连接成功
            if (weakSelf.needInputName == YES) {//首次使用存储个人信息
                weakSelf.userName = self.inputName;
                [weakSelf.userInfo setName:self.userName];
                [weakSelf.userInfo setName:weakSelf.userName];
                [weakSelf.userInfo setAddress:weakSelf.socketManager.localHost];
            }
            [weakSelf sendSelfAddressToServer];//发送自己地址给服务器
        }
        [weakSelf updateOnlineOrOfflineWithStauts:isConnected];//更新在线状态UI
    }];
    
    [self.socketManager didReceiveData:^(NSDictionary *dic) {
        NSLog(@"___________didReceiveData: %@", dic);
        if ([dic[@"infoType"] isEqualToString:@"chatToClient"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainWindowController_receiveChatLog" object:@{@"info": dic[@"info"]}];
        }
    }];
    
    [self.socketManager connectToHost:@"192.168.87.195" port:8000];
}

- (void)updateOnlineOrOfflineWithStauts:(BOOL)isConnected {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isConnected) {
            self.onlineItem.state = 1;
            self.offlineItem.state = 0;
            [self.statusButton setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
        }else{
            self.onlineItem.state = 0;
            self.offlineItem.state = 1;
            [self.statusButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
        }
    });
}

//发送自己地址给服务器
- (void)sendSelfAddressToServer {
    if (self.socketManager.isConnected) {
        NSDictionary *info = @{@"infoType": @"searchAddress",
                               @"info": @{@"name": self.userName, @"address": self.socketManager.localHost}};
        [self.socketManager sendDataWithInfo:info];
        if (self.needInputName == YES) {
            [NSThread sleepForTimeInterval:3];
            [self getAllAddresses];
        }
    }
}

//获取所有的地址
- (void)getAllAddresses {
    __weak __block typeof(self) weakSelf = self;
    [self.socketManager getAllAddressCompletion:^(NSMutableArray<NSDictionary *> *addresses) {
        NSLog(@"___________getAllAddressCompletion: %@", addresses);
        weakSelf.addressArray = [NSMutableArray array];
        weakSelf.addressArray = addresses;
        [weakSelf.userInfo setAddressArray:addresses];
        if (_needRefreshAddress == YES) {//重新刷新地址
            _MainVC.addressArray = addresses;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainWindowController_didRefreshAddress" object:nil];
            _needRefreshAddress = NO;
        }
        if (self.needInputName == NO) {
            return;
        }
        self.needInputName = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf removeInputNameView];
        });
    }];
}

#pragma mark - Observer notification

- (void)startActionNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    NSString *name = dic[@"name"];
    self.inputName = name;
    [self initSocketManager];
}

- (void)removeInputNameView {
    self.statusButton.enabled = YES;
    self.settingItem.enabled = YES;
    self.userNameLable.stringValue = self.userName;
    self.MainVC.userName = self.userName;
    self.MainVC.addressArray = [NSMutableArray arrayWithArray:self.addressArray];
    [self.MainVC removeInputUserNameView];
    self.settingPanel.contentViewController = self.settingVC;
}

- (void)userNameUpdateNotification:(NSNotificationCenter *)noti {
    self.userName = [self.userInfo getName];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.userNameLable.stringValue = self.userName;
    });
    [self sendSelfAddressToServer];
}

- (void)refreshAddressNotification:(NSNotification *)noti {
    if (self.socketManager.isConnected) {
        self.needRefreshAddress = YES;
        [self getAllAddresses];
    }else{
        self.needRefreshAddress = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MainWindowController_didRefreshAddress" object:nil];
    }
}

#pragma mark - Actions

- (IBAction)settingItemAction:(NSToolbarItem *)sender {
    NSString *name = [self.userInfo getName];
    if (name == nil) {
        return;
    }
    [self.window beginSheet:self.settingPanel completionHandler:nil];
}

- (IBAction)changeStatusAction:(NSButton *)sender {
    CGPoint location = sender.frame.origin;
    location.x -= 18;
    location.y -= 5;
    [self.ChangeStatusMenu popUpMenuPositioningItem:nil atLocation:location inView:self.userInfoView];
    
}

- (IBAction)onlineItemAction:(NSMenuItem *)sender {
    sender.state = 1;
    self.offlineItem.state = 0;
    [self.statusButton setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
    if (self.socketManager.isConnected) {
        return;
    }
    [self initSocketManager];
}

- (IBAction)offlineItemAction:(NSMenuItem *)sender {
    sender.state = 1;
    self.onlineItem.state = 0;
    [self.statusButton setImage:[NSImage imageNamed:NSImageNameStatusUnavailable]];
    [self.socketManager.socketClient disconnect];
    self.socketManager.socketClient = nil;
}

#pragma mark - Lazy load

- (SocketClientManager *)socketManager {
    if (!_socketManager) {
        _socketManager = [SocketClientManager shareManager];
    }
    return _socketManager;
}

- (UserInfoManager *)userInfo {
    if (!_userInfo) {
        _userInfo = [UserInfoManager shareManager];
    }
    return _userInfo;
}

- (SettingViewController *)settingVC {
    if (!_settingVC) {
        _settingVC = [[SettingViewController alloc] init];
        __block __weak typeof(self) weakSelf = self;
        [_settingVC didClickOkButton:^{
            [weakSelf.window endSheet:self.settingPanel];
            NSLog(@"確定");
        }];
    }
    return _settingVC;
}

@end









