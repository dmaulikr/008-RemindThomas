//
//  MasterViewController.h
//  RemindThomas
//
//  Created by Charles Lobo on 15/06/17.
//  Copyright © 2017 The Productive Programmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DetailViewDelegate.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <DetailViewDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

- (void)reminderUpdated;
- (void)loadData;
- (void)saveData;

- (void)requestPermissions;

@end

