//
//  CoreDataStack.h
//  DemoProject
//
//  Created by Sergey Marchukov on 30.05.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
#import "Person.h"
#import "Dog.h"


@interface CoreDataStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *coreDataContext;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initStack NS_DESIGNATED_INITIALIZER;
+ (instancetype)stack;

- (void)save;

@end
