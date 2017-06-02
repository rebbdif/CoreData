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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    self.navigationItem.title = @"CoreData";
    
    [self frc];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame = self.view.frame;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [self.view addSubview:_tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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

#pragma mark - TableView DataSource and Delegate

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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Person *deletedPerson = _fetchResultsController.fetchedObjects[indexPath.row];
    [self removePerson:deletedPerson];
}

#pragma mark - tableViewEditing

- (IBAction)editButtonPressed:(id)sender {
    if (!_tableView.editing) {
        [_tableView setEditing:YES animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    } else {
        [_tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    [_tableView setEditing:NO animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
}

- (IBAction)addButtonPressed:(id)sender {
    UIAlertController *addPersonAlert = [UIAlertController alertControllerWithTitle:@"Добавление человека" message:@"Введите данные" preferredStyle:UIAlertControllerStyleAlert];
    [addPersonAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Имя";
    }];
    [addPersonAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @" Фамилия";
    }];
    [addPersonAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Возраст";
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Готово" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *info = @{@"firstName" : addPersonAlert.textFields[0].text,
                               @"secondName" : addPersonAlert.textFields[1].text,
                               @"age" : addPersonAlert.textFields[2].text};
        [self createPerson:info];
    }];
    [addPersonAlert addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отмена" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [addPersonAlert addAction:cancelAction];
    
    [self presentViewController:addPersonAlert animated:YES completion:nil];
}


#pragma mark - Logic

- (void)removePerson:(Person *)person {
    [_coreDataStack.coreDataContext deleteObject:person];
    [_coreDataStack save];
}

- (void)createPerson:(NSDictionary *)info {
    [_coreDataStack.coreDataContext performBlock:^{
        Person *person = (id)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self->_coreDataStack.coreDataContext];
        person.firstName = info[@"firstName"];
        person.lastName = info[@"lastName"];
        person.age = [info[@"age"] integerValue];
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

#pragma mark - fetchResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        default:
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
