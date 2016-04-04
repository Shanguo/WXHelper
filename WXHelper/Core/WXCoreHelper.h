//
//  WXLoginHelper.h
//  WeiXin
//
//  Created by TanHao on 13-8-25.
//  Copyright (c) 2013年 http://www.tanhao.me. All rights reserved.
//

/**
 *  网络请求核心
 */

#import <Foundation/Foundation.h>
#import "WXAccess.h"

@interface WXCoreHelper : NSObject

/**
 *  由微信服务器返回一个会话ID,UUID用来获取登陆二维码
 *
 *  @return UUID String
 */
+ (NSString *)wxUUID;

/**
 *  获取登录的二维码
 *
 *  @param uuid uuid
 *
 *  @return UIImage
 */
+ (UIImage *)qrCode:(NSString *)uuid;

/**
 *  获取登录的页面地址，即重定向URL--loginPage
 *
 *  @param uuid  uuid
 *  @param state state
 *
 *  @return loginPage
 */
+ (NSString *)loginPage:(NSString *)uuid state:(int *)state;


/**
 *  通过登录页登录
 *
 *  @param loginPage 返回的重定向URL
 *
 *  @return WXAccess
 */
+ (WXAccess *)login:(NSString *)loginPage;

//此步骤不明情况
+ (void)webwxstatreport:(NSString *)uuid;

/**
 *  微信初使化
 *
 *  @return dic
 */
+ (NSDictionary *)wxInit;

/**
 *  获取所有好友，订阅号等，没有群
 *
 *  @return array
 */
+ (NSArray *)allFriendsOthers;

/**
 *  根据ChatSet里面的Usernames 请求
 *
 *  @param count   username的数量
 *  @param jsonStr part json
 *
 *  @return 请求的Contacts array
 */
+ (NSArray *)postGroupWithCount:(NSInteger)count JsonStr:(NSString*)jsonStr;

+ (NSDictionary *)postGetOrderList;

//此步骤不明情况(给自己发了一条消息)
+ (BOOL)webwxstatusnotify;

//保持与服务器的同步
+ (int)synccheck;

/**
 *  接收消息
 *
 *  @return array
 */
+ (NSArray *)receiveMessage;

/**
 *  发送消息
 *
 *  @param user    username
 *  @param message message
 *
 *  @return Bool
 */
//+ (BOOL)sendMeaageToUser:(NSString *)user message:(NSString *)message;
+ (void)sendTextMsg:(NSString*)aMsg ToUserName:(NSString*)userName Result:(void(^)(BOOL success))result;


+ (UIImage *)imageWithURL:(NSURL*)url;

+ (UIImage *)syncImageWithUrlStr:(NSString*)urlStr;

+ (void)asyncImageWithURLStr:(NSString*)urlStr Complete:(void (^)(BOOL isSuccess,UIImage *image))complete;

+ (UIImage*)readImageFromCacheWithUrlStr:(NSString*)urlStr;

@end
