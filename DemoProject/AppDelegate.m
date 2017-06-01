//
//  AppDelegate.m
//  DemoProject
//
//  Created by Sergey Marchukov on 30.03.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoViewController.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    DemoViewController *demoViewController = [DemoViewController new];
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _window.rootViewController = demoViewController;
    
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
