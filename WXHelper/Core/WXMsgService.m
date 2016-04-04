//
//  WXMsgService.m
//  WXHelper
//
//  Created by 刘山国 on 16/4/2.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXMsgService.h"
#import "WXNetService.h"
#import "WXMessage.h"
#import "WXContact.h"
#import "WXFriendsModel.h"

@interface WXMsgService()

@property (nonatomic,strong) WXFriendsModel *model;

@end

@implementation WXMsgService

#pragma mark - life cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessagesGeted:) name:kWXNetStateKey object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWXNetStateKey object:nil];
}



/**
 *  单例模式
 *
 *  @return MsgService 单例
 */
+ (instancetype)shareInstance{
    static WXMsgService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[WXMsgService alloc] init];
    });
    return service;
}


#pragma mark - Notification

- (void)newMessagesGeted:(NSNotification*)notification{
    if ([[notification.userInfo objectForKey:kWXNewMsgKey] integerValue] == StateHasNewMessage) {
        NSArray *msgDicsArray = [[notification userInfo] objectForKey:kWXNewMsgKey];
        if (!msgDicsArray || msgDicsArray.count <=0 )  return;
        [self resolveMsgDicsArray:msgDicsArray];
    }
}


#pragma mark - private

- (void)resolveMsgDicsArray:(NSArray*)msgDicsArray{
    NSLog(@"meaage:%@",msgDicsArray);
    for (NSDictionary *aMsg in msgDicsArray){
        WXMessage *message = [[WXMessage alloc] initWithDic:aMsg];
        NSString *fromUserName = message.fromUserName;
        NSString *toUserName   = message.toUserName;
        if ([fromUserName isEqualToString:toUserName]) continue;//过滤
        
        if (message.forwardFlag) {//来自自己
//            if ([self contactResolveWithUserName:toUserName WXMessage:message]) {
//                if (message.msgType == MTypeStatusNotify) {
//                    [self addNewMessage:nil keyUserName:nil resetFirstWithUserName:toUserName];
//                }else{
//                    message.forwardFlag = 1;
//                    [weakSelf addNewMessage:message keyUserName:toUserName resetFirstWithUserName:toUserName];
//                }
//            }
//            
        }else{//来自他人
//            if ([weakSelf contactResolveWithUserName:fromUserName WXMessage:message]) {
//                [weakSelf addNewMessage:message keyUserName:fromUserName resetFirstWithUserName:fromUserName];
//            }
        }
        
    }
}



//- (WXContact*)contactResolveWithUserName:(NSString*)userName WXMessage:(WXMessage*)message{
//    WXContact *contact = [self contactWithUserName:userName];
//    if (!contact) return nil;
//    if (contact.contactType == TypeGroup) {
//        if (![[WXAccess access] isSelfWithUserName:message.fromUserName]) {
//            NSString *userNameInGroup = [message userNameInGroupMsg];
//            if (!userNameInGroup) {
//                if (userName) [self.model resetContactToBeFirstWithUserName:userName];
//                return nil;
//            }
//            WXContact *contentContact = [self contactWithUserName:userNameInGroup];
//            if (!contentContact) return nil;
//            message.contact = contentContact;
//            [message contentGroupResolve];
//        }
//        
//    }else if(contact.contactType == TypeFriend || contact.contactType == TypeUnKnown) {
//        message.contact = contact;
//        [message contentResolve];
//    }else{
//        return nil;
//    }
//    return contact;
//}


- (WXContact*)contactWithUserName:(WXMessage*)message{
    WXContact *contact = nil;
    if (message.forwardFlag) {
        contact = [self.model contactWithUserName:message.toUserName];
        if (!contact) contact = [self.model postToGetUnknownContactWithUserName:message.toUserName];;
    } else {
        contact = [self.model contactWithUserName:message.fromUserName];
        if (!contact) {
            if ([self isMsgMaybeGroupMsg:message]) {//如果只群，可能是群中的好友，或者群中的陌生人
//                contact = [self.model postToGetUnknownContactWithUserName:userName];
            } else {//一定不来自群
                contact = [self.model postToGetUnknownContactWithUserName:message.fromUserName];
            }
        }
    }
    
    
    return contact;
}


//- (void)g;

- (BOOL)isMsgMaybeGroupMsg:(WXMessage*)message{
    if (message.content.length<15) return NO;
    if ([message.content hasPrefix:@"@"] && [message.content containsString:@":<br/>"]) {
        return YES;
    } else {
        return NO;
    }
}


@end
