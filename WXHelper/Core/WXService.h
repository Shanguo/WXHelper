//
//  WXService.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/9.
//  Copyright © 2016年 山国. All rights reserved.
//

/**
 *  后台语音服务
 */

#import <Foundation/Foundation.h>

/**
 *  kServiceNotification既是通知的key，也是传递消息体的key
 */
static NSString * const kServiceNotification = @"kServiceNotification";

@class WXMessage;
@class WXFriendsModel;
@interface WXService : NSObject

@property (nonatomic,strong) WXFriendsModel *model;
@property (nonatomic,assign) NSInteger step;

+ (instancetype)shareInstance;

- (void)startNewWorkService;
- (void)startVoiceServiceWithFriendsNames:(NSSet*)friendNames;

- (void)speekWithWords:(NSString*)words;
- (void)readMessage:(WXMessage*)message;
@end
