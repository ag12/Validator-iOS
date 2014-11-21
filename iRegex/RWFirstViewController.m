//
//  RWFirstViewController.m
//  iRegex
//
//  Created by Canopus on 12/1/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//


#import "RWFirstViewController.h"
#import "AMValidator.h"

@interface RWFirstViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (strong, nonatomic) NSString *lastSearchString;
@property (strong, nonatomic) NSString *lastReplacementString;
@property (strong, nonatomic) NSDictionary *lastSearchOptions;
@end


@implementation RWFirstViewController


#pragma mark
#pragma mark - View life cycle

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
        controller.replacementString = self.lastReplacementString;
    }
}

#pragma mark
#pragma mark - IBActions

- (IBAction)findInterestingData:(id)sender
{
    [self underlineAllDates];
    [self underlineAllTimes];
    [self underlineAllLocations];
}

#pragma mark
#pragma mark - RWSearchViewController delegate

- (void)controller:(RWSearchViewController *)controller didFinishWithSearchString:(NSString *)string options:(NSDictionary *)options replacement:(NSString *)replacement
{
    if (![string isEqualToString:self.lastSearchString] ||
        ![options isEqual:self.lastSearchOptions] ||
        ![replacement isEqualToString:self.lastReplacementString])
    {
        // Keep a reference
        self.lastSearchString = string;
        self.lastReplacementString = replacement;
        self.lastSearchOptions = options;
        
        // Do a clean up of the last time. Remove all the highlights
        [self removeAllHighlightedTextInTextView:self.textView];
        
        if (replacement)
            // Start search and replace
            [self searchAndReplaceText:string withText:replacement inTextView:self.textView options:options];
        else
            // Start the search
            [self searchText:string inTextView:self.textView options:options];
    }
}

#pragma mark
#pragma mark - Manage search to find and replace

// Search for a searchString in the given text view with search options
- (void)searchText:(NSString *)searchString inTextView:(UITextView *)textView options:(NSDictionary *)options
{
    // TODO: To be implemented from tutorial.
    NSLog(@"SEARCH");

    NSRange range = [self visibleRangeOfTextView:self.textView];


    NSMutableAttributedString *visibleAttributedText = [textView.attributedText attributedSubstringFromRange:range].mutableCopy;

    NSString *visibleText = visibleAttributedText.string;

    NSRange visibleRange = NSMakeRange(0, visibleText.length);

    NSRegularExpression *regex = [self regularExpressionWithString:searchString options:options];

    //IMP
    NSArray *matches = [regex matchesInString:visibleText options:NSMatchingProgress range:visibleRange];

    for (NSTextCheckingResult *match in matches) {
        NSRange range = match.range;
        [visibleAttributedText addAttribute:NSBackgroundColorAttributeName value:[UIColor greenColor] range:range];
    }

    CFRange visibleRange_CF = CFRangeMake(visibleRange.location, visibleRange.length);

    NSMutableAttributedString *textViewAttri = self.textView.attributedText.mutableCopy;

    CFAttributedStringReplaceAttributedString((__bridge CFMutableAttributedStringRef)
                                              (textViewAttri), visibleRange_CF, (__bridge CFAttributedStringRef)(visibleAttributedText));

    textView.attributedText = textViewAttri;

}

// Search for a searchString and replace it with the replacementString in the given text view with search options
- (void)searchAndReplaceText:(NSString *)searchString withText:(NSString *)replacementString inTextView:(UITextView *)textView options:(NSDictionary *)options
{
    NSLog(@"REPLACE");

    NSString *beforeText = textView.text;
    NSRange range = NSMakeRange(0, beforeText.length);

    NSRegularExpression *regex = [self regularExpressionWithString:searchString options:options];

    //IMP
    NSString *afterText = [regex stringByReplacingMatchesInString:beforeText options:0 range:range withTemplate:replacementString];

    textView.text = afterText;


}

#pragma mark
#pragma mark - Helper methods

// Create a regular expression with given string and options
- (NSRegularExpression *)regularExpressionWithString:(NSString *)string options:(NSDictionary *)options
{
    return [AMValidator regularExpressionWithString:string options:options];
}

// Return range of text in text view that is visible
- (NSRange)visibleRangeOfTextView:(UITextView *)textView
{
    CGRect bounds = textView.bounds;
    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))].end;
    NSRange visibleRange = NSMakeRange([textView offsetFromPosition:textView.beginningOfDocument toPosition:start],
                                       [textView offsetFromPosition:start toPosition:end]);
    return visibleRange;
}

// Compare the two ranges and return YES if range1 contains range2
bool NSRangeContainsRange (NSRange range1, NSRange range2)
{
    BOOL contains = NO;
    if (range1.location < range2.location && range1.location+range1.length > range2.length+range2.location)
    {
        contains = YES;
    }
    return contains;
}

// Remove all highlighted text (the background color) of NSAttributedString
// in a given UITextView
- (void)removeAllHighlightedTextInTextView:(UITextView *)textView
{
    NSMutableAttributedString *mutableAttributedString = self.textView.attributedText.mutableCopy;
    NSRange wholeRange = NSMakeRange(0, mutableAttributedString.length);
    [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:wholeRange];
    textView.attributedText = mutableAttributedString.copy;
}

#pragma mark
#pragma mark - Find interesting data

-(NSArray *)getMatchesFromPattern:(NSString *)pattern {

    NSError *error = NULL;
    NSString *string = self.textView.text;
    NSRange range = NSMakeRange(0, string.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error == NULL) {
        return [regex matchesInString:string options:NSMatchingProgress range:range];}
    return nil;

}

- (void)underlineAllDates
{
    NSString *pattern = @"(\\d{1,2}[-/.]\\d{1,2}[-/.]\\d{1,2})|(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?)\\s*\\d{1,2}(st|nd|rd|th)?+[,]\\s*\\d{4}";

    [self highlightMatches:[self getMatchesFromPattern:pattern]];
}

- (void)underlineAllTimes
{
    NSString *pattern = @"\\d{1,2}\\s*(pm|am)";
    [self highlightMatches:[self getMatchesFromPattern:pattern]];
}

- (void)underlineAllLocations
{
    NSString *pattern = @"[a-zA-Z]+[,]\\s*([A-Z]{2})";
    [self highlightMatches:[self getMatchesFromPattern:pattern]];
}

// Matches is an array with object of type NSTextCheckingResult
- (void)highlightMatches:(NSArray *)matches
{
    __block NSMutableAttributedString *mutableAttributedString = self.textView.attributedText.mutableCopy;
    
    [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSTextCheckingResult class]])
        {
            NSTextCheckingResult *match = (NSTextCheckingResult *)obj;
            NSRange matchRange = match.range;
            [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:matchRange];
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
        }
    }];
    
    self.textView.attributedText = mutableAttributedString.copy;
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

    if (CGPointEqualToPoint(velocity, CGPointZero))
    {    NSLog(@"scrollViewWillEndDragging");

        if (self.lastSearchString && self.lastSearchOptions && !self.lastReplacementString)
            [self searchText:self.lastSearchString inTextView:self.textView options:self.lastSearchOptions];
    }}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
    if (self.lastSearchString && self.lastSearchOptions && !self.lastReplacementString)
        [self searchText:self.lastSearchString inTextView:self.textView options:self.lastSearchOptions];

}


@end
