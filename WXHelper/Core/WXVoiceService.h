//
//  WXVoiceService.h
//  WXHelper
//
//  Created by 刘山国 on 16/4/2.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  <=0 失败
 */
typedef NS_ENUM(NSUInteger, WXVoiceState) {
    VStateReadFail              = -1,
    VStateListenFail            = 0,
    VStateListenning            = 100,
    VStateReading               = 101,
    VStateAudioPlaying          = 102,
    VStateVideoPlaying          = 103,
    VStateListenReadQueue       = 104
};


/**
 *  kServiceNotification既是通知的key，也是传递消息体的key
 */
static NSString * const kServiceNotification = @"kServiceNotification";

@class WXMessage;
@class WXFriendsModel;
@interface WXVoiceService : NSObject

@property (nonatomic,strong) WXFriendsModel *model;
@property (nonatomic,assign) NSInteger step;

@end
