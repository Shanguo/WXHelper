//
//  WXNetService.m
//  WXHelper
//
//  Created by 刘山国 on 16/4/2.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXNetService.h"

@interface WXNetService()

@property (nonatomic,strong) WXAccess       *access;
@property (nonatomic,assign) WXNetState     netState;
@property (nonatomic,assign) NSInteger      counter;

@end

@implementation WXNetService

/**
 *  单例模式
 *
 *  @return NetService 单例
 */
+ (instancetype)shareInstance{
    static WXNetService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[WXNetService alloc] init];
    });
    return service;
}

/**
 *  Step 1. 获取扫描登陆二维码
 */
- (void)wxStartRequestCodeImage{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //获得会话ID-UUID
        NSString *uuid = [WXCoreHelper wxUUID];
        if (uuid)
        {
            //获得二维码
            UIImage *image = [WXCoreHelper qrCode:uuid];
            if (image)
            {
                //已经获取到二维码，等待扫描
                [self postAState:StateGetCodeImage withInfo:image forKey:kWXCodeImageKey];
                //轮询服务器登录状态
                while (YES)
                {
                    int state = 0;
                    NSString *loginPage = [WXCoreHelper loginPage:uuid state:&state];
                    if (loginPage){
                        //最终登录获得uin和sid
                        self.access = [WXCoreHelper login:loginPage];
                        [WXCoreHelper webwxstatreport:uuid];
                        break;//跳出轮询状态
                    }
                    if (state == 201){
                        //二维码扫描成，等待确认
                        [self postState:StateHasScanCode];
                    }
                    sleep(1);
                }
            }
        }else{
            //未得到UUID
            [self postState:StateNotGetAccess];
            return ;
        }
        
        if (!self.access){
            //登录失败
            [self postState:StateNotGetAccess];
        }else{
            //手机已经确认登陆
            [self postState:StatePhoneHadMakeSureLogin];
        }
    });
    
 
}
/**
 *  Step 2. 登陆成功加载好友信息
 */
- (void)wxOnLoginRequest:(NSArray* (^)(NSArray *contactDics,NSString *charSetStr))initResult GroupsOtherPostResult:(void (^)(NSArray *groupAndOthers))groupsAndOthersResult AllFriens:(void (^)(NSArray *allFriendsDics))allFriendsResult{
    //第五步，init 获得基础的信息
    NSDictionary *wxInfo  = [WXCoreHelper wxInit];
    NSArray *commonContacts = [wxInfo objectForKey:@"ContactList"];
    NSString *chatSetStr = [wxInfo objectForKey:@"ChatSet"];
    NSArray *postRequestArray = initResult(commonContacts,chatSetStr);

    //第六步,第一次POST Groups
    NSArray *groupsAndOther = [WXCoreHelper postGroupWithCount:postRequestArray.count JsonStr:SGJsonStringWithObj(postRequestArray)];
    groupsAndOthersResult(groupsAndOther);

    //第七步，与服务器同步
    [WXCoreHelper receiveMessage];
  
    //第八步，获得所有的联系人
    NSArray *allFriendsAndOthers = [WXCoreHelper allFriendsOthers];
    allFriendsResult(allFriendsAndOthers);
   
    //第九步， notify
    [WXCoreHelper webwxstatusnotify];

    //Step 3. 登陆轮询
    [self wxStartMaintainOnLineService];
}

/**
 *  Step 3. 登陆后状态轮询
 */
- (void)wxStartMaintainOnLineService{
    self.counter = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //保持在线状态,并轮询信息
        while (self.netState) {
            int state = [WXCoreHelper synccheck];
            if (state <-1 || state>7){
                [self postState:StateFail];
            }else if(state == 0){
                self.counter = 0;
                NSLog(@"正常长连接状态");
            }else if (state == 2){
                self.counter = 0;
                [self wxRequestNewMessage];
                NSLog(@"有新消息状态");
            }else if (state == 6){
                self.counter++;
                NSLog(@"进入消息状态6");
                if (self.counter>4) {
                    [self postState:StateFail];
                }
            }else if (state == 7){
                self.counter++;
                if(self.counter<=3){
                    NSLog(@"刚登陆正在检查状态");
                }else if (self.counter>3) {
                    [self postState:StateFail];
                }else{
                    NSLog(@"手机微信进入聊天界面");
                }
            }
            sleep(2);
        }
        
        
    });
}

