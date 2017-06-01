//
//  CoreDataStack.m
//  DemoProject
//
//  Created by Sergey Marchukov on 30.05.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

#import "CoreDataStack.h"


@interface CoreDataStack ()

@property (nonatomic, strong, readwrite) NSManagedObjectContext *coreDataContext;

@end

@implementation CoreDataStack

- (instancetype)initStack {
    self = [super init];
    
    [self setupCoreData];
    
    return self;
}

+ (instancetype)stack {
    return [[CoreDataStack alloc] initStack];
}

- (void)setupCoreData {
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"Model2" withExtension:@"momd"];
    NSManagedObjectModel *coreDataModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:path];
    
    NSPersistentStoreCoordinator *coreDataPSC = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:coreDataModel];
    NSError *err = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationSupportFolder = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
   
    if (![fileManager fileExistsAtPath:applicationSupportFolder.path]) {
        [fileManager createDirectoryAtPath:applicationSupportFolder.path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSURL *url = [applicationSupportFolder URLByAppendingPathComponent:@"db.sqlite"];
    [coreDataPSC addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&err];
    
    self.coreDataContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _coreDataContext.persistentStoreCoordinator = coreDataPSC;
}

- (void)save {
    if (_coreDataContext.hasChanges) {
        NSError *error = nil;
        [_coreDataContext save:&error];
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
}

@end
