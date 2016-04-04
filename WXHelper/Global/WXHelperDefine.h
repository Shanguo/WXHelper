//
//  WXHelperDefine.h
//  WXHelper
//
//  Created by 刘山国 on 16/2/28.
//  Copyright © 2016年 山国. All rights reserved.
//

#ifndef WXHelperDefine_h
#define WXHelperDefine_h


// 屏幕尺寸和比例
#define SCREEN_BOUNDS ([UIScreen mainScreen].bounds)
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define YScale (SCREEN_HEIGHT/568.0<1?1:SCREEN_HEIGHT/568.0)
#define XScale (SCREEN_WIDTH/320.0)

// 状态栏、导航栏高度
#define STATUS_BAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height
#define NAVIGATION_BAR_HEIGHT 44

// 系统版本
#define SYSTEM_VERSION [UIDevice currentDevice].systemVersion.floatValue

// 颜色定义
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)


//其他
#define kNewMsgState @"NewMsgState"
#define kNewMsgNotification  @"NewMsgNotification"

#define kOnLineConnectFail @"OnLineConnectFail"


#endif /* WXHelperDefine_h */
