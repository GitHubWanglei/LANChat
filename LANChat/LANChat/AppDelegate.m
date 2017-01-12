//
//  AppDelegate.m
//  LANChat
//
//  Created by lihongfeng on 16/12/26.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()

@property (nonatomic, strong) MainWindowController *mainWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.mainWindowController showWindow:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (MainWindowController *)mainWindowController {
    if (!_mainWindowController) {
        _mainWindowController = [[MainWindowController alloc] init];
    }
    return _mainWindowController;
}


@end
