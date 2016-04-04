//
//  WXChatRoomController.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/1.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXChatRoomController.h"
#import "WXContact.h"
#import "WXMessage.h"
#import "SGMessageBar.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import <YYCache.h>
#import "SGImageBrowser.h"
#import "VedioPlayViewController.h"

#define kTextFont [UIFont systemFontOfSize:14]
#define kBackGroundColor RGB(240, 240, 240)
#define kMessageBarColor RGB(224, 224, 224)
static CGFloat const kMessageBarH = 35.0f;
static CGFloat const kTextBubbleW = 180.0f;
static CGFloat const kHeadImageWH = 35.0f;
static CGFloat const kLRSpace     = 10.0f;
static CGFloat const kUDSpace     = -5.0f;
static CGFloat const kVoiceH      = 54.0f;
static CGFloat const kVoiceBaseW  = 66.0f;

@interface WXChatRoomController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIScrollViewDelegate,SGMessageBarDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) SGMessageBar *messageBar;
@property (nonatomic,assign) BOOL isHasSendMsg;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;


@end

@implementation WXChatRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.cache = [[AppDelegate shareDelegate] cache];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.messageBar];
    NSString *friendName;
    if (self.contact.remarkName.length>0) {
        friendName = self.contact.remarkName;
    }else{
        friendName = self.contact.nickName;
    }
    [self.navigationItem setTitle:friendName];
    
    //注册通知
    [self registerNotification];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    self.tableView.userInteractionEnabled = YES;
    [self.tableView addGestureRecognizer:singleTap];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadTableView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatRoomControllerOutWithUserName:hasNewMsg:)]) {
            [self.delegate chatRoomControllerOutWithUserName:self.contact.userName hasNewMsg:self.isHasSendMsg];
        }
    }
    
}


#pragma mark - tableViewCell代理方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.msgList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WXMessage *message = [self.msgList objectAtIndex:indexPath.row];
    if (message.msgType == MTypeImage || message.msgType == MTypeVideo) {
        CGFloat ratio = message.imageW/message.imageH;
        CGFloat width = [self constructWidthWithWHRatio:ratio realWidth:message.imageW];
        if (width<0.5) width = message.imageW;
        return width/ratio+15;
    }else if(message.msgType == MTypeVoice){
        CGRect rect = SGWordsRect(kTextBubbleW, @"哈哈", kTextFont);
        return rect.size.height+45;
    }else{
        CGRect rect = SGWordsRect(kTextBubbleW, message.content, kTextFont);
        return rect.size.height+45;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentity = @"MSGCELL";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kBackGroundColor;
    }else{
        for (UIView *cellView in cell.subviews){
            [cellView removeFromSuperview];
        }
    }
    //设置服务器的数据
    WXMessage *message = self.msgList[indexPath.row];
    
    //创建头像
    BOOL isSelf = (BOOL)message.forwardFlag;
    CGFloat x;
    UIImage *headImage;
    if (isSelf) {
        x = SCREEN_WIDTH-kHeadImageWH-kLRSpace;
        headImage = [[WXAccess access] headImage];
    }else{
        x = kLRSpace;
        headImage = message.contact.headImage;
    }
    UIImageView *photo = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, kHeadImageWH, kHeadImageWH)];
    [photo setImage:headImage];
    [cell addSubview:photo];
    
    //设置内容
    if (message.msgType == MTypeText) {
        [cell addSubview:[self textBubbleViewWithMsg:message]];
    }else if (message.msgType == MTypeVoice){
        [cell addSubview:[self voiceBubbleViewWithMsg:message indexRow:indexPath.row]];
    }else if (message.msgType == MTypeImage || message.msgType == MTypeVideo){
        UIView *view = [self imageVedioViewWithMessage:message indexRow:indexPath.row];
        if (view) [cell addSubview:view];
    }
    
    return cell;
}



#pragma mark - action

- (void)btnClick:(UIButton*)btn{
    NSError *error = nil;
    WXMessage *message = self.msgList[btn.tag];
    NSData *data = (NSData*)[[[AppDelegate shareDelegate] cache] objectForKey:message.msgUrlStr];
    if (data) {
        if (self.audioPlayer.isPlaying) [self.audioPlayer stop];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        [self.audioPlayer play];
    }
}


- (void)imageTouched:(UIGestureRecognizer*)gesture{
    UIImageView *imageView = (UIImageView*)gesture.view;
    WXMessage *message = self.msgList[imageView.tag];
    if (message.msgType == MTypeImage) {
        [SGImageBrowser showImageView:imageView biggerImageUrl:message.msgUrlStr canBeSaved:NO];
    }else if(message.msgType == MTypeVideo){
        VedioPlayViewController *playerViewController = [[VedioPlayViewController alloc] initWithContentURL:[NSURL URLWithString:message.msgUrlStr]];
        [self presentMoviePlayerViewControllerAnimated:playerViewController];
    }
}

- (void)onGetNewMsg:(NSNotification*)notification{
    [self reloadTableView];
}



#pragma mark delegate

- (void)sgMessageBarClickSendBtn:(UIButton *)sendBtn withText:(NSString *)text{
  
    if (!text) return;
    WXMessage *message = [[WXMessage alloc] initWithSendTextMsg:text ToUserName:self.contact.userName];
    [WXCoreHelper sendTextMsg:text ToUserName:self.contact.userName Result:^(BOOL success) {
        if (success) {
            [self.msgList addObject:message];
            self.isHasSendMsg = YES;
            //刷新消息
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadTableView];
            });
        }
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideKeyboard];
}

