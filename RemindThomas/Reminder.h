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

/**
 * [...] The region requires a unique name
 * across the application. As we don't have
 * any unique name we use this id.
 * We expect the creator to ensure that
 * the id is unique (and provide a helper
 * method `maxId` to help return a unique
 * id (maxId +1))
 */
@property (readonly) NSNumber* unique_id;
+ (long)maxId:(NSArray*)reminders;

@property NSString* name;
@property NSString* address;
@property NSString* todos;

@property CLRegion* region;

- (int)numberOfTodos;
- (BOOL)containsLocation:(CLLocation*)location;

@end

#endif /* Reminder_h */
