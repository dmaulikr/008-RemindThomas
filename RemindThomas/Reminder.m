//
//  Reminder.m
//  RemindThomas
//
//  Created by Charles Lobo on 16/06/17.
//  Copyright © 2017 The Productive Programmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Reminder.h"

@implementation Reminder

- (id)initWithLocation:(CLLocation*)location andId:(long)id {
    if ((self = [super init])) {
        [self setAddressFrom:location];
        NSString *identifier = [NSString stringWithFormat:@"region-%ld", id];
        self.region = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:5.0 identifier:identifier];
        self.region.notifyOnEntry = YES;
        self.region.notifyOnExit = YES;
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super init])) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.todos = [aDecoder decodeObjectForKey:@"todos"];
        self.region = [aDecoder decodeObjectForKey:@"region"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.todos forKey:@"todos"];
    [aCoder encodeObject:self.region forKey:@"region"];
}

#pragma mark - Helper functions

/**
 [=] Return the number of TODOS
 [+] If the todo's are empty
     it's zero
 [+] Otherwise count the number
     of transitions from newlines
     to non-newlines (each is a TODO)
 [+...]
    - Do X
    - Do Y
    (blank)
    - Do Z
    = should result in 3 todo's
  [ ] Start in state - INNEWLINE
  [ ] When we find a non-newline
      character, update state to
      NOTINNEWLINE and increment
      number of TODO's.
  */
- (int)numberOfTodos {
    if (!self.todos) return 0;

    int NOTINNEWLINE = 1;
    int INNEWLINE = 2;
    int state = INNEWLINE;
    int numtodos = 0;
    
    // get all characters to iterate
    unichar characters[self.todos.length * sizeof(unichar)];
    [self.todos getCharacters:characters];
    for(int i = 0;i < self.todos.length;i++) {
        if([[NSCharacterSet newlineCharacterSet] characterIsMember:characters[i]]) {
            state = INNEWLINE;
        } else {
            if(state == INNEWLINE) {
                numtodos++;
                state = NOTINNEWLINE;
            }
        }
    }
    return numtodos;
}

- (void)setAddressFrom:(CLLocation*)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error) return;
        CLPlacemark *place = [placemarks firstObject];
        self.address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",
                        place.name ? place.name : @"",
                        place.locality ? place.locality : @"",
                        place.country ? place.country : @"",
                        place.postalCode ? place.postalCode : @""
                        ];
    }];
}

@end
