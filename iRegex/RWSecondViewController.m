//
//  RWSecondViewController.m
//  iRegex
//
//  Created by Canopus on 12/1/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "RWSecondViewController.h"

@interface RWSecondViewController () <UITextFieldDelegate>
@property (strong, nonatomic) NSArray *textFields;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *middleInitialTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *socialSecurityNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@end

@implementation RWSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Keep an array of text field to make it
    // first responder upon tapping on next button
	self.textFields = [NSArray arrayWithObjects:self.firstNameTextField,
                                                self.middleInitialTextField,
                                                self.lastNameTextField,
                                                self.socialSecurityNumberTextField,
                                                self.dateOfBirthTextField,
                                                self.usernameTextField,
                                                self.passwordTextField,
                                                self.emailTextField,
                                                nil];
}

#pragma mark
#pragma mark - UITextField delegates


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    // Find the next textfield
    NSInteger index = [self.textFields indexOfObject:textField];
    if (index < self.textFields.count - 1)
        index ++;
    else
        index = 0;
    UITextField *nextResponder = [self.textFields objectAtIndex:index];
    
    // Find the respective (hosting) cell
    // and scroll to that
    UITableViewCell *cell = (UITableViewCell *)nextResponder.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    // Make it the first responder
    [nextResponder becomeFirstResponder];
    
    return YES;
}

@end
