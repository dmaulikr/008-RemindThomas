//
//  Reminder.h
//  RemindThomas
//
//  Created by Charles Lobo on 16/06/17.
//  Copyright © 2017 The Productive Programmer. All rights reserved.
//

#ifndef Reminder_h
#define Reminder_h

#include <CoreLocation/CoreLocation.h>

@interface Reminder : NSObject <NSCoding>

- (id)initWithLocation:(CLLocation*)location andId:(long)id;

@property NSString* name;
@property NSString* address;
@property NSString* todos;

@property CLRegion* region;

- (int)numberOfTodos;

@end

#endif /* Reminder_h */
