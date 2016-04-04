//
//  WXFriendsModel.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/4.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXFriendsModel.h"
#import "WXContact.h"

@interface WXFriendsModel()

@property (nonatomic,strong) NSMutableSet *others;
@property (nonatomic,strong) NSMutableSet *groups;
@property (nonatomic,strong) NSMutableSet *friends;
@property (nonatomic,strong) NSMutableDictionary *contactsDic;//key是UserName
@property (nonatomic,strong) NSMutableDictionary *namesForContactDic;//key是nickname，remarkname等
@property (nonatomic,strong) NSMutableSet *namesList;


@property (nonatomic,strong) NSMutableArray *aRememberList;


@end

@implementation WXFriendsModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.others             = [NSMutableSet set];
        self.groups             = [NSMutableSet set];
        self.friends            = [NSMutableSet set];
        self.list               = [NSMutableArray array];
        self.contactsDic        = [NSMutableDictionary dictionary];
        self.namesForContactDic = [NSMutableDictionary dictionary];
        self.namesList          = [NSMutableSet set];
    }
    return self;
}

#pragma mark - public add

/**
 *  init 并 add 与普通add不同，因为过滤群，记录群留待其他请求
 *
 *  @param contacts Dics 请求结果词典
 */
- (void)initAddContactsWithDicsArray:(NSArray*)contacts{
    self.aRememberList = [NSMutableArray array];
    for (NSDictionary *dic in contacts) {
        WXContact *contact = [[WXContact alloc] initWithDic:dic];
        if (contact.contactType == TypeGroup) {
            if(contact.userName.length>0) [self.aRememberList addObject:contact.userName];
            continue;
        }
        [self addWithContact:contact];
    }
}

/**
 *  普通add,添加联系人
 *
 *  @param contacts 联系人数组
 */
- (void)addContactsWithDicsArray:(NSArray *)contacts{
    for (NSDictionary *dic in contacts) {
        WXContact *contact = [[WXContact alloc] initWithDic:dic];
        [self addWithContact:contact];
    }
}




#pragma mark - public read
/**
 *  根据index获取Contact, for tableView
 *
 *  @param index NSInteger
 *
 *  @return contact
 */
- (WXContact*)contactAtIndex:(NSUInteger)index{
    if (self.list.count <= index) return nil;
    NSString *username = self.list[index];
    return [self contactWithUserName:username];
}

/**
 *  根据username获取contact
 *
 *  @param username username
 *
 *  @return contact
 */
- (WXContact*)contactWithUserName:(NSString*)username{
    return [self.contactsDic objectForKey:username];
}

/**
 *  获取contact，根据nickname或者remarkname或者displayname
 *
 *  @param name nickname or remarkname or displayname
 *
 *  @return WXContact
 */
- (WXContact*)contactWithName:(NSString*)name{
    return [self.namesForContactDic objectForKey:name];
}

/**
 *  所有群，好友，非好友的nickname，remarkname,displayname
 *
 *  @return NSSet
 */
- (NSSet*)friendsNames{
    return self.namesList;
}


#pragma mark - public ordered

/**
 *  将最新聊天对象重置到第一位
 *
 *  @param aUserName username
 *
 *  @return Contact
 */
- (WXContact*)resetContactToBeFirstWithUserName:(NSString*)aUserName{
    if (!aUserName) return nil;
    WXContact *contact = [self.contactsDic objectForKey:aUserName];
    if (!contact) return nil;

    for (int i = 0; i<self.list.count; i++) {
        NSString *userName = self.list[i];
        if ([userName isEqualToString:aUserName]) {
            [self.list removeObjectAtIndex:i];
            [self.list insertObject:userName atIndex:0];
        }
    }
    for (NSString *userName in self.others) {
        if ([userName isEqualToString:aUserName]) {
            [self.list insertObject:userName atIndex:0];
        }
    }
    return contact;
    
}



#pragma mark - public netword init
/**
 *  登陆成功加载好友信息
 */
