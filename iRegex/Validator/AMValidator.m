//
//  AMValidator.m
//  iRegex
//
//  Created by Amir Ghoreshi on 20/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "AMValidator.h"

@implementation AMValidator

NSString * const AM_PATTERN_WHOLEWORD = @"\\b%\\b";
NSString * const AM_PATTERN_NAME = @"^[aæøå-zAÆØÅ-Z]{3,10}$";
NSString * const AM_PATTERN_MIDLE_INITIAL = @"^[aæøå-zAÆØÅ-Z]$";
NSString * const AM_PATTERN_BIRTH_DAY = @"^(0[1-9]|1[012])[-/.](0[1-9]|[12][0-9]|3[01])[-/.](19|20)\\d\\d$";
NSString * const AM_PATTERN_SPACE = @"(?:^\\s+)|(?:\\s+$)|(?m:^ +| +$|( ){2,})";
NSString * const AM_PATTERN_POSTAL_CODE = @"^([0-9]{3}[1-9]{1}$)";
NSString * const AM_PATTERN_PRO_POSTAL_CODE = @"^(\\d{3}[1-9]{1}$)";


+ (NSRegularExpression *)regularExpressionWithString:(NSString *)string options:(NSDictionary *)options {


    BOOL isCaseSensitive = [[options objectForKey:kRWSearchCaseSensitiveKey] boolValue];
    BOOL isWholeWord = [[options objectForKey:kRWSearchWholeWordsKey] boolValue];

    NSError *error = NULL;

    NSRegularExpressionOptions *option = isCaseSensitive ? 0 : NSRegularExpressionCaseInsensitive;

    NSString *placeHolder = isWholeWord ? AM_PATTERN_WHOLEWORD : @"%@";
    NSString *pattern = [NSString stringWithFormat:placeHolder, string];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:option error:&error];

    if (error) {
        NSLog(@"Error: Wrong regex?? %@", error.debugDescription);
    } else if (error == NULL) {
        NSLog(@"Regex created");
    }
    return regex;
}

+ (NSString *)stringTrimmedForWhiteSpaces:(NSString *)string
{
    NSRegularExpression *regex =[NSRegularExpression regularExpressionWithPattern:AM_PATTERN_SPACE options:NSRegularExpressionCaseInsensitive error:NULL];
    NSRange targetRange = NSMakeRange(0, string.length);
    NSString *trimString = [regex stringByReplacingMatchesInString:string options:NSMatchingProgress range:targetRange withTemplate:@"$1"];
    return trimString;
}
+ (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern {

    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSAssert(regex, @"Unable to create regular expression");

    NSRange range = NSMakeRange(0, string.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingProgress range:range];

    BOOL didValidate = NO;
    if (matchRange.location != NSNotFound) {
        didValidate = YES;
    }
    return didValidate;

}









@end
