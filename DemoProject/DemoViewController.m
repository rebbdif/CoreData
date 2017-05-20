//
//  DemoViewController.m
//  DemoProject
//
//  Created by Sergey Marchukov on 16.05.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

#import "DemoViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC, 2 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        
    });
    dispatch_resume(timer);
}

- (void)someMethod {
    
}

@end
