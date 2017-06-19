//
//  DetailViewController.m
//  RemindThomas
//
//  Created by Charles Lobo on 15/06/17.
//  Copyright © 2017 The Productive Programmer. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    if(self.reminder) {
        self.name.text = self.reminder.name;
        self.address.text = self.reminder.address;
        self.todos.text = self.reminder.todos;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.address.delegate = self;
    self.todos.delegate = self;
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item (reminders)

- (void)setDetailItem:(Reminder *)newReminder {
    if (_reminder != newReminder) {
        _reminder = newReminder;
        
        // Update the view.
        [self configureView];
    }
}


- (IBAction)nameUpdated:(UITextField *)sender {
    self.reminder.name = self.name.text;
    if(self.delegate) [self.delegate reminderUpdated];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(textView == self.address) {
        self.reminder.address = textView.text;
        if(self.delegate) [self.delegate reminderUpdated];
    }
    if(textView == self.todos) {
        self.reminder.todos = textView.text;
        if(self.delegate) [self.delegate reminderUpdated];
    }
}

@end
