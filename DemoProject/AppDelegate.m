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
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:demoViewController];

    _window.rootViewController = nc;
    
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
