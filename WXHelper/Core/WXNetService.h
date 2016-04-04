//
//  WXNetService.h
//  WXHelper
//
//  Created by 刘山国 on 16/4/2.
//  Copyright © 2016年 山国. All rights reserved.
//

/**
 *  网络请求服务
 */

#import <Foundation/Foundation.h>


static NSString * const kWXNetStateKey          = @"WXNetState";
static NSString * const kWXCodeImageKey         = @"WXCodeImage";
static NSString * const kWXNewMsgKey            = @"WXNewMsg";

/**
 *  <=0 失败
 */
typedef NS_ENUM(NSUInteger, WXNetState) {
    StateFail                           = 0,
    StateNotGetUUID                     = 10,
    StateGetCodeImage                   = 11,
    StateHasScanCode                    = 12,
    StateNotGetAccess                   = -13,
    StatePhoneHadMakeSureLogin          = 14,
    StateHasNewMessage                  = 15,
};

@interface WXNetService : NSObject

/**
 *  单例模式
 *
 *  @return NetService 单例
 */
+ (instancetype)shareInstance;

/**
 *  Step 1. 获取扫描登陆二维码
 */
- (void)wxStartRequestCodeImage;


/**
 *  Step 2. 登陆成功加载好友信息
 */
- (void)wxOnLoginRequest:(NSArray* (^)(NSArray *contactDics,NSString *charSetStr))initResult GroupsOtherPostResult:(void (^)(NSArray *groupAndOthers))groupsAndOthersResult AllFriens:(void (^)(NSArray *allFriendsDics))allFriendsResult;

/**
 *  Step 3. 登陆后状态轮询
 */
- (void)wxStartMaintainOnLineService;


- (NSDictionary*)wxPostGroupWithUserName:(NSString*)userName;

- (NSDictionary*)wxPostStrangeWithUserName:(NSString*)userName EncryRoomId:(NSString*)anId;


- (NSMutableArray*)groupDicsWithUserNames:(NSArray*)userNames;

- (NSMutableArray*)unKnownFriendDicsWithUserNames:(NSArray*)userNames;


@end
