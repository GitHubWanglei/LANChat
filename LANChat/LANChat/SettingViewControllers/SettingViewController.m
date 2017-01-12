//
//  SettingViewController.m
//  LANChat
//
//  Created by lihongfeng on 16/12/26.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "SettingViewController.h"
#import "PersonalInfoViewController.h"
#import "RefreshAddressViewController.h"

@interface SettingViewController ()

@property (strong) IBOutlet NSTabView *tabView;
@property (nonatomic, strong) void (^okBlock)();
@property (nonatomic, strong) PersonalInfoViewController *personInfoVC;
@property (nonatomic, strong) RefreshAddressViewController *refreshAddressVC;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addContentViews];
    
}

- (void)addContentViews {
    //個人信息
    self.personInfoVC = [[PersonalInfoViewController alloc] init];
    NSTabViewItem *personalItem = [NSTabViewItem tabViewItemWithViewController:self.personInfoVC];
    personalItem.label = @"個人信息";
    [self.tabView addTabViewItem:personalItem];
    
    //刷新地址
    self.refreshAddressVC = [[RefreshAddressViewController alloc] init];
    NSTabViewItem *refreshAddressItem = [NSTabViewItem tabViewItemWithViewController:self.refreshAddressVC];
    refreshAddressItem.label = @"搜尋地址";
    [self.tabView addTabViewItem:refreshAddressItem];
}

#pragma mark - Public methods

- (void)didClickOkButton:(void (^)())ok {
    _okBlock = ok;
}

#pragma mark - Actions

- (IBAction)okAction:(NSButton *)sender {
    if (self.okBlock) {
        self.okBlock();
    }
}

@end
