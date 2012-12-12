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
@property (retain, nonatomic) NSArray *validations;
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

#pragma mark
#pragma mark - View life cycle

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
    
    // Array of regex to validate each field
    self.validations = [NSArray arrayWithObjects:@"^[a-zA-Z]", // First name
                                                 @"", // Middle name
                                                 @"", // Last name
                                                 @"", // Social security number
                                                 @"", // Date of birth
                                                 @"", // Username
                                                 @"", // Password
                                                 @"", // Email address
                                                 nil];
}

#pragma mark
#pragma mark - UITextField delegates

// Called when user taps next button
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Index of current text field
    NSInteger index = [self.textFields indexOfObject:textField];
    
    // Get the validate string and validate the content
    NSString *validationPattern = [self.validations objectAtIndex:index];
    [self validateTextField:textField withPattern:validationPattern];
    
    // Find the next textfield
    if (index < self.textFields.count - 1)
        index ++;
    else
        index = 0;
    
    // The next text field as the next responder
    UITextField *nextResponder = [self.textFields objectAtIndex:index];
    
    // Find the respective (hosting) cell
    // and scroll to that
    UITableViewCell *cell = (UITableViewCell *)nextResponder.superview.superview;
    CGRect cellFrame = cell.frame;
    [self.tableView scrollRectToVisible:cellFrame animated:YES];
    
    // Make it the first responder
    [nextResponder becomeFirstResponder];
    
    return YES;
}

// Called when user taps on clear button
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    // We are going to return YES and clear out
    // but the field is not cleared yet. Because for correct validation
    // icon on the right side of the text field, we need the text field to
    // have a cleat text, so we set it manually to nil.
    textField.text = nil;
    
    // Validate
    [self validateTextField:textField];
    
    return YES;
}

// Called when user taps on a different text field and
// this text field resigns
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Validate
    [self validateTextField:textField];
}

#pragma mark
#pragma mark - Validation

- (void)validateTextField:(UITextField *)textField
{
    // Index of current text field
    NSInteger index = [self.textFields indexOfObject:textField];
    
    // Get the validate string and validate the content
    NSString *validationPattern = [self.validations objectAtIndex:index];
    [self validateTextField:textField withPattern:validationPattern];
}

- (void)validateTextField:(UITextField *)textField withPattern:(NSString *)pattern
{
    NSString *text = textField.text;
    UIImageView *rightView = (UIImageView *)textField.rightView;
    
    // If user completely deletes a field, we don't want to display anything
    if (!text.length)
    {
        rightView = nil;
        textField.rightViewMode = UITextFieldViewModeNever;
    }
    else
    {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (!regex)
        {
            NSAssert(FALSE, @"Unable to create regular expression");
        }
        
        NSRange textRange = NSMakeRange(0, text.length);
        NSRange matchRange = [regex rangeOfFirstMatchInString:text options:0 range:textRange];
        
        if (!rightView)
        {
            rightView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
            textField.rightView = rightView;
            CGRect frame = [textField rightViewRectForBounds:rightView.bounds];
            rightView.frame = frame;
        }
        
        // Did it validate?
        if (matchRange.location == NSNotFound)
        {
            rightView.image = [UIImage imageNamed:@"exclamation.png"];
            textField.rightViewMode = UITextFieldViewModeUnlessEditing;
        }
        else
        {
            rightView.image = [UIImage imageNamed:@"checkmark.png"];
            textField.rightViewMode = UITextFieldViewModeUnlessEditing;
        }
    }
}

@end