- (void)onLoginRequest{
    //第五步，init 获得基础的信息
    NSDictionary *wxInfo  = [WXCoreHelper wxInit];
    NSArray *commonContacts = [wxInfo objectForKey:@"ContactList"];
    [self initAddContactsWithDicsArray:commonContacts];
    NSString *chatSetStr = [wxInfo objectForKey:@"ChatSet"];
    
    NSArray *postRequestArray = [self filterChatSet:chatSetStr];
    
    //第六步,第一次POST Groups
    NSArray *groupsAndOther = [WXCoreHelper postGroupWithCount:postRequestArray.count JsonStr:[self postGroupsJsonWithUserNameArray:postRequestArray]];
    [self addContactsWithDicsArray:groupsAndOther];
    
    //第七步，与服务器同步
    [WXCoreHelper receiveMessage];
    
    
    //第八步，获得所有的联系人
    NSArray *allFriensAndOthers = [WXCoreHelper allFriendsOthers];
    [self addContactsWithDicsArray:allFriensAndOthers];
    
    //第九步， notify
    [WXCoreHelper webwxstatusnotify];
    
    [self listGroupFriends];
}

/**
 *  根据username请求自己所在的群，或者请求自己的好友，非好友不可用词方法实现
 *
 *  @param userName username
 *
 *  @return Contact
 */
- (WXContact*)postToGetUnknownContactWithUserName:(NSString*)userName{
    NSArray *groupsArray = [WXCoreHelper postGroupWithCount:1 JsonStr:[self postGroupsJsonWithUserNameArray:@[userName]]];
    if (groupsArray.count>0) {
        NSDictionary *infoDic = groupsArray[0];
        WXContact *contact = [[WXContact alloc] initWithDic:infoDic];
        [self addContactsWithDicsArray:groupsArray];
        [self.list insertObject:contact.userName atIndex:0];
        return contact;
    }
    return nil;
}


#pragma mark - private
/**
 *  生成去请求的json string
 *
 *  @param userNames 数组usernames
 *
 *  @return 去请求的json string
 */
- (NSString*)postGroupsJsonWithUserNameArray:(NSArray*)userNames{
    NSMutableString *mulStr = [NSMutableString stringWithString:@"["];
    for (NSString *userName in userNames) {
        NSString *string;
        BOOL flag = NO;
        for (NSString *oldGroupName in self.aRememberList) {
            if ([oldGroupName isEqualToString:userName]){
                flag = YES;
                string = [NSString stringWithFormat:@"{\"UserName\":\"%@\",\"ChatRoomId\":\"\"},",userName];
                [mulStr appendString:string];
                [self.aRememberList removeObject:oldGroupName];
                break;
            }
        }
        if (flag) continue;
        
        string = [NSString stringWithFormat:@"{\"UserName\":\"%@\",\"EncryChatRoomId\":\"\"},",userName];
        [mulStr appendString:string];
    }
    
    NSRange range ;
    range.location = mulStr.length-1;
    range.length = 1;
    [mulStr deleteCharactersInRange:range];
    
    [mulStr appendString:@"]"];
    return mulStr;
    
}



- (NSArray*)filterChatSet:(NSString*)chatSetStr{
    NSMutableArray *multableArray = [NSMutableArray array];
    NSArray *array = [chatSetStr componentsSeparatedByString:@","];
    for (NSString *userName in array) {
        if ([userName isEqualToString:@"fmessage"]) continue;
        if (userName.length==0) continue;
        
        //设个标记
        BOOL flag = NO;
        for (NSString *aUserName in self.others) {
            if ([aUserName isEqualToString:userName])  {
                flag = YES;
                break;
            }
        }
        
        if (flag) continue;
        
        for (NSString *aUserName in self.friends) {
            if ([aUserName isEqualToString:userName])  {
                flag = YES;
                break;
            }
        }
        
        if (flag) continue;
        
        [multableArray addObject:userName];
        
    }
    
    return [multableArray copy];
    
}

