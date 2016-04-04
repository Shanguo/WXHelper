//
//  WXLoginViewController.m
//  WXHelper
//
//  Created by 刘山国 on 16/2/28.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXLoginViewController.h"
#import "WXAccess.h"
#import "AppDelegate.h"
#import "WXFriendsController.h"
#import "WXService.h"
#import "WXNetService.h"

@interface WXLoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *retryConnectBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (nonatomic,strong) WXAccess *access;

@end

@implementation WXLoginViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.imageView.image = [UIImage imageNamed:@"weixin"];
    [[AppDelegate shareDelegate] clearAllCache];
    NSLog(@"apprear");
    [self.tipsLabel setText:@"请等待服务器响应..."];
//    [[WXNetService shareInstance] wxStartRequestCodeImage];
    [self startWebWx];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"disappear");
}

- (void)dealloc{
    [self removeNotifications];
}

#pragma mark - NetState Notification

- (void)wxStartRequestCodeImageResult:(NSNotification*)notification{
    WXNetState theState = [[notification.userInfo objectForKey:kWXNetStateKey] integerValue];
    if (!theState) return;
    switch (theState) {
        case StateGetCodeImage:{
            [self.tipsLabel setHighlighted:NO];
            [self.retryConnectBtn setHighlighted:YES];
            UIImage *image = [[notification userInfo] objectForKey:kWXCodeImageKey];
            [self.imageView setImage:image];
            [self.tipsLabel setText:@"请使用微信手机客户端扫描登录！"];
            break;
        }
        case StateNotGetAccess:{
            NSLog(@"未获取到access");
            [self.tipsLabel setHidden:YES];
            [self.retryConnectBtn setHidden:NO];
            [self.tipsLabel setText:@"请等待服务器响应..."];
            break;
        }
        case StateHasScanCode:{
            [self.tipsLabel setText:@"成功扫描，请在手机上确认登录！"];
            break;
        }
        case StatePhoneHadMakeSureLogin:{
            [self.tipsLabel setText:@"正在登录..."];
            [self pushToFriendsVC];
            break;
        }
        case StateNotGetUUID:{
            [self.tipsLabel setHidden:YES];
            [self.retryConnectBtn setHidden:NO];
            [self.tipsLabel setText:@"请等待服务器响应..."];
            break;
        }
        default:
            break;
    }
}

- (void)serviceFaild:(NSNotification*)notification{
    
    [[WXNetService shareInstance] wxStartRequestCodeImage];
}


#pragma mark - private 

- (void)pushToFriendsVC{
    WXFriendsController *friendsVC = [[WXFriendsController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:friendsVC];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOnLineConnectFail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kWXNetStateKey object:nil];
}

- (void)registerNotifications{
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceFaild:) name:kOnLineConnectFail object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxStartRequestCodeImageResult:) name:kWXNetStateKey object:nil];
}



#pragma mark - memery warning

- (void)didReceiveMemoryWarning {
    [[AppDelegate shareDelegate] clearAllMemoryCache];
    [super didReceiveMemoryWarning];
}



- (void)startWebWx{

    [self.tipsLabel setText:@"请等待服务器响应..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //获得会话ID-UUID
        NSString *uuid = [WXCoreHelper wxUUID];
        if (uuid)
        {
            //获得二维码
            UIImage *image = [WXCoreHelper qrCode:uuid];
            if (image)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tipsLabel setHighlighted:NO];
                    [self.retryConnectBtn setHighlighted:YES];
                    [self.imageView setImage:image];
                    [self.tipsLabel setText:@"请使用微信手机客户端扫描登录！"];
                });

                //轮询服务器登录状态
                while (YES)
                {
                    int state = 0;
                    NSString *loginPage = [WXCoreHelper loginPage:uuid state:&state];
                    if (loginPage)
                    {
                        //最终登录获得uin和sid
                        self.access = [WXCoreHelper login:loginPage];
                        [WXCoreHelper webwxstatreport:uuid];
                        break;//跳出轮询状态
                    }
                    if (state == 201)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tipsLabel setText:@"成功扫描，请在手机上确认登录！"];
                        });
                    }
                    sleep(1);
                }
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tipsLabel setHidden:YES];
                [self.retryConnectBtn setHidden:NO];
            });

        }

        if (!self.access)
        {
            //登录失败
            dispatch_async(dispatch_get_main_queue(), ^{
                SGHud(@"与服务器连接失败！");
                [self.tipsLabel setHidden:YES];
                [self.retryConnectBtn setHidden:NO];
            });
        }else
        {
            //登录成功
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tipsLabel setText:@"正在登录..."];
                [self pushToFriendsVC];
            });
        }
    });
}

@end
