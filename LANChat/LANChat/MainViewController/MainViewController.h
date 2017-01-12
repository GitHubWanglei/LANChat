//
//  MainViewController.h
//  LANChat
//
//  Created by lihongfeng on 16/12/26.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSMutableArray *addressArray;
@property (strong) IBOutlet NSTextField *coutTimeLabel;
@property (strong) IBOutlet NSTextField *countInfoLabel;

- (void)removeInputUserNameView;

@end
