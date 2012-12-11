//
//  RWFirstViewController.m
//  iRegex
//
//  Created by Canopus on 12/1/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//


#import "RWFirstViewController.h"

@interface RWFirstViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *lastSearchString;
@property (strong, nonatomic) NSDictionary *lastSearchOptions;
@end

@implementation RWFirstViewController

#pragma mark
#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueIdentifier = segue.identifier;
    if ([segueIdentifier isEqualToString:@"RWSearchViewControllerSegue"])
    {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        RWSearchViewController *controller = [navigationController.viewControllers objectAtIndex:0];
        controller.delegate = self;
        controller.searchString = self.lastSearchString;
        controller.searchOptions = self.lastSearchOptions;
    }
}

#pragma mark
#pragma mark - RWSearchViewController delegate

- (void)controller:(RWSearchViewController *)controller didFinishWithSearchString:(NSString *)string options:(NSDictionary *)options
{
    self.lastSearchString = string;
    self.lastSearchOptions = options;

    if (string)
    {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"\\b%@\\b", string]
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
        
        // If we found somehing
        if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0)))
        {
            // NSString *substringForFirstMatch = [string substringWithRange:rangeOfFirstMatch];
            // Highlight it
            NSMutableAttributedString *mutableAttributedString = self.textView.attributedText.mutableCopy;
            [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:rangeOfFirstMatch];
            
            // Set the attributed string of the text view
            self.textView.attributedText = mutableAttributedString.copy;
        }
    }
}

@end
