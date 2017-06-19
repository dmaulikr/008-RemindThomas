//
//  MasterViewController.m
//  RemindThomas
//
//  Created by Charles Lobo on 15/06/17.
//  Copyright © 2017 The Productive Programmer. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property CLLocation* latestLocation;

@property NSMutableArray *objects;

@property (strong) CLLocationManager* locationManager;

@property UIAlertController *delayMsgBox;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(findLocationAndCreateReminder:)];
    self.navigationItem.rightBarButtonItem = addButton;
    /* TODO: Why is this set? */
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    
    self.delayMsgBox = [UIAlertController alertControllerWithTitle:@"Please Wait" message:@"Getting Location" preferredStyle:UIAlertControllerStyleAlert];
}

- (void)setupLocationManager {
    /* Store a strong reference to locationManger as required */
    self.locationManager = [[CLLocationManager alloc] init];
    
    /* Request a good accuracy - this is the most expensive
     but should give us the best results */
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    /* Handle location callbacks */
    self.locationManager.delegate = self;
}

- (void)requestPermissions {
    
    /* Ensure we have user permissions to access location services */
    [self setupLocationManager];
    [self.locationManager requestWhenInUseAuthorization];
    
    /* Ensure we have user permissions to set notifications */
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(!granted) {
            /* TODO: show user error */
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)findLocationAndCreateReminder:(id)sender {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        /* we need the current location so we will request
         it. However, the Location Manager gives us multiple
         callbacks (with increasing accuracy?) so we should
         let it "stabilize" for a few seconds.
         While it is stabilizing, we need to indicate to
         the user that something is going on. So we will
         show an alert box and then dismiss it */
        [self.locationManager requestLocation];
        [self showDelayMsg];
        [self performSelector:@selector(insertNewReminder) withObject:self afterDelay:3];
    } else {
        /* TODO: show user error message */
    }
}

- (void)showDelayMsg {
    [self presentViewController:self.delayMsgBox animated:YES completion:nil];
}

- (void)dismissDelayMsg {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)insertNewReminder {
    [self dismissDelayMsg];
    [self insertNewReminderWithLocation:self.latestLocation];
}

- (void)insertNewReminderWithLocation:(CLLocation*)location {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self addNewReminderWithLocation:location];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

# pragma mark - Reminder Management

- (void)addNewReminderWithLocation:(CLLocation*)location {
    Reminder *reminder = [[Reminder alloc] initWithLocation:location andId:self.objects.count];
    [self.objects insertObject:reminder atIndex:0];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Reminder *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setReminder:object];
        controller.delegate = self;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Reminder *reminder = self.objects[indexPath.row];
    cell.textLabel.text = reminder.name ? reminder.name : @"(No Name)";
    cell.detailTextLabel.text = [self getNumberOfTodosMsg:[reminder numberOfTodos]];
    return cell;
}

- (NSString*)getNumberOfTodosMsg:(int)numberOfTodos {
    if(numberOfTodos == 0) return @"(no reminders)";
    if(numberOfTodos == 1) return @"(1 reminder)";
    return [NSString stringWithFormat:@"(%d reminders)", numberOfTodos];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setupLocationNotifications];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark - DetailViewDelegate

- (void)reminderUpdated {
    [self.tableView reloadData];
    [self setupLocationNotifications];
}

- (void)setupLocationNotifications {
    [self removeAllPendingNotifications];
    for(Reminder *reminder in self.objects) {
        [self addNotificationFor:reminder];
    }
}

- (void)removeAllPendingNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
}

- (void)addNotificationFor:(Reminder*)reminder {
    if([reminder numberOfTodos] > 0) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"Remind Thomas";
        content.body = reminder.todos;
        
        UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger
                                                 triggerWithRegion:reminder.region repeats:YES];

        UNNotificationRequest *request = [UNNotificationRequest
                                          requestWithIdentifier:reminder.region.identifier
                                          content:content trigger:trigger];
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if(error) {
                /* TODO report error */
            }
        }];
    }
}

#pragma mark - Load/Save data

- (void)saveData {
    NSString *appDataFile = [self appDataFilePath];
    [NSKeyedArchiver archiveRootObject:self.objects toFile:appDataFile];
    /* TODO: I've just put this call here to sync notification
       as I am paranoid. This is poor design */
    [self setupLocationNotifications];
}

- (void)loadData {
    NSString *appDataFile = [self appDataFilePath];
    self.objects = [NSKeyedUnarchiver unarchiveObjectWithFile:appDataFile];
}

- (NSString*)appDataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [paths lastObject];
    return [documentDir stringByAppendingPathComponent:@"appData"];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    for(CLLocation *location in locations) {
        if(!self.latestLocation ||
           [self.latestLocation.timestamp compare:location.timestamp] == NSOrderedAscending) {
            self.latestLocation = location;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    /* TODO: show error to user */
}

@end
