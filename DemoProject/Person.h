//
//  Person.h
//  DemoProject
//
//  Created by Sergey Marchukov on 30.05.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

@import CoreData;

@class Dog;

@interface Person : NSManagedObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic) uint16_t age;

@property (nonatomic, strong) Dog *dog;

@end
