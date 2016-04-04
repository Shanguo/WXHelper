//
//  WXCoreModel.h
//  WXHelper
//
//  Created by 刘山国 on 16/4/3.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXContact;
@class WXMessage;
@interface WXCoreModel : NSObject

/**
 *  单例模式
 *
 *  @return WXCoreModel 单例
 */
+ (instancetype)shareModel;

/**
 *  Model初始化请求
 */
- (void)modelDataInit;

/**
 *  微信连接失败，清空model
 */
- (void)modelClear;

/**
 *  好友和群的总数量，不包括陌生人
 *
 *  @return count
 */
- (NSInteger)contactsCount;

/**
 *  根据index获取Contact, for tableView
 *
 *  @param index NSInteger
 *
 *  @return contact
 */
- (WXContact*)contactAtIndex:(NSUInteger)index;


/**
 *  获取contact，根据nickname或者remarkname
 *
 *  @param name nickname or remarkname
 *
 *  @return WXContact
 */
- (WXContact*)contactWithName:(NSString*)name;

/**
 *  根据username获取contact
 *
 *  @param username username
 *
 *  @return contact
 */
- (WXContact*)contactWithUserName:(NSString*)userName;

/**
 *  所有群，好友，非好友的nickname，remarkname
 *
 *  @return NSSet
 */
- (NSSet*)friendsNames;

@end
