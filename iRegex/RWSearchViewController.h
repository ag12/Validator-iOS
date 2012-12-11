//
//  RWSearchViewController.h
//  iRegex
//
//  Created by Canopus on 12/10/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


// Search options keys
// The values are BOOL for these keys
#define kRWSearchCaseInsensitiveKey @"RWSearchCaseInsensitiveKey"
#define kRWSearchMatchWordKey       @"RWSearchMatchWordKey"

// Delegate
@protocol RWSearchViewControllerDelegate;


@interface RWSearchViewController : UITableViewController
@property (weak, nonatomic) id <RWSearchViewControllerDelegate> delegate;

// If you start off with a default or previous
// search string, pass it in
@property (strong, nonatomic) NSString *searchString;

@property (strong, nonatomic) NSDictionary *searchOptions;

@end


// Delegate
@protocol RWSearchViewControllerDelegate <NSObject>

// Return self, the search string and the search options
- (void)controller:(RWSearchViewController *)controller didFinishWithSearchString:(NSString *)string options:(NSDictionary *)options;

@end