#pragma mark - private

- (void)hideKeyboard{
    [self.messageBar resignFirstResponder];
}


- (void)reloadTableView{
    
    //刷新消息
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1、刷新表格
        [self.tableView reloadData];
        // 2、滚动至当前行
        if (self.msgList.count>3) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.msgList.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
    
    

}

- (void)registerNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetNewMsg:) name:kNewMsgNotification object:nil];
}
- (void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMsgNotification object:nil];
}

#pragma mark - getter

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-kMessageBarH)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = kBackGroundColor;
    }
    return _tableView;
}

- (SGMessageBar *)messageBar{
    if (!_messageBar) {
        _messageBar = [[SGMessageBar alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-kMessageBarH, SCREEN_WIDTH, kMessageBarH)];
        _messageBar.delegate = self;
        _messageBar.clearInputWhenSend = YES;
        _messageBar.resignFirstResponderWhenSend = YES;
        _messageBar.backgroundColor = kMessageBarColor;
    }
    return _messageBar;
   
}

//泡泡文本
- (UIView *)textBubbleViewWithMsg:(WXMessage*)message{
    
    CGFloat aSpace = 30.0f;
    
    //计算大小
    CGRect rect = SGWordsRect(kTextBubbleW, message.content, kTextFont);
    CGSize size = rect.size;
    
    // build single chat bubble cell with given text
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    returnView.backgroundColor = [UIColor clearColor];
    
    //背影图片
    UIImage *bubble = [UIImage imageNamed:message.forwardFlag?@"SenderAppNodeBkg_HL":@"ReceiverTextNodeBkg"];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height/2)]];

    //添加文本信息
    UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(message.forwardFlag?15.0f:22.0f, 20.0f, size.width+10, size.height+10)];
    bubbleText.backgroundColor = [UIColor clearColor];
    bubbleText.font = kTextFont;
    bubbleText.numberOfLines = 0;
    bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
    bubbleText.text = message.content;
    
    bubbleImageView.frame = CGRectMake(0.0f, 14.0f, bubbleText.frame.size.width+aSpace, bubbleText.frame.size.height+20.0f);
    
    if(message.forwardFlag)
        returnView.frame = CGRectMake(SCREEN_WIDTH-widthOf(bubbleImageView)-kLRSpace-kHeadImageWH-kLRSpace/4, kUDSpace, bubbleText.frame.size.width+aSpace, bubbleText.frame.size.height+aSpace);
    else
        returnView.frame = CGRectMake(kLRSpace+kHeadImageWH+kLRSpace/4, kUDSpace, bubbleText.frame.size.width+aSpace, bubbleText.frame.size.height+aSpace);
    
    [returnView addSubview:bubbleImageView];
    [returnView addSubview:bubbleText];
    
    return returnView;
}

//泡泡语音
- (UIView *)voiceBubbleViewWithMsg:(WXMessage*)message indexRow:(NSInteger)indexRow{
    
    //根据语音长度
    int yuyinwidth = kVoiceBaseW+message.voiceLength*2;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = indexRow;
    if(message.forwardFlag)
        button.frame =CGRectMake(SCREEN_WIDTH-yuyinwidth-kLRSpace-kHeadImageWH-kLRSpace/4, 6, yuyinwidth, kVoiceH);
    else
        button.frame =CGRectMake(kLRSpace+kHeadImageWH+kLRSpace/4,6, yuyinwidth, kVoiceH);
    
    //image偏移量
    UIEdgeInsets imageInsert;
    imageInsert.top = -10;
    imageInsert.left = message.forwardFlag?button.frame.size.width/3:-button.frame.size.width/3;
    button.imageEdgeInsets = imageInsert;
    
    [button setImage:[UIImage imageNamed:message.forwardFlag?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
    UIImage *backgroundImage = [UIImage imageNamed:message.forwardFlag?@"SenderVoiceNodeDownloading":@"ReceiverVoiceNodeDownloading"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(message.forwardFlag?-30:button.frame.size.width, 0, 30, button.frame.size.height)];
    label.text = [NSString stringWithFormat:@"%ld''",(long)message.voiceLength];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [button addSubview:label];
    
    return button;
}

//泡泡图片，视频

- (UIView *)imageVedioViewWithMessage:(WXMessage*)message indexRow:(NSInteger)indexRow{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.tag = indexRow;
    UIImage *image = [WXCoreHelper readImageFromCacheWithUrlStr:message.msgThumbnailUrlStr];
    if (!image) return nil;

    imageView.image = image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat ratio = width/height;
    width = [self constructWidthWithWHRatio:ratio realWidth:width];
    if (width<0.1) width = image.size.width;
    height = width/ratio;
    CGFloat x= kLRSpace+kHeadImageWH+kLRSpace, y=10;
    if (message.forwardFlag) {
        x = SCREEN_WIDTH - x - width;
    }
    imageView.frame = CGRectMake(x, y, width, height);
    [imageView setCircleRadius:8];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTouched:)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:singleTap];
    
    return imageView;
}



- (CGFloat)constructWidthWithWHRatio:(CGFloat)ratio realWidth:(CGFloat)width{

    if (ratio>1) {
        if (width>200) width = 200;
    }else if(ratio>0.5){
        if (width>160) width = 160;
    }else{
        if (width>70) width = 70;
    }
    return width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[AppDelegate shareDelegate] clearAllMemoryCache];
}

-(void)dealloc{
    [self removeNotification];
}



@end