/**
 *  Step 4. 请求新消息
 */
- (void)wxRequestNewMessage{
//    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *newMessages = [WXCoreHelper receiveMessage];
        [self postAState:StateHasNewMessage withInfo:newMessages forKey:kWXNewMsgKey];
    });
}

- (NSDictionary*)wxPostGroupWithUserName:(NSString*)userName{
    return [[self postGroupWithUserNames:@[userName]] firstObject];
}
- (NSArray*)postGroupWithUserNames:(NSArray*)userNames{
    NSArray *requstArray = [self groupDicsWithUserNames:userNames];
    NSArray *groupsAndOther = [WXCoreHelper postGroupWithCount:requstArray.count JsonStr:SGJsonStringWithObj(requstArray)];
    return groupsAndOther;
}

- (NSDictionary*)wxPostStrangeWithUserName:(NSString*)userName EncryRoomId:(NSString*)anId{
    return [[self postStrangeWithUserNames:@[userName] EncryRoomIds:@[anId]] firstObject];
}

- (NSArray*)postStrangeWithUserNames:(NSArray*)userNames EncryRoomIds:(NSArray*)theIds{
    NSArray *requestArray = [self strangeFriendsWithUserNames:userNames EncryRoomIds:theIds];
    NSArray *resultArray = [WXCoreHelper postGroupWithCount:requestArray.count JsonStr:SGJsonStringWithObj(requestArray)];
    return resultArray;
}



#pragma mark - private 

- (void)postState:(WXNetState)aState{
    [self postAState:aState withInfo:nil forKey:nil];
}

- (void)postAState:(WXNetState)aState withInfo:(id)obj forKey:(NSString*)key{
    self.netState = aState;
    NSDictionary *dic;
    if (!obj || ! key) {
        dic = @{kWXNetStateKey:@(aState)};
    }else{
        dic = @{kWXNetStateKey:@(aState),key:obj};
    }
    SGPostNotificationWithName(kWXNetStateKey, self, dic);
}


#pragma mark - 请求相关参数生成
- (NSArray*)strangeFriendWithUserName:(NSString*)userName EncryRoomId:(NSString*)anId{
    return [self strangeFriendsWithUserNames:@[userName] EncryRoomIds:@[anId]];
}

/**
 *  请求群中的非好友，保证usernames 与 ids 对应非空
 *
 *  @param userNames array
 *  @param theIds    array
 */
- (NSArray*)strangeFriendsWithUserNames:(NSArray*)userNames EncryRoomIds:(NSArray*)theIds{
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = MIN(userNames.count, theIds.count);
    for (int i = 0; i<count; i++) {
        NSString *userName = userNames[i];
        NSString *anId     = theIds[i];
        if (userName.length>0 && anId.length>0) [array addObject:@{@"UserName":userName,@"EncryChatRoomId":anId}];
    }
    return array;
}

- (NSMutableArray*)unKnownFriendDicsWithUserNames:(NSArray*)userNames{
    return [self dicsWithUserNames:userNames key:@"EncryChatRoomId" value:@""];
}

- (NSArray*)groupDicsWithUserName:(NSString*)userName{
    return [self groupDicsWithUserNames:@[userName]];
}

- (NSMutableArray*)groupDicsWithUserNames:(NSArray*)userNames{
    return [self dicsWithUserNames:userNames key:@"ChatRoomId" value:@""];
}

- (NSMutableArray*)dicsWithUserNames:(NSArray*)userNames key:(NSString*)key value:(NSString*)value{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:userNames.count];
    for (NSString *username in userNames) {
        if (username.length>0) {
            NSDictionary *dic = @{@"UserName":username,key:value};
            [array addObject:dic];
        }
    }
    return array;
}


@end
