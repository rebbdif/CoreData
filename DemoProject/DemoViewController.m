//
//  DemoViewController.m
//  DemoProject
//
//  Created by Sergey Marchukov on 16.05.17.
//  Copyright © 2017 Sergey Marchukov. All rights reserved.
//

#import "DemoViewController.h"
#import "CoreDataStack.h"


@interface DemoViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, strong) NSFetchedResultsController *fetchResultsController;
@property (nonatomic, strong) UITableView *tableView;

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTableView:)];
    self.navigationItem.title = @"CoreData";

    
    [self frc];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.view.frame;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [self.view addSubview:_tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
   // [self createPerson];
        
    NSLog(@"\nBefore");
    
    Person *lastPerson = [self findPerson].lastObject;
    if (lastPerson) {
     //   [self removePerson:lastPerson];
    }
    
    NSLog(@"\nAfter");

    
    [self findPerson];
}

- (IBAction)editTableView:(id)sender {
    if (!_tableView.editing) {
        [_tableView setEditing:YES animated:YES];
    } else {
        [_tableView setEditing:NO animated:YES];
    }
}

- (IBAction)addPerson:(id)sender {
    [self createPerson];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSArray<Person *> *people = self.fetchResultsController.fetchedObjects;
    Person * currentObject = people[indexPath.row];
    cell.textLabel.text = currentObject.firstName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %hu", currentObject.lastName, currentObject.age];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchResultsController.fetchedObjects.count;
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
        person.age = 10;
        [self->_coreDataStack save];
    }];
}

- (NSArray<Person *> *)findPerson {
    NSError *err;
    NSArray<Person *> *persons = [_coreDataStack.coreDataContext executeFetchRequest:[self fetchRequestForAge:0] error:&err];
    if (err) NSLog(@"%@", err.localizedDescription);
    NSLog(@"%@", persons);
    NSLog(@"%lu",persons.count);
    return persons;
}

- (void)asyncRequest {
    NSError *err;
    NSAsynchronousFetchRequest *asyncRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:[self fetchRequestForAge:0] completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        
    }];
    [_coreDataStack.coreDataContext executeRequest:asyncRequest error:&err];
    NSLog(@"%@", err.localizedDescription);
}

- (NSFetchRequest *)fetchRequestForAge:(NSInteger)age {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"age >= 0"];
    request.fetchBatchSize = 10;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES]];
    return request;
}

- (NSFetchedResultsController *)frc {
    if (_fetchResultsController ) return _fetchResultsController;
    
    _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequestForAge:0] managedObjectContext:_coreDataStack.coreDataContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error = nil;
    
    [_fetchResultsController performFetch:&error];
    _fetchResultsController.delegate = self;

    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    return _fetchResultsController;
}


#pragma mark - fetchResultsControllerDelegate

/* Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update. Enables NSFetchedResultsController change tracking.
controller - controller instance that noticed the change on its fetched objects
anObject - changed object
indexPath - indexPath of changed object (nil for inserts)
type - indicates if the change was an insert, delete, move, or update
newIndexPath - the destination path of changed object (nil for deletes)

Changes are reported with the following heuristics:

Inserts and Deletes are reported when an object is created, destroyed, or changed in such a way that changes whether it matches the fetch request's predicate. Only the Inserted/Deleted object is reported; like inserting/deleting from an array, it's assumed that all objects that come after the affected object shift appropriately.
Move is reported when an object changes in a manner that affects its position in the results.  An update of the object is assumed in this case, no separate update message is sent to the delegate.
Update is reported when an object's state changes, and the changes do not affect the object's position in the results.
*/

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        default:
            break;
    }
}



/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
 Clients may prepare for a batch of updates by using this method to begin an update block for their view.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

/* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
 Clients may prepare for a batch of updates by using this method to begin an update block for their view.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/* Asks the delegate to return the corresponding section index entry for a given section name.	Does not enable NSFetchedResultsController change tracking.
 If this method isn't implemented by the delegate, the default implementation returns the capitalized first letter of the section name (seee NSFetchedResultsController sectionIndexTitleForSectionName:)
 Only needed if a section index is used.
 */

- (nullable NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return nil;
}


@end
