//
//  MainViewController.m
//  LANChat
//
//  Created by lihongfeng on 16/12/26.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "MainViewController.h"
#import "Masonry.h"
#import "LeftVC.h"
#import "RightVC.h"

@interface MainViewController ()

@property (nonatomic, strong) NSSplitView *splitView;
@property (nonatomic, strong) LeftVC *leftVC;
@property (nonatomic, strong) RightVC *rightVC;

@property (strong) IBOutlet NSView *inputUserNameView;
@property (strong) IBOutlet NSTextField *userNameTextField;
@property (strong) IBOutlet NSButton *startButton;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.progressIndicator.hidden = YES;
    self.coutTimeLabel.hidden = YES;
    self.countInfoLabel.hidden = YES;
    [self.progressIndicator startAnimation:self];
    self.inputUserNameView.wantsLayer = YES;
    self.inputUserNameView.layer.backgroundColor = [NSColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1].CGColor;
    
    if (self.userName.length > 0) {
        [self addSubView];
        [self removeInputUserNameView];
    }
    
}

- (void)addSubView {
    [self.splitView addSubview:self.leftVC.view];
    [self.splitView addSubview:self.rightVC.view];
    [self.view addSubview:self.splitView];
    
    [self.leftVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.greaterThanOrEqualTo(@(150));
        make.width.lessThanOrEqualTo(@(151));
    }];
    [self.rightVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.greaterThanOrEqualTo(@(649));
        make.width.lessThanOrEqualTo(@(650));
    }];
}

- (void)setAddressArray:(NSMutableArray *)addressArray {
    _addressArray = addressArray;
    self.leftVC.addressArray = addressArray;
}

#pragma mark - Public methods

- (void)removeInputUserNameView {
    if (self.inputUserNameView) {
        [self.inputUserNameView removeFromSuperview];
        [self addSubView];
        [self.leftVC reloadView];
    }
}

#pragma mark - Actions

- (IBAction)startAction:(NSButton *)sender {
    NSString *name = [self.userNameTextField.stringValue stringByReplacingOccurrencesOfString:@"" withString:@""];
    if (name.length == 0 || name.length > 15) {
        return;
    }
    [self.startButton removeFromSuperview];
    self.progressIndicator.hidden = NO;
    self.userNameTextField.enabled = NO;
    self.coutTimeLabel.hidden = NO;
    self.countInfoLabel.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainViewController_startAction" object:@{@"name": name}];
}

#pragma mark - Lazy load

- (NSSplitView *)splitView {
    if (!_splitView) {
        _splitView = [[NSSplitView alloc] initWithFrame:self.view.bounds];
        _splitView.vertical = YES;
        _splitView.dividerStyle = NSSplitViewDividerStyleThin;
    }
    return _splitView;
}

- (LeftVC *)leftVC {
    if (!_leftVC) {
        _leftVC = [[LeftVC alloc] init];
        _leftVC.view.autoresizingMask = 0;
        _leftVC.view.autoresizesSubviews = YES;
        _leftVC.addressArray = [NSMutableArray arrayWithArray:self.addressArray];
    }
    return _leftVC;
}

- (RightVC *)rightVC {
    if (!_rightVC) {
        _rightVC = [[RightVC alloc] init];
        _rightVC.view.autoresizingMask = 0;
        _rightVC.view.autoresizesSubviews = YES;
    }
    return _rightVC;
}


@end
