//
//  AppDelegate.h
//  WXHelper
//
//  Created by 刘山国 on 16/2/28.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYCache;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) YYCache *cache;;

+ (AppDelegate*)shareDelegate;
- (void)goToMainController;

- (void)clearAllCache;
- (void)clearAllMemoryCache;

@end

