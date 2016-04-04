//
//  WXContact.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/3.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WXContactType) {
    TypeOther       = 0,
    TypeFriend      = 1,
    TypeGroup       = 2,
    TypeStranger    = 3 //一般是群里未加好友的人
};

@interface WXContact : NSObject<NSCoding>

//@property (nonatomic,copy)      NSNumber    *uin;
@property (nonatomic,strong)    NSURL       *headImgURL;
@property (nonatomic,copy)      NSString    *userName;//每次登陆变新值，想文件助手这类不变
@property (nonatomic,copy)      NSString    *nickName;
@property (nonatomic,copy)      NSString    *remarkName;
@property (nonatomic,copy)      NSString    *displayName;
//@property (nonatomic,assign)    NSInteger   contactFlag;
@property (nonatomic,assign)    NSInteger   verifyFlag;
@property (nonatomic,copy)      NSString    *PYInitial;
//@property (nonatomic,copy)      NSString    *PYQuanPin;
@property (nonatomic,copy)      NSString    *encryChatRoomId;
@property (nonatomic,copy)      NSString    *alias;//微信号

@property (nonatomic,assign) WXContactType contactType;
//@property (nonatomic,copy) NSString *message;
//@property (nonatomic,copy) NSString *timeStr;


@property (nonatomic,strong) UIImage  *headImage;
- (instancetype)initWithDic:(NSDictionary *)infoDic;

@end
