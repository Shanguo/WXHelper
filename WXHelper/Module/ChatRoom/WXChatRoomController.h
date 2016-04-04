//
//  WXChatRoomController.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/1.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class ChatRoomController;
@protocol ChatRoomControllerDelegate <NSObject>

- (void)chatRoomControllerOutWithUserName:(NSString*)userName hasNewMsg:(BOOL)hasNewMsg;

@end


@class WXContact;
@interface WXChatRoomController : UIViewController

@property (nonatomic,assign) id<ChatRoomControllerDelegate> delegate;
@property (nonatomic,strong) WXContact *contact;
@property (nonatomic,strong) NSMutableArray *msgList;

@end