- (NSArray *)fileterOrderedNamesList:(NSString*)namesStr{
    NSArray *namesArray = [namesStr componentsSeparatedByString:@","];
    NSMutableArray *mutNamesArray = [NSMutableArray arrayWithArray:namesArray];
    for (NSString *username  in mutNamesArray) {
        BOOL flag = NO;
        for (NSString *aUserName in self.groups) {
            if ([aUserName isEqualToString:username]) {
                [mutNamesArray removeObject:username];
                flag = YES;
                break;
            }
        }
        
        if (flag) continue;
        
        for (NSString *aUserName in self.others) {
            if ([aUserName isEqualToString:username]) {
                [mutNamesArray removeObject:username];
                flag = YES;
                break;
            }
        }
        
        if (flag) continue;
        
        for (NSString *aUserName in self.friends) {
            if ([aUserName isEqualToString:username]) {
                [mutNamesArray removeObject:username];
                flag = YES;
                break;
            }
        }
        
    }
    
    return [mutNamesArray copy];
   
}

- (void)listGroupFriends{
    for (NSString *aUserName in self.groups) {
        WXContact *contact = [self.contactsDic objectForKey:aUserName];
        if (contact.remarkName.length>0 || contact.nickName.length>0) [self.list addObject:contact.userName];
    }
    
    for (NSString *aUserName in self.friends) {
        WXContact *contact = [self.contactsDic objectForKey:aUserName];
        if (contact.remarkName.length>0 || contact.nickName.length>0)[self.list addObject:contact.userName];
    }
}

- (void)listWithOrderNames:(NSArray*)userNames{
    for (NSString *username in userNames) {
        if (username.length==0) continue;
        BOOL flag = NO;
        for (NSString *aUserName in self.groups) {
            if ([aUserName isEqualToString:username]) {
                [self.list addObject:aUserName];
                flag = YES;
                break;
            }
        }
        if (flag) continue;
        for (NSString *aUserName in self.others) {
            if ([aUserName isEqualToString:username]) {
                [self.list addObject:aUserName];
                flag = YES;
                break;
            }
        }
        if (flag) continue;
        for (NSString *aUserName in self.friends) {
            if ([aUserName isEqualToString:username]) {
                [self.list addObject:aUserName];
                flag = YES;
                break;
            }
        }
        
    }
}

/**
 *  添加一个contact，如果contact是自己则不添加，不重复添加，
 *
 *  @param contact contact
 */
- (void)addWithContact:(WXContact*)contact{
    if (contact.userName.length==0) return;
    if ([contact.userName isEqualToString:[[WXAccess access].owner objectForKey:@"UserName"]]) return;
    if ([self isHadContactWithUserName:contact.userName]) return;
    if (contact.contactType == TypeOther ) {
        [self.others addObject:contact.userName];
    }else if (contact.contactType == TypeGroup ){
        [self.groups addObject:contact.userName];
    }else if (contact.contactType == TypeFriend ){
        [self.friends addObject:contact.userName];
    }
    //有username必有contact
    [self.contactsDic setObject:contact forKey:contact.userName];
    if (contact.nickName.length>0) {
        [self.namesForContactDic setObject:contact forKey:contact.nickName];
        if (contact.contactType != TypeOther) [self nameListAddName:contact.nickName];
    }
    if (contact.remarkName.length>0) {
        [self.namesForContactDic setObject:contact forKey:contact.remarkName];
        if (contact.contactType != TypeOther) [self nameListAddName:contact.remarkName];
    }
    if (contact.displayName.length>0){
        [self.namesForContactDic setObject:contact forKey:contact.displayName];
        if (contact.contactType != TypeOther) [self nameListAddName:contact.displayName];
    }
}

/**
 *  添加名称到列表，用于语音识别词令。不重复添加
 *
 *  @param name name
 */
- (void)nameListAddName:(NSString*)name{
    if (![self.namesList containsObject:name]) {
        [self.namesList addObject:name];
    }
}


/**
 *  是否有该用户
 *
 *  @param username username
 *
 *  @return BOOL
 */
- (BOOL)isHadContactWithUserName:(NSString*)username{
    if ([self.contactsDic objectForKey:username]) return YES;
    return NO;
}


@end
