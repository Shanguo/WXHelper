//
//  AppDelegate.m
//  WXHelper
//
//  Created by 刘山国 on 16/2/28.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "AppDelegate.h"
#import "WXLoginViewController.h"
#import "WXFriendsController.h"
#import <YYCache.h>
#import <YYMemoryCache.h>


static AppDelegate *sharedDelegate;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //进入登录页
    [self goToLogin];
    return YES;
}


#pragma mark - private method

+ (AppDelegate*)shareDelegate{
//    sharedDelegate = (AppDelegate*)self;//这个调用方法会闪退
    sharedDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return sharedDelegate;
}

/**
 *  进入登录页
 */
- (void)goToLogin{
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    WXLoginViewController *loginVC = [[WXLoginViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.window setRootViewController:loginVC];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
}

- (void)goToMainController{
    [self.window resignKeyWindow];
    self.window = [[UIWindow alloc]initWithFrame:SCREEN_BOUNDS];
    WXFriendsController *loginVC = [[WXFriendsController alloc] init];
    UINavigationController *navigationContro = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.window setRootViewController:navigationContro];
    [self.window makeKeyAndVisible];
}


- (void)clearAllCache{
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    [self.cache removeAllObjects];
}

- (void)clearAllMemoryCache{
    [[SDImageCache sharedImageCache] clearMemory];
    [self.cache.memoryCache removeAllObjects];
}


- (YYCache *)cache{
    if (!_cache) {
        _cache = [[YYCache alloc]initWithName:@"voiceCache"];
    }
    return _cache;
}

@end



