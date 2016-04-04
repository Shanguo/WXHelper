//
//  WXMessage.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/3.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WXMessageType) {
    MTypeUnKnown        = 0,
    MTypeText           = 1,
    MTypeImage          = 3,
    MTypeVoice          = 34,
    MTypeAnimationImg   = 47,
    MTypeStatusNotify   = 51,
    MTypeVideo          = 62
};

@class WXContact;
@interface WXMessage : NSObject

@property (nonatomic,copy) NSNumber *msgId;
//@property (nonatomic,assign) NSInteger appMsgType;
//@property (nonatomic,copy) NSNumber *mediaId;
//@property (nonatomic,copy) NSURL *url;
@property (nonatomic,assign) NSTimeInterval createTime;
//@property (nonatomic,strong) NSDictionary *recommendInfo;
//@property (nonatomic,copy) NSString *ticket;
//@property (nonatomic,copy) NSNumber *newMsgID;//
//@property (nonatomic,copy) NSNumber *msgId;
//@property (nonatomic,assign) NSInteger subMsgType;
@property (nonatomic,assign) WXMessageType msgType;
@property (nonatomic,copy) NSString *content;
//@property (nonatomic,assign) CGFloat fileSize;
//@property (nonatomic,assign) CGFloat imageWidth;
//@property (nonatomic,assign) CGFloat imageHeight;
//@property (nonatomic,assign) NSInteger imageStatus;
//@property (nonatomic,copy) NSNumber *hasProductId;
@property (nonatomic,copy) NSString *fromUserName;
@property (nonatomic,copy) NSString *toUserName;
//@property (nonatomic,assign) CGFloat voiceLenth;
//@property (nonatomic,assign) CGFloat playLenth;
@property (nonatomic,assign) NSInteger forwardFlag;//1是自己，0是别人
//@property (nonatomic,strong) NSDictionary *appInfo;
//@property (nonatomic,assign) NSInteger statusNotifyCode;
//@property (nonatomic,assign) NSInteger status;
//@property (nonatomic,copy) NSString *fileName;
//@property (nonatomic,copy) NSString *statusNofityUserName;
@property (nonatomic,copy) NSString *msgUrlStr;
@property (nonatomic,copy) NSString *msgThumbnailUrlStr;
//@property (nonatomic,copy) NSString *imageKey;
@property (nonatomic,assign) NSInteger voiceLength;


//补充
//@property (nonatomic,assign) BOOL isSend;

@property (nonatomic,assign) CGFloat imageW;
@property (nonatomic,assign) CGFloat imageH;
@property (nonatomic,strong) WXContact *contact;


- (instancetype)initWithDic:(NSDictionary*)dic;
- (instancetype)initWithSendTextMsg:(NSString*)content ToUserName:(NSString*)toUserName;

/**
 *  如果是群组消息，那么获取发消息人的用户名
 *
 *  @return username
 */
- (NSString *)userNameInGroupMsg;

/**
 *  群组消息内容处理
 *
 *  @return WXMessage
 */
- (WXMessage*)contentGroupResolve;

/**
 *  去除<br>
 *
 *  @return WXMessage
 */
- (WXMessage*)contentResolve;



@end
