//
//  RWSearchViewController.m
//  iRegex
//
//  Created by Canopus on 12/10/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "RWSearchViewController.h"


@interface RWSearchViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) NSMutableDictionary *options;
@end

@implementation RWSearchViewController

#pragma mark
#pragma mark - View life cycle

- (void)viewDidLoad
{
    self.searchTextField.text = self.searchString;
    if (!self.searchString)
    {
        // Pop the keyboard if there is no previous search string
        [self.searchTextField becomeFirstResponder];
    }
    self.options = self.searchOptions.mutableCopy;
    
    // Dismiss the keyboard if user double taps on the background
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimissKeyboard:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
    
    [super viewDidLoad];
}

#pragma mark
#pragma mark - IBActions

- (IBAction)closeButtonTapped:(id)sender
{
    self.searchOptions = self.options.copy;
    
    // Notify the delegate
    [self.delegate controller:self didFinishWithSearchString:self.searchString options:self.searchOptions];
    
    // Dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)caseInsensitiveSearchSwitchToggled:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    NSNumber *isCaseInsensitive = [NSNumber numberWithBool:theSwitch.isOn];
    [self.options setObject:isCaseInsensitive forKey:kRWSearchCaseInsensitiveKey];
}


- (IBAction)matchWordSwitchToggled:(id)sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    NSNumber *isMatchWord = [NSNumber numberWithBool:theSwitch.isOn];
    [self.options setObject:isMatchWord forKey:kRWSearchMatchWordKey];
}


- (IBAction)dimissKeyboard:(id)sender
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark
#pragma mark - UITextField delegates


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.searchString = textField.text;
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Dismiss the keyboard
    [textField resignFirstResponder];
    
    // Dimiss the view controller
    [self closeButtonTapped:nil];
    return YES;
}
@end
