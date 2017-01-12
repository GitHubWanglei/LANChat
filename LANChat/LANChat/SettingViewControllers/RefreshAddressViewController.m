//
//  RefreshAddressViewController.m
//  LANChat
//
//  Created by lihongfeng on 16/12/26.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "RefreshAddressViewController.h"
#import "SearchAddressManager.h"
#import "UserInfoManager.h"

@interface RefreshAddressViewController ()<NSTableViewDelegate, NSTableViewDataSource>

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSButton *refreshButton;
@property (nonatomic, strong) NSView *refreshMaskView;
@property (nonatomic, strong) UserInfoManager *userInfo;

@end

@implementation RefreshAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRefreshNotification:)
                                                 name:@"MainWindowController_didRefreshAddress"
                                               object:nil];
    
    self.userInfo = [UserInfoManager shareManager];
    self.tableView.allowsColumnReordering = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.refusesFirstResponder = YES;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"MainWindowController_didRefreshAddress"
                                                  object:nil];
}

- (void)didRefreshNotification:(NSNotification *)noti {
    self.addressArray = [self.userInfo getAddressArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self removeRefreshMaskView];
    });
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.addressArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *rowInfoDic = self.addressArray[row];
    NSString *rowData = rowInfoDic[tableColumn.identifier];
    return rowData;
}

#pragma mark - Actions

- (IBAction)refreshAction:(NSButton *)sender {
    if (self.refreshButton.enabled) {
        self.addressArray = [NSMutableArray array];
        [self.tableView reloadData];
        [self.view addSubview:self.refreshMaskView];
        self.refreshButton.enabled = NO;
        //get all addresses notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAddressViewController_refreshAddress" object:nil userInfo:nil];
    }
}

- (void)removeRefreshMaskView {
    [self.refreshMaskView removeFromSuperview];
    self.refreshButton.enabled = YES;
}

#pragma mark - Lazy load

- (NSView *)refreshMaskView {
    if (!_refreshMaskView) {
        _refreshMaskView = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 492, 189)];
        _refreshMaskView.wantsLayer = YES;
        _refreshMaskView.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.7].CGColor;
        NSProgressIndicator * indicator =[[NSProgressIndicator alloc] initWithFrame:CGRectMake((492-40)/2.0f, (189-40)/2.0f, 40, 40)];
        indicator.style = NSProgressIndicatorSpinningStyle;
        [indicator startAnimation:indicator];
        [_refreshMaskView addSubview:indicator];
    }
    return _refreshMaskView;
}

@end









