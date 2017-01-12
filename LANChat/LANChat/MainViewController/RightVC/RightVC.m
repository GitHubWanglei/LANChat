//
//  RightVC.m
//  LANChat
//
//  Created by lihongfeng on 16/12/28.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "RightVC.h"
#import "RightVC_childVC.h"

@interface RightVC ()

@property (strong) IBOutlet NSView *iconMaskView;
@property (nonatomic, strong) RightVC_childVC *childVC;

@end

@implementation RightVC

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.childVC.view.hidden = YES;
    self.childVC.view.wantsLayer = YES;
    self.childVC.view.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    self.childVC.view.frame = CGRectMake(0, 0, 650, 560);
    [self.view addSubview:self.childVC.view];
    
//    NSLog(@"frame: %@", NSStringFromRect(self.view.frame));
    [self addObserver];
}

- (void)dealloc {
    [self removeObserver];
}

#pragma mark - Observer selected row

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelctedRowNotification:)
                                                 name:@"LeftVC_didSelectRow"
                                               object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"LeftVC_didSelectRow"
                                                  object:nil];
}

- (void)didSelctedRowNotification:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    NSInteger rowIndex = [(NSNumber *)dic[@"rowIndex"] integerValue];
    NSLog(@"----------selected row %ld", rowIndex);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iconMaskView.hidden = (rowIndex >= 0) ? YES : NO;
        self.childVC.view.hidden = (rowIndex >= 0) ? NO : YES;
    });
}

#pragma mark - Lazy load

- (RightVC_childVC *)childVC {
    if (!_childVC) {
        _childVC = [[RightVC_childVC alloc] init];
        _childVC.view.autoresizingMask = 0;
        _childVC.view.autoresizesSubviews = YES;
        _childVC.view.frame = self.view.bounds;
    }
    return _childVC;
}


@end















