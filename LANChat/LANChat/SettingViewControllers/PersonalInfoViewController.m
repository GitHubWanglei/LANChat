//
//  PersonalInfoViewController.m
//  LANChat
//
//  Created by lihongfeng on 16/12/27.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "PersonalInfoPopover.h"
#import "UserInfoManager.h"
#import "SocketClientManager.h"

@interface PersonalInfoViewController ()

@property (strong) IBOutlet NSTextField *userNameLabel;
@property (strong) IBOutlet NSTextField *addressLabel;
@property (strong) IBOutlet NSButton *lockButton;
@property (nonatomic, strong) NSTextField * userNameTextField;
@property (nonatomic, strong) NSPopover *popover;
@property (strong) IBOutlet NSButton *infoButton;
@property (nonatomic, strong) UserInfoManager *userInfo;

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lockButton.target = self;
    self.lockButton.action = @selector(lockAction:);
    
    UserInfoManager *userInfo = [UserInfoManager shareManager];
    self.userInfo = userInfo;
    self.userNameLabel.stringValue = [userInfo getName];
    self.addressLabel.stringValue = [userInfo getAddress];
    
    [self.view addSubview:self.userNameTextField];
    self.userNameTextField.hidden = YES;
}

#pragma mark - Actions

- (void)lockAction:(NSButton *)btn {
    
    SocketClientManager *manger = [SocketClientManager shareManager];
    if (!manger.isConnected) {
        return;
    }
    
    if (self.userNameTextField.hidden) {
        self.userNameTextField.hidden = NO;
        [self.userNameTextField becomeFirstResponder];
        [self.lockButton setImage:[NSImage imageNamed:NSImageNameLockUnlockedTemplate]];
        self.lockButton.keyEquivalent = @"\r";
    }else{
        NSString *result = [self.userNameTextField.stringValue stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (result.length > 15 || result.length == 0) {
            [self.popover showRelativeToRect:self.userNameTextField.bounds ofView:self.userNameTextField preferredEdge:NSRectEdgeMaxY];
            return;
        }
        self.userNameTextField.hidden = YES;
        [self.lockButton setImage:[NSImage imageNamed:NSImageNameLockLockedTemplate]];
        self.userNameLabel.stringValue = result;
        self.lockButton.keyEquivalent = @"";
        [self.userInfo setName:result];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PersonalInfoViewController_userNameUpdate" object:@{@"name": result}];
        
    }
}

- (IBAction)infoButtonAction:(NSButton *)sender {
    [self.popover showRelativeToRect:sender.bounds ofView:sender preferredEdge:NSRectEdgeMaxX];
}

#pragma mark - Lazy load

- (NSTextField *)userNameTextField {
    if (!_userNameTextField) {
        _userNameTextField = [[NSTextField alloc] initWithFrame:CGRectMake(174, 138, 200, 22)];
        _userNameTextField.stringValue = self.userNameLabel.stringValue;
        _userNameTextField.alignment = NSTextAlignmentCenter;
    }
    return _userNameTextField;
}

- (NSPopover *)popover {
    if (!_popover) {
        _popover = [[NSPopover alloc] init];
        _popover.contentViewController = [[PersonalInfoPopover alloc] init];
        _popover.behavior = NSPopoverBehaviorTransient;
    }
    return _popover;
}

@end










