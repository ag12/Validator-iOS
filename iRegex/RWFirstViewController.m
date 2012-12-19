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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
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
    if (![string isEqualToString:self.lastSearchString] || ![options isEqual:self.lastSearchOptions])
    {
        // Keep a reference
        self.lastSearchString = string;
        self.lastSearchOptions = options;
        
        // Do a clean up of the last time. Remove all the highlights
        [self removeAllHighlightedTextInTextView:self.textView];
        
        // Start the search
        [self searchForText:string inTextView:self.textView options:options];
    }
}

#pragma mark
#pragma mark - Manage search

/** first try - main thread - all instances together
 * =================================================
- (void)searchForText:(NSString *)text inTextView:(UITextView *)textView options:(NSDictionary *)options
{
    // Do a clean up of the last time. Remove all the highlights
    [self removeAllHighlightedTextInTextView:self.textView];
    
    // 5) Modify call to delegate at the end of processHTML **AND** processZip to be the following
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [delegate imageInfosAvailable:imageInfos done:(pendingZips==0)];
    });
    BOOL isCaseSensitive = [[options objectForKey:kRWSearchCaseSensitiveKey] boolValue];
    BOOL isWholeWords = [[options objectForKey:kRWSearchWholeWordsKey] boolValue];
    
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = isCaseSensitive ? 0 : NSRegularExpressionCaseInsensitive;
    
    NSString *placeholder = isWholeWords ? @"\\b%@\\b" : @"%@";
    NSString *pattern = [NSString stringWithFormat:placeholder, text];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:regexOptions
                                                                             error:&error];
    
    NSString *textViewText = textView.text;
    NSRange range = NSMakeRange(0, textViewText.length);
    
    NSArray *matches = [regex matchesInString:textViewText options:NSMatchingProgress range:range];
    
    // Range of visible text
    NSRange visibleRange = [self visibleRangeOfTextView:self.textView];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = match.range;
        
        //Highlight all matches
        [self highlightRange:matchRange inTextView:self.textView];
    }
}
 */

/** second try - main thread - but only instances visible
 * =================================================
- (void)searchForText:(NSString *)text inTextView:(UITextView *)textView options:(NSDictionary *)options
{
    // Do a clean up of the last time. Remove all the highlights
    [self removeAllHighlightedTextInTextView:self.textView];
    
    BOOL isCaseSensitive = [[options objectForKey:kRWSearchCaseSensitiveKey] boolValue];
    BOOL isWholeWords = [[options objectForKey:kRWSearchWholeWordsKey] boolValue];
    
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = isCaseSensitive ? 0 : NSRegularExpressionCaseInsensitive;
    
    NSString *placeholder = isWholeWords ? @"\\b%@\\b" : @"%@";
    NSString *pattern = [NSString stringWithFormat:placeholder, text];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:regexOptions
                                                                             error:&error];
    
    NSString *textViewText = textView.text;
    NSRange range = NSMakeRange(0, textViewText.length);
    
    NSArray *matches = [regex matchesInString:textViewText options:NSMatchingProgress range:range];
    
    // Range of visible text
    NSRange visibleRange = [self visibleRangeOfTextView:self.textView];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = match.range;
        
        // If the range is visible, highlight it
        BOOL isRangeVisible = NSRangeContainsRange(visibleRange, matchRange);
        if (isRangeVisible)
            [self highlightRange:matchRange inTextView:self.textView];
    }
}
 */

/** third try */
- (void)searchForText:(NSString *)text inTextView:(UITextView *)textView options:(NSDictionary *)options
{
    BOOL isCaseSensitive = [[options objectForKey:kRWSearchCaseSensitiveKey] boolValue];
    BOOL isWholeWords = [[options objectForKey:kRWSearchWholeWordsKey] boolValue];
    
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = isCaseSensitive ? 0 : NSRegularExpressionCaseInsensitive;
    
    NSString *placeholder = isWholeWords ? @"\\b%@\\b" : @"%@";
    NSString *pattern = [NSString stringWithFormat:placeholder, text];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    
    // Range of visible text
    NSRange visibleRange = [self visibleRangeOfTextView:self.textView];
    
    // Get a mutable sub-range of attributed string of the text view that is visible
    NSMutableAttributedString *visibleAttributedString = [textView.attributedText attributedSubstringFromRange:visibleRange].mutableCopy;
    
    NSString *textToSearch = visibleAttributedString.string;
    NSRange range = NSMakeRange(0, textToSearch.length);
    
    NSArray *matches = [regex matchesInString:textToSearch options:NSMatchingProgress range:range];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = match.range;
        [visibleAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:matchRange];
    }
    
    // Replace the range of the attributed string that we just highlighted
    CFRange visibleRange_CF = CFRangeMake(visibleRange.location, visibleRange.length);
    NSMutableAttributedString *textViewAttributedString = self.textView.attributedText.mutableCopy;
    CFAttributedStringReplaceAttributedString((__bridge CFMutableAttributedStringRef)(textViewAttributedString), visibleRange_CF, (__bridge CFAttributedStringRef)(visibleAttributedString));
    
    self.textView.attributedText = textViewAttributedString;
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

#pragma mark
#pragma mark - UIScrollView delegate

// Called when the user finishes scrolling the content
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (CGPointEqualToPoint(velocity, CGPointZero))
    {
        if (self.lastSearchString && self.lastSearchOptions)
            [self searchForText:self.lastSearchString inTextView:self.textView options:self.lastSearchOptions];
    }
}

// Called when the scroll view has ended decelerating the scrolling movement
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.lastSearchString && self.lastSearchOptions)
        [self searchForText:self.lastSearchString inTextView:self.textView options:self.lastSearchOptions];
}

#pragma mark
#pragma mark - Highlighting the text in UITextView

// Highlight a given range in a text view
/*** Deprecated after the third try
- (void)highlightRange:(NSRange)range inTextView:(UITextView *)textView
{
    NSMutableAttributedString *mutableAttributedString = textView.attributedText.mutableCopy;
    [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:range];
    self.textView.attributedText = mutableAttributedString.copy;
}
 ***/

// Remove all highlighted text (the background color) of NSAttributedString
// in a given UITextView
- (void)removeAllHighlightedTextInTextView:(UITextView *)textView
{
    NSMutableAttributedString *mutableAttributedString = self.textView.attributedText.mutableCopy;
    NSRange wholeRane = NSMakeRange(0, mutableAttributedString.length);
    [mutableAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:wholeRane];
    textView.attributedText = mutableAttributedString.copy;
}

@end
