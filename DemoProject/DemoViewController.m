//
//  DemoViewController.m
//  DemoProject
//
//  Created by Sergey Marchukov on 16.05.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

#import "DemoViewController.h"
#import "CoreDataStack.h"


@interface DemoViewController ()

@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultsController;

@end

@implementation DemoViewController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.coreDataStack = [CoreDataStack stack];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPerson];

    NSLog(@"\nBefore");
    
    Person *lastPerson = [self findPerson].lastObject;
    if (lastPerson) {
        [self removePerson:lastPerson];
    }
    
    NSLog(@"\nAfter");
    
    [self findPerson];
}

- (void)removePerson:(Person *)person {
    [_coreDataStack.coreDataContext deleteObject:person];
    [_coreDataStack save];
}

- (void)createPerson {
    [_coreDataStack.coreDataContext performBlock:^{
        Person *person = (id)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self->_coreDataStack.coreDataContext];
        person.firstName = @"Коля";
        person.lastName = @"Иванов";
        person.age = 16;
        [self->_coreDataStack save];
    }];
}

- (NSArray<Person *> *)findPerson {
    NSError *err;
    NSArray<Person *> *persons = [_coreDataStack.coreDataContext executeFetchRequest:[self fetchRequest] error:&err];
    NSLog(@"%@", err.localizedDescription);
    NSLog(@"%@", persons);
    NSLog(@"%lu",persons.count);
    return persons;
}

- (void)asyncRequest {
    NSError *err;
    NSAsynchronousFetchRequest *asyncRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:[self fetchRequest] completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        
    }];
    [_coreDataStack.coreDataContext executeRequest:asyncRequest error:&err];
    NSLog(@"%@", err.localizedDescription);
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"age > 13"];
    request.fetchBatchSize = 10;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    return request;
}


@end
