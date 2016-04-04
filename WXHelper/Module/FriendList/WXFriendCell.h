//
//  WXFriendCell.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/6.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXContact;
@class WXMessage;
static NSString * const FriendCellIdentity = @"WXFriendCell";
@interface WXFriendCell : UITableViewCell

@property (nonatomic,strong) WXContact *contact;
//@property (nonatomic,strong) NSDictionary *msgInfoDic;
@property (nonatomic,strong) WXMessage *message;
//@property (nonatomic,strong) NSMutableDictionary *imageDic;

@end
