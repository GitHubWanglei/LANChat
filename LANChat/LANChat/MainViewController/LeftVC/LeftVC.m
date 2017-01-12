//
//  LeftVC.m
//  LANChat
//
//  Created by lihongfeng on 16/12/28.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "LeftVC.h"
#import "LeftVCTableRowView.h"
#import "cellInfoModel.h"
#import "UserInfoManager.h"

@interface LeftVC ()<NSTableViewDelegate, NSTableViewDataSource>

@property (strong) IBOutlet NSScrollView *scrollView;
@property (strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UserInfoManager *userInfo;
@property (nonatomic, assign) NSInteger selectedRowIndex;

@end

@implementation LeftVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userNameUpdateNotification:)
                                                 name:@"PersonalInfoViewController_userNameUpdate"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRefreshNotification:)
                                                 name:@"MainWindowController_didRefreshAddress"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chatLogChangedNotification:)
                                                 name:@"RightVC_childVC_chatLogsChanged"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveChatLog:)
                                                 name:@"MainWindowController_receiveChatLog"
                                               object:nil];
    
    self.userInfo = [UserInfoManager shareManager];
    self.scrollView.borderType = NSNoBorder;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1].CGColor;
    self.selectedRowIndex = -1;
    
//    [self getTestData];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.addressArray = [self.userInfo getAddressArray];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"PersonalInfoViewController_userNameUpdate"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"MainWindowController_didRefreshAddress"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"RightVC_childVC_chatLogsChanged"
                                                  object:nil];
}

- (void)userNameUpdateNotification:(NSNotification *)noti {
    
    for (cellInfoModel *model in self.dataSource) {
        if ([model.address isEqualToString:[self.userInfo getAddress]]) {
            [self.dataSource removeObject:model];
        }
    }
    
    for (NSDictionary *dic in self.addressArray) {
        if ([dic[@"address"] isEqualToString:[self.userInfo getAddress]]) {
            NSDictionary *newDic = @{@"name": [self.userInfo getName], @"address": [self.userInfo getAddress]};
            [self.addressArray removeObject:dic];
            [self.addressArray insertObject:newDic atIndex:0];
            for (NSDictionary *dic in _addressArray) {
                cellInfoModel *model = [[cellInfoModel alloc] init];
                model.name = dic[@"name"];
                model.address = dic[@"address"];
                [self.dataSource addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            break;
        }
    }
}

- (void)didRefreshNotification:(NSNotification *)noti {
    self.addressArray = [self.userInfo getAddressArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)chatLogChangedNotification:(NSNotification *)noti {
    NSDictionary *info = noti.object;
    NSString *address = info[@"address"];
    for (cellInfoModel *model in self.dataSource) {
        if ([model.address isEqualToString:address]) {
            model.chatLogs = info[@"chatLog"];
            break;
        }
    }
}

- (void)receiveChatLog:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    NSLog(@"chatLogs: %@", dic);
    NSDictionary *info = dic[@"info"];
    NSString *fromAddress = info[@"fromAddress"];
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        cellInfoModel *model = self.dataSource[i];
        if ([fromAddress isEqualToString:model.address]) {
            model.chatLogs = [model.chatLogs stringByAppendingString:info[@"chatString"]];
            model.hasNewMessage = YES;
            if (self.selectedRowIndex != i) {
                [self reloadView];
            }
            break;
        }
    }
}

- (void)reloadView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)getTestData {
    cellInfoModel *model1 = [[cellInfoModel alloc] init];
    model1.name = @"John";
    model1.address = @"192.168.87.195";
    cellInfoModel *model2 = [[cellInfoModel alloc] init];
    model2.name = @"Jack";
    model2.address = @"192.168.87.182";
    cellInfoModel *model3 = [[cellInfoModel alloc] init];
    model3.name = @"Tom";
    model3.address = @"192.168.87.167";
    self.dataSource = [NSMutableArray arrayWithArray:@[model1, model2, model3]];
}

