//
//  WXCoreModel.m
//  WXHelper
//
//  Created by 刘山国 on 16/4/3.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXCoreModel.h"
#import "WXContact.h"
#import "WXMessage.h"
#import "WXNetService.h"
#import "AppDelegate.h"
#import <YYCache.h>


@interface WXCoreModel()

@property (nonatomic,strong) WXNetService *netService;

@property (nonatomic,strong) NSMutableDictionary *contactsDic;
@property (nonatomic,strong) NSMutableDictionary *nameContactDic;
@property (nonatomic,strong) NSMutableArray *userNamesArray;
@property (nonatomic,strong) NSMutableDictionary *allMsgInfo;
@property (nonatomic,strong) NSMutableSet *namesSet;


@end

@implementation WXCoreModel


#pragma mark - public 

/**
 *  单例模式
 *
 *  @return WXCoreModel 单例
 */
+ (instancetype)shareModel{
    static WXCoreModel *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[WXCoreModel alloc] init];
    });
    return model;
}

/**
 *  Model初始化请求
 */
- (void)modelDataInit{
    [self basicInit];
    [self.netService wxOnLoginRequest:^NSArray *(NSArray *contactDics, NSString *charSetStr) {
         return [self filterRequestNamesWithCharSet:charSetStr contactDics:contactDics];
    } GroupsOtherPostResult:^(NSArray *groupAndOthers) {
        [self addContactsWithDicsArray:groupAndOthers];
    } AllFriens:^(NSArray *allFriendsDics) {
        [self addContactsWithDicsArray:allFriendsDics];
    }];
}

/**
 *  微信连接失败，清空model
 */
- (void)modelClear{
    @autoreleasepool {
        self.contactsDic = nil;
        self.userNamesArray = nil;
        self.namesSet = nil;
        self.allMsgInfo = nil;
        self.nameContactDic = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWXNetStateKey object:nil];
}

/**
 *  好友和群的总数量，不包括陌生人
 *
 *  @return count
 */
- (NSInteger)contactsCount{
    return self.userNamesArray.count;
}

/**
 *  根据index获取Contact, for tableView
 *
 *  @param index NSInteger
 *
 *  @return contact
 */
- (WXContact*)contactAtIndex:(NSUInteger)index{
    if (self.userNamesArray.count <= index) return nil;
    NSString *username = self.userNamesArray[index];
    return [self contactWithUserName:username];
}


/**
 *  获取contact，根据nickname或者remarkname
 *
 *  @param name nickname or remarkname
 *
 *  @return WXContact
 */
- (WXContact*)contactWithName:(NSString*)name{
    if (name.length==0) return nil;
    NSString *userName = [self.nameContactDic objectForKey:name];
    if (!userName) return nil;
    return [self contactWithUserName:userName];
}

/**
 *  根据username获取contact
 *
 *  @param username username
 *
 *  @return contact
 */
- (WXContact*)contactWithUserName:(NSString*)userName{
    return [self.contactsDic objectForKey:userName];
}


/**
 *  所有群，好友，非好友的nickname，remarkname
 *
 *  @return NSSet
 */
- (NSSet*)friendsNames{
    return self.namesSet;
}

#pragma mark - New Message Get
- (void)newMessagesGeted:(NSNotification*)notification{
    NSArray *newMsgDics = [notification.userInfo objectForKey:kWXNewMsgKey];
    
    
    NSLog(@"meaage:%@",newMsgDics);
    for (NSDictionary *aMsg in newMsgDics){
        WXMessage *message = [[WXMessage alloc] initWithDic:aMsg];
        if (!message) continue;
        NSString *fromUserName = message.fromUserName;
        NSString *toUserName   = message.toUserName;
        if ([fromUserName isEqualToString:toUserName]) continue;
        WXContact *contact = [self contactFromMsg:message];//陌生contact自动添加到缓存
        if (!contact) continue;
        
        [self resetContactToBeFirst:contact];
        
        //特殊消息处理
        if (message.msgType == MTypeImage || message.msgType == MTypeVideo) {
            UIImage *image = [WXCoreHelper imageWithURL:[NSURL URLWithString:message.msgThumbnailUrlStr]];
            message.imageW = image.size.width;
            message.imageH = image.size.height;
            [[SDImageCache sharedImageCache] storeImage:image forKey:message.msgThumbnailUrlStr];
        }else if(message.msgType == MTypeVoice){
            NSData *data = [THWebService dataWithUrl:[NSURL URLWithString:message.msgUrlStr]];
            [[[AppDelegate shareDelegate] cache] setObject:data forKey:message.msgUrlStr];
        }
        
        [self addMessage:message toAllMsgInfoWithContact:contact];
//        [self addAMsgToMessageInfoDicWithMsg:message UserName:keyUserName];
//        [[WXService shareInstance] readMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewMsgNotification object:self];
        
        
    }
   
}

