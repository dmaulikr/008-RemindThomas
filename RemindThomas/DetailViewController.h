//
//  DetailViewController.h
//  RemindThomas
//
//  Created by Charles Lobo on 15/06/17.
//  Copyright © 2017 The Productive Programmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"
#import "DetailViewDelegate.h"

@interface DetailViewController : UIViewController <UITextViewDelegate>

@property (weak) id <DetailViewDelegate> delegate;

@property (strong, nonatomic) Reminder *reminder;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *address;
@property (weak, nonatomic) IBOutlet UITextView *todos;
- (IBAction)nameUpdated:(UITextField *)sender;

- (void)textViewDidEndEditing:(UITextView *)textView;

@end

