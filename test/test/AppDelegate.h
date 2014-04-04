//
//  AppDelegate.h
//  test
//
//  Created by Mayank Purwar on 2/5/13.
//  Copyright (c) 2013 Mayank Purwar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordViewController.h"
#import "PreviewViewController.h"


#define APP_DELEGATE       ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define IS_IPHONE_5        ([UIScreen mainScreen].bounds.size.height == 568)
#define IOS7  ([[[[[UIDevice currentDevice] systemVersion]componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 7)


@class PreviewViewController;
@class  RecordViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RecordViewController *record;
@property (strong, nonatomic) PreviewViewController *preview;
@end
