//
//  AMValidator.h
//  iRegex
//
//  Created by Amir Ghoreshi on 20/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

// Search options keys
// The values of these keys are BOOL
#define kRWSearchCaseSensitiveKey    @"RWSearchCaseSensitiveKey"
#define kRWSearchWholeWordsKey       @"RWSearchWholeWordsKey"
#define kRWReplacementKey            @"RWReplacementKey"


#import <Foundation/Foundation.h>

@interface AMValidator : NSObject


+ (NSRegularExpression *)regularExpressionWithString:(NSString *)string options:(NSDictionary *)options;
+ (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern;
+ (NSString *)stringTrimmedForWhiteSpaces:(NSString *)string;
@end