#pragma mark - private

- (void)addContactsWithDic:(NSDictionary*)contactDic{
    [self addContactsWithDicsArray:@[contactDic]];
}
/**
 *  添加contacts，如果contact是自己则不添加，不重复添加，特殊类型(微信助手等)不添加
 *
 *  @param contact contact
 */
- (void)addContactsWithDicsArray:(NSArray *)contacts{
    
    for (NSDictionary *dic in contacts) {
        WXContact *contact =[self contactWithDic:dic];
        [self addContact:contact];
    }
}


/**
 *  添加Contact 到本地(contactsDic)，还包括nameContactDic,userNamesArray,namesSet
 *
 *  @param contact contact
 */
- (void)addContact:(WXContact*)contact{
    if (contact.contactType == TypeOther) return;
    if (contact.userName.length==0) return;
    if ([contact.userName isEqualToString:[[WXAccess access].owner objectForKey:@"UserName"]]) return;
    if ([self contactWithUserName:contact.userName]) return;
    if (contact.nickName.length==0 && contact.remarkName.length==0 && contact.displayName.length==0) return;
    
    //有username必有contact
    [self.contactsDic setObject:contact forKey:contact.userName];
   
    if (contact.contactType == TypeStranger) return;//Stranger 不添加到userNamesArray，nameContactDic
    if (contact.contactType == TypeGroup) {
        [self.userNamesArray insertObject:contact.userName atIndex:0];
    }else{
        [self.userNamesArray addObject:contact.userName];
    }
    
    if (contact.nickName.length>0) [self nameListAddName:contact.nickName UserName:contact.userName];
    if (contact.remarkName.length>0) [self nameListAddName:contact.remarkName UserName:contact.userName];
    
}

/**
 *  根据Message获取Contact，本地没有就去请求，然后添加大本地
 *
 *  @param message WXMessage
 *
 *  @return Contact
 */
- (WXContact*)contactFromMsg:(WXMessage*)message{
    WXContact *contact = nil;
    if (message.forwardFlag) {//自己不可能发到陌生人
        contact = [self contactWithUserName:message.toUserName];
        if (!contact){//本地没有
            NSDictionary *contactDic = [self.netService wxPostGroupWithUserName:message.toUserName];
            if (contactDic) {
                contact = [self contactWithDic:contactDic];
                [self addContact:contact];//添加contact
            }
            
        }
    } else {
        contact = [self contactWithUserName:message.fromUserName];
        if (!contact) {//本地没有
            NSDictionary *groupContactDic = [self.netService wxPostGroupWithUserName:message.fromUserName];
            contact = [self contactWithDic:groupContactDic];
            if (contact) {//可能来自群
                NSString *userNameInContent = [self userNameInContent:message.content];
                WXContact *contactInContent = [self contactWithUserName:userNameInContent];
                if (!contactInContent) {//本地没有，那是陌生人
                    NSDictionary *contactInContentDic = [self.netService wxPostStrangeWithUserName:userNameInContent EncryRoomId:contact.encryChatRoomId];
                    contactInContent = [self contactWithDic:contactInContentDic];
                    if (contactInContent) {
                        contactInContent.contactType = TypeStranger;
                        [self addContact:contactInContent];
                        message.contact = contactInContent;
                    }
                }
            }else{//也可能来自新添加的好友
                NSDictionary *contactDic = [self.netService wxPostStrangeWithUserName:message.fromUserName EncryRoomId:@""];
                contact = [self contactWithDic:contactDic];
            }
            if (contact) [self addContact:contact];//添加contact
        }
    }
    return contact;
}


/**
 *  把Contact重置到第一位
 *
 *  @param contact WXContact
 */
- (void)resetContactToBeFirst:(WXContact*)contact{
    if (!contact) return;
    if (contact.userName.length>0) {
        for (NSInteger i=0 ; i<self.userNamesArray.count; i++) {
            if ([contact.userName isEqualToString:self.userNamesArray[i]]) {
                if (i==0) break;//第一个就是，那么不用处理
                [self.userNamesArray removeObjectAtIndex:i];
                [self.userNamesArray addObject:contact.userName];
            }
        }
    }
}

