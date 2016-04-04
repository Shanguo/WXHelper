//
//  WXFriendsController.m
//  WXHelper
//
//  Created by 刘山国 on 16/2/29.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXFriendsController.h"
#import "WXChatRoomController.h"
#import "WXFriendsModel.h"
#import "WXContact.h"
#import "WXMessage.h"
#import "WXFriendCell.h"
#import "SGSoundVibrate.h"
#import "WXService.h"
#import "AppDelegate.h"
#import <YYCache.h>


@interface WXFriendsController ()<UITableViewDataSource,UITableViewDelegate,ChatRoomControllerDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableDictionary *messageInfo;
@property (nonatomic,strong) WXFriendsModel *model;
@property (nonatomic,assign) BOOL selfIsAppear;


@end

@implementation WXFriendsController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messageInfo = [NSMutableDictionary dictionary];
        self.model = [[WXFriendsModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"微信助手"];
    [self.view addSubview:self.tableView];
    
    [self.model onLoginRequest];
    [self.tableView reloadData];
    [[WXService shareInstance] startNewWorkService];
    [[WXService shareInstance] startVoiceServiceWithFriendsNames:self.model.friendsNames];
    [self registerNotifications];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.selfIsAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.selfIsAppear = NO;
}


#pragma mark - tableViewCell代理方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.model.list.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WXFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentity];
    
    WXContact *contact = [self.model contactAtIndex:indexPath.row];
    [cell setContact:contact];
    NSArray *messages = self.messageInfo[contact.userName];
    if (messages && messages.count>0){
        [cell setMessage:[messages lastObject]];
    }else{
        [cell setMessage:nil];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WXChatRoomController *chatRoomContro = [[WXChatRoomController alloc] init];
    chatRoomContro.contact = [self.model contactAtIndex:indexPath.row];
    NSMutableArray *msgList = [self.messageInfo objectForKey:chatRoomContro.contact.userName];
    if (!msgList) {
        msgList = [NSMutableArray array];
        [self.messageInfo setObject:msgList forKey:chatRoomContro.contact.userName];
    }
    chatRoomContro.msgList = msgList;
    chatRoomContro.delegate = self;
    [self.navigationController pushViewController:chatRoomContro animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Notification Listener

- (void)requestNewMessage:(NSNotification*)notification{
    if (![[WXService shareInstance] model]) [[WXService shareInstance] setModel:self.model];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
//        刷新SyncKey
        NSArray *newMessages = [WXCoreHelper receiveMessage];
        
        
        NSLog(@"meaage:%@",newMessages);
        for (NSDictionary *aMsg in newMessages){
            WXMessage *message = [[WXMessage alloc] initWithDic:aMsg];
            NSString *fromUserName = message.fromUserName;
            NSString *toUserName   = message.toUserName;
            if ([fromUserName isEqualToString:toUserName]) continue;
            
            if ([fromUserName isEqualToString:[[WXAccess access] userName]]) {//来自自己
                if ([weakSelf contactResolveWithUserName:toUserName WXMessage:message]) {
                    if (message.msgType == MTypeStatusNotify) {
                        [weakSelf addNewMessage:nil keyUserName:nil resetFirstWithUserName:toUserName];
                    }else{
                        message.forwardFlag = 1;
                        [weakSelf addNewMessage:message keyUserName:toUserName resetFirstWithUserName:toUserName];
                    }
                }
                
            }else{//来自他人
                if ([weakSelf contactResolveWithUserName:fromUserName WXMessage:message]) {
                    [weakSelf addNewMessage:message keyUserName:fromUserName resetFirstWithUserName:fromUserName];
                }
            }
            
        }
        
        //刷新消息
        if (self.selfIsAppear)
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    });
}


- (WXContact*)contactWithUserName:(NSString*)userName{
    WXContact *contact = [self.model contactWithUserName:userName];
    if (!contact) contact = [self.model postToGetUnknownContactWithUserName:userName];
    return contact;
}

- (WXContact*)contactResolveWithUserName:(NSString*)userName WXMessage:(WXMessage*)message{
    WXContact *contact = [self contactWithUserName:userName];
    if (!contact) return nil;
    if (contact.contactType == TypeGroup) {
        if (![[WXAccess access] isSelfWithUserName:message.fromUserName]) {
            NSString *userNameInGroup = [message userNameInGroupMsg];
            if (!userNameInGroup) {
                if (userName) [self.model resetContactToBeFirstWithUserName:userName];
                return nil;
            }
            WXContact *contentContact = [self contactWithUserName:userNameInGroup];
            if (!contentContact) return nil;
            message.contact = contentContact;
            [message contentGroupResolve];
        }
        
    }else if(contact.contactType == TypeFriend || contact.contactType == TypeStranger) {
        message.contact = contact;
        [message contentResolve];
    }else{
        return nil;
    }
    return contact;
}

- (void)addNewMessage:(WXMessage*)message keyUserName:(NSString*)keyUserName resetFirstWithUserName:(NSString*)userName{
    if (message && keyUserName) {
        if (message.msgType == MTypeImage || message.msgType == MTypeVideo) {
            UIImage *image = [WXCoreHelper imageWithURL:[NSURL URLWithString:message.msgThumbnailUrlStr]];
            message.imageW = image.size.width;
            message.imageH = image.size.height;
            [[SDImageCache sharedImageCache] storeImage:image forKey:message.msgThumbnailUrlStr];
        }else if(message.msgType == MTypeVoice){
            NSData *data = [THWebService dataWithUrl:[NSURL URLWithString:message.msgUrlStr]];
            [[[AppDelegate shareDelegate] cache] setObject:data forKey:message.msgUrlStr];
        }
        
        [self addAMsgToMessageInfoDicWithMsg:message UserName:keyUserName];
        [[WXService shareInstance] readMessage:message];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewMsgNotification object:self];
    }
    
   
    if (userName) [self.model resetContactToBeFirstWithUserName:userName];

}

- (void)serviceFaild:(NSNotification*)notification{
    NSLog(@"连接失败！");
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - private

- (void)chatRoomControllerOutWithUserName:(NSString *)userName hasNewMsg:(BOOL)hasNewMsg{
    if (hasNewMsg) {//排序
        [self.model resetContactToBeFirstWithUserName:userName];
        [self.tableView reloadData];
    }
}




- (void)addAMsgToMessageInfoDicWithMsg:(WXMessage*)message UserName:(NSString*)userName{
    NSMutableArray *cuMsg = [self.messageInfo objectForKey:userName];
    if (!cuMsg) {
        cuMsg = [NSMutableArray arrayWithObject:message];
        [self.messageInfo setObject:cuMsg forKey:userName];
    }else {
        [cuMsg addObject:message];
    }
}



- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMsgState object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLineConnectFail object:nil];
}

- (void)registerNotifications{
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestNewMessage:) name:kNewMsgState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceFaild:) name:kOnLineConnectFail object:nil];
}


#pragma mark - getter

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:FriendCellIdentity bundle:nil] forCellReuseIdentifier:FriendCellIdentity];
    }
    return _tableView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[AppDelegate shareDelegate] clearAllMemoryCache];
}

- (void)dealloc{
    [self removeNotifications];
}




@end
