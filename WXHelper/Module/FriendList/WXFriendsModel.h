//
//  WXFriendsModel.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/4.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WXContact;
@interface WXFriendsModel : NSObject

@property (nonatomic,strong) NSMutableArray *list;;
/***********************************************************************************************************/

/**
 *  第一次添加数据
 *
 *  @param contacts infoDics Array
 */
- (void)initAddContactsWithDicsArray:(NSArray*)contacts;

/**
 *  后续添加数据
 *
 *  @param contacts infoDics Array
 */
- (void)addContactsWithDicsArray:(NSArray*)contacts;




/***********************************************************************************************************/
/**
 *  获取contact for tableView cell
 *
 *  @param index indexPath.row
 *
 *  @return WXContact
 */
- (WXContact*)contactAtIndex:(NSUInteger)index;

/**
 *  获取contact，根据UserName
 *
 *  @param username username
 *
 *  @return WXContact
 */
- (WXContact*)contactWithUserName:(NSString*)username;

/**
 *  获取contact，根据nickname或者remarkname或者displayname
 *
 *  @param name nickname or remarkname or displayname
 *
 *  @return WXContact
 */
- (WXContact*)contactWithName:(NSString*)name;

/**
 *  获取所有好友的nickname，remarkname,用户识别
 *
 *  @return array
 */
- (NSSet*)friendsNames;




/***********************************************************************************************************/

/**
 *  对最新聊天的排序
 *
 *  @param aUserName aUserName
 *
 *  @return WXContact
 */
- (WXContact*)resetContactToBeFirstWithUserName:(NSString*)aUserName;


/***********************************************************************************************************/

/**
 *  登录成功，网络数据初始化请求
 */
- (void)onLoginRequest;

/**
 *  根据Username请求没有的Contact
 *
 *  @param userName username
 *
 *  @return WXContact
 */
- (WXContact*)postToGetUnknownContactWithUserName:(NSString*)userName;



@end
