//
//  Dog.h
//  DemoProject
//
//  Created by Sergey Marchukov on 30.05.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Person;

@interface Dog : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSSet<Person *> *persons;

@end