/**
*  添加Message 到 ALLMessageInfo
*
*  @param message WXMessage
*  @param contact WXContact
*/
- (void)addMessage:(WXMessage*)message toAllMsgInfoWithContact:(WXContact*)contact{
    if (message && contact && contact.userName) {
        NSMutableArray *cuMsg = [self.allMsgInfo objectForKey:contact.userName];
        if (!cuMsg) {
            cuMsg = [NSMutableArray arrayWithObject:message];
            [self.allMsgInfo setObject:cuMsg forKey:contact.userName];
        }else {
            [cuMsg addObject:message];
        }
    }
}

/**
 *  添加名称到列表，用于语音识别词令。不重复添加
 *
 *  @param name name
 */
- (void)nameListAddName:(NSString*)name UserName:(NSString*)userName{
    if (![self.namesSet containsObject:name]) {
        [self.namesSet addObject:name];
       if (userName) [self.nameContactDic setObject:userName forKey:name];
    }
}

/**
 *  从群消息中提取发送人的username
 *
 *  @param content WXContact
 *
 *  @return userName
 */
- (NSString*)userNameInContent:(NSString*)content{
    if (content.length<15) return nil;
    NSString *brStr = @":<br/>";
    if ([content hasPrefix:@"@"] && [content containsString:brStr]) {
        NSRange range = [content rangeOfString:brStr];
        NSString *returnStr = [content substringToIndex:range.location];
        return returnStr;
    } else {
        return nil;
    }
}

/**
 *  WXContact 用数据词典初始化
 *
 *  @param dic NSDictionary
 *
 *  @return Contact or nil
 */
- (WXContact*)contactWithDic:(NSDictionary*)dic{
    if (!dic) return nil;
    return [[WXContact alloc] initWithDic:dic];
}



#pragma mark  method for init

/**
 *  Model 初始化时先初始化 基本数据Container
 */
- (void)basicInit{
    self.namesSet           = [NSMutableSet set];
    self.userNamesArray     = [NSMutableArray array];
    self.contactsDic        = [NSMutableDictionary dictionary];
    self.allMsgInfo         = [NSMutableDictionary dictionary];
    self.nameContactDic     = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessagesGeted:) name:kWXNetStateKey object:nil];
}

/**
 *  筛选出群，和其他新的未知的数据，用于生成再次请求详细数据的Json Array
 *
 *  @param charSetStr 第一次请求结果CharSet
 *  @param dics       第一次请求结果数据
 *
 *  @return Array 用作生成Json
 */
- (NSArray*)filterRequestNamesWithCharSet:(NSString*)charSetStr contactDics:(NSArray*)dics{
    NSArray *array = [self filterGroupsWithContactDics:dics];
    NSMutableSet *groupsSet = array[0];
    NSMutableSet *otherSets = array[1];
    NSArray *charSetsArray  = [charSetStr componentsSeparatedByString:@","];
    
    NSMutableSet *charSets  = [NSMutableSet setWithArray:charSetsArray];
    [charSets minusSet:groupsSet];
    [charSets minusSet:otherSets];
    
    if ([charSets containsObject:@"fmessage"]) [charSets removeObject:@"fmessage"];
    if ([charSets containsObject:@"filehelper"]) [charSets removeObject:@"filehelper"];
    if ([charSets containsObject:@"newsapp"]) [charSets removeObject:@"newsapp"];
    
    NSMutableArray *mutArray = [self.netService groupDicsWithUserNames:SGArrayWithSet(groupsSet)];
    [mutArray addObjectsFromArray:[self.netService unKnownFriendDicsWithUserNames:SGArrayWithSet(charSets)]];
    return mutArray;
    
}
/**
 *  获取初始化数据中的有关群的usernames，由于数据不全，所以要另做请求群信息，其他数据用作筛选
 *
 *  @param contactDics 第一次请求回来的所有数据
 *
 *  @return usernames NSSet
 */
- (NSArray*)filterGroupsWithContactDics:(NSArray*)contactDics{
    NSMutableSet *groupSet = [NSMutableSet set];
    NSMutableSet *otherSet = [NSMutableSet set];
    
    for (NSDictionary *dic in contactDics) {
        WXContact *contact = [self contactWithDic:dic];
        if (!contact || contact.userName.length==0) continue;
        
        if (contact.contactType == TypeGroup) {
            [groupSet addObject:contact.userName];
        }else{
            [otherSet addObject:contact.userName];
        }
    }
    NSArray *array = @[groupSet,otherSet];
    return array;
}




@end