- (void)setAddressArray:(NSMutableArray *)addressArray {
    _addressArray = addressArray;
    self.dataSource = [NSMutableArray array];
    for (NSDictionary *dic in _addressArray) {
        cellInfoModel *model = [[cellInfoModel alloc] init];
        model.name = dic[@"name"];
        model.address = dic[@"address"];
        model.hasNewMessage = NO;
        [self.dataSource addObject:model];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    cellInfoModel *model = self.dataSource[row];
    NSString *name = model.name;
    NSString *address = model.address;
    BOOL hasNewMessage = model.hasNewMessage;
    
    //get tableCellView
    NSTableCellView *contentView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    contentView.frame = CGRectMake(1, 1, self.view.bounds.size.width, 60);
    //name label
    NSTextField *nameLabel = [contentView viewWithTag:10000];
    if (!nameLabel) {
        nameLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 60-30, contentView.bounds.size.width - 10, 25)];
    }
    nameLabel.stringValue = name;
    nameLabel.font = [NSFont systemFontOfSize:14];
    nameLabel.bordered = NO;
    nameLabel.editable = NO;
    nameLabel.textColor = [NSColor colorWithRed:1/255.0 green:1/255.0 blue:1/255.0 alpha:1];
    nameLabel.backgroundColor = [NSColor clearColor];
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    nameLabel.maximumNumberOfLines = 1;
    nameLabel.tag = 10000;
    //address label
    NSTextField *addressLabel = [contentView viewWithTag:10001];
    if (!addressLabel) {
        addressLabel = [[NSTextField alloc] initWithFrame:CGRectMake(10, 60-(30 + 20), contentView.bounds.size.width - 10, 20)];
    }
    addressLabel.stringValue = address;
    addressLabel.font = [NSFont systemFontOfSize:12];
    addressLabel.bordered = NO;
    addressLabel.editable = NO;
    addressLabel.textColor = [NSColor grayColor];
    addressLabel.backgroundColor = [NSColor clearColor];
    addressLabel.tag = 10001;
    
    if (hasNewMessage) {
        NSTextField *messageLabel = [contentView viewWithTag:10002];
        if (!messageLabel) {
            messageLabel = [[NSTextField alloc] initWithFrame:CGRectMake(contentView.bounds.size.width - 25, 60-20, 20, 13)];
        }
        messageLabel.stringValue = address;
        messageLabel.font = [NSFont systemFontOfSize:12];
        messageLabel.bordered = NO;
        messageLabel.editable = NO;
        messageLabel.textColor = [NSColor whiteColor];
        messageLabel.backgroundColor = [NSColor lightGrayColor];
        messageLabel.tag = 10002;
        messageLabel.stringValue = @"⋯";
        messageLabel.alignment = NSTextAlignmentCenter;
        messageLabel.wantsLayer = YES;
        messageLabel.layer.cornerRadius = 6;
        [contentView addSubview:messageLabel];
    }else{
        NSTextField *messageLabel = [contentView viewWithTag:10002];
        if (messageLabel) {
            [messageLabel removeFromSuperview];
        }
    }
    
    [contentView addSubview:nameLabel];
    [contentView addSubview:addressLabel];
    
    return contentView;
}

#pragma mark - NSTableViewDelegate

//客製化 rowView
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    LeftVCTableRowView *rowView = [tableView makeViewWithIdentifier:@"rowView" owner:self];
    if (rowView == nil) {
        rowView = [[LeftVCTableRowView alloc] init];
        rowView.identifier = @"rowView";
    }
    return rowView;
}

#pragma mark ***** Notifications *****
//鼠标左键选中调用
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger rowIndex = [notification.object selectedRow];
    if (rowIndex >= 0) {
        cellInfoModel *model = self.dataSource[rowIndex];
        NSDictionary *obj = @{@"rowIndex": @(rowIndex), @"info": model};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftVC_didSelectRow" object:obj];
        //去掉消息 label
        if (model.hasNewMessage) {
            model.hasNewMessage = NO;
            [self reloadView];
            [self.tableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rowIndex] byExtendingSelection:YES];
        }
    }else{
        NSDictionary *info = @{@"rowIndex": @(rowIndex)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftVC_didSelectRow" object:info];
    }
    self.selectedRowIndex = rowIndex;
}

@end




