//
//  WXService.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/9.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXService.h"
#import "WXAudio.h"
#import "iflyMSC/iflyMSC.h"
#import "TTSConfig.h"
#import "WXMessage.h"
#import "WXContact.h"
#import "WXFriendsModel.h"
#import "AppDelegate.h"
#import "YYCache.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define NAME        @"userwords"
#define USERWORDS   @"{\"userword\":[{\"name\":\"我的常用词\",\"words\":[\"成时\",\"郭波\",\"高兰路\",\"复联二\"]},{\"name\":\"我的好友\",\"words\":[\"李馨琪\",\"鹿晓雷\",\"张集栋\",\"周家莉\",\"叶震珂\",\"熊泽萌\"]}]}"

static NSString * const kSendMsgTo      = @"发消息给";
static NSString * const kSendMsgToQun  = @"发消息到群";

@interface WXService()<IFlySpeechSynthesizerDelegate,IFlySpeechRecognizerDelegate,AVAudioPlayerDelegate>

@property (nonatomic,assign) BOOL       connectedOK;
@property (nonatomic,assign) NSInteger counter;
@property (nonatomic,strong) IFlySpeechRecognizer *iflyRecognizer;
@property (nonatomic,strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象
@property (nonatomic,strong) UIView *view;
@property (nonatomic,strong) NSMutableArray *msgList;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

//@property (nonatomic,assign) NSInteger step;
@property (nonatomic,copy) NSString *remarkUserName;

@end

@implementation WXService

+ (instancetype)shareInstance{
    static WXService *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[WXService alloc] init];
        service.view = [[UIApplication sharedApplication]keyWindow];
    });
    return service;
}


- (void)startNewWorkService{
    self.connectedOK = YES;
    [self startMaintainOnLineService];
}

- (void)startVoiceServiceWithFriendsNames:(NSSet*)friendNames{
    [self uploadWordsWithFriendNames:friendNames];
}

- (void)startListenOrder{
    if (![self.iflyRecognizer isListening]) {
        [self.iflyRecognizer startListening];
    }
}

- (void)stopListenOrder{
    if (self.iflyRecognizer.isListening) {
        [self.iflyRecognizer cancel];
    }
}




/**
 上传用户词表
 ****/
- (void)uploadWordsWithFriendNames:(NSSet*)friendNames{
    if (!friendNames) return;
//    NSSet *set = [NSSet setWithSet:friendNames];
//    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
//    NSArray *sortSetArray = [set sortedArrayUsingDescriptors:sortDesc];
    NSArray *sortSetArray = SGArrayWithSet(friendNames);
//    sortSetArray = @[@"龟龟",@"成时",@"侯少安",@"庆伟",@"郭波"];
    [self.iflyRecognizer stopListening];
    [self.uploader setParameter:@"iat" forKey:[IFlySpeechConstant SUBJECT]];
    [self.uploader setParameter:@"userword" forKey:[IFlySpeechConstant DATA_TYPE]];
    
    NSArray         *usedWords      = @[kSendMsgTo,kSendMsgToQun];
    NSDictionary    *usedWordsDic   = @{@"name":@"我的常用词",@"words":usedWords};
    NSDictionary    *friendNamesDic = @{@"name":@"我的好友",@"words":sortSetArray};
    
    NSDictionary *dic = @{@"userword":@[usedWordsDic,friendNamesDic]};
    
//龟龟 成时 侯少安 庆伟 郭波
    NSString *uploadStr = SGJsonStringWithObj(dic);
    IFlyUserWords *iFlyUserWords = [[IFlyUserWords alloc] initWithJson:uploadStr];
    
    [_uploader uploadDataWithCompletionHandler:
     ^(NSString * grammerID, IFlySpeechError *error)
     {
         NSLog(@"%d",[error errorCode]);
         if ([error errorCode] == 0) {
             NSLog(@"上传成功");
             [self startListenOrder];
         }
     } name:NAME data:[iFlyUserWords toString]];
    
}

#pragma mark - delegate
#pragma mark IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    
//    NSLog(@"音量：%d",volume);
}



/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString *result =[NSString stringWithString:resultString];


    if(result.length>0){
        SGHud(result);
        [self resolveVoiceResult:result];
    }else{
        [self startListenOrder];
    }
    
}

- (void)resolveVoiceResult:(NSString*)result{
    if (result.length == 0) {
        [self startListenOrder];
        return;
    }
    if (self.step == 2) {
        if (self.remarkUserName)
            [WXCoreHelper sendTextMsg:result ToUserName:self.remarkUserName Result:^(BOOL success) {
                if (success) [self speekWithWords:@"已发送"];
                self.remarkUserName = nil;
                self.step = 0;
                [self startListenOrder];
            }];
    }else{
        NSString *name;
        if ([result containsString:kSendMsgTo]) {
            NSRange range = [result rangeOfString:kSendMsgTo];
            name = [result substringFromIndex:range.location+range.length];
        }else if([result containsString:kSendMsgToQun]){
            NSRange range = [result rangeOfString:kSendMsgTo];
            name = [result substringFromIndex:range.location+range.length];
        }else{
            [self remindWithMsg:@"不能识别的命令！"];
            return;
        }
        WXContact *contact = [self.model contactWithUserName:name];
        if (contact) {
            if (contact.userName) {
                self.remarkUserName = contact.userName;
                [self remindWithMsg:@"没有这个用户！"];
            }else{
                [self remindWithMsg:@"没有用户名！"];
            }
        }else{
            [self remindWithMsg:@"没有该用户"];
        }
    }
    
}

- (void)remindUserSayMsg{
    [self remindWithMsg:@"请说要发送的内容："];
    self.step = 2;
}
- (void)remindNoThisUser{
    [self remindWithMsg:@"没有这个用户！"];
}

- (void)remindWithMsg:(NSString*)msg{
    [self speekWithWords:msg];
}


- (void)onError:(IFlySpeechError *)error{
    NSLog(@"errorCode:%@", [error errorDesc]);
}

/**
 听写取消回调
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}


#pragma mark - 合成语音---------------------------------------------------------------------------------------合成语音
- (void)readMessage:(WXMessage*)message{
    [self readMsg:message fromResource:NO completion:nil];
}
- (void)readMsg:(WXMessage*)message fromResource:(BOOL)isList completion:(void(^)(BOOL isRead))complete{
    if (![[WXService shareInstance] step]) {
        if (message.msgType == MTypeText) {
            [self speekWithWords:[NSString stringWithFormat:@"%@发来消息说：%@，",[self messageContentResolve:message],message.content]];
        }else if (message.msgType == MTypeImage){
            [self speekWithWords:[NSString stringWithFormat:@"%@发来图片消息，",[self messageContentResolve:message]]];
        }else if (message.msgType == MTypeVoice){
            [self speekWithWords:[NSString stringWithFormat:@"%@发来语音消息，",[self messageContentResolve:message]]];
            sleep(3);
            [self playVoiceWithMsg:message];
        }else if (message.msgType == MTypeVideo){
            [self speekWithWords:[NSString stringWithFormat:@"%@发来视频消息，",[self messageContentResolve:message]]];
        }else if (message.msgType == MTypeAnimationImg){
            [self speekWithWords:[NSString stringWithFormat:@"%@发来动画表情，",[self messageContentResolve:message]]];
        }
        if (complete) complete(YES);
    }else{
        if (!isList) [self.msgList addObject:message];
        if (complete) complete(NO);
    }
    
}

- (void)playVoiceWithMsg:(WXMessage*)message{
    NSData *data = (NSData*)[[[AppDelegate shareDelegate] cache] objectForKey:message.msgUrlStr];
    NSError *error = nil;
    if (data) {
        if (self.audioPlayer.isPlaying) [self.audioPlayer stop];
        [self stopListenOrder];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
    }
    if (error) NSLog(@"paly error:%@",error);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    player = nil;
    [self startListenOrder];
}

- (NSString*)messageContentResolve:(WXMessage*)message{
    NSString *header = @"";
    NSString *name = @"";
    if ([[WXAccess access] isSelfWithUserName:message.fromUserName]) return @"我从手机";
    WXContact *contact = [self.model contactWithUserName:message.fromUserName];
    if (contact.contactType == TypeGroup) {
        WXContact *realContact = message.contact;
        name = realContact.displayName.length>0 ? realContact.displayName : (realContact.remarkName.length>0 ? realContact.remarkName : realContact.nickName);
        if (name.length == 0) name = @"未知朋友";
        if ([contact.nickName hasSuffix:@"群"]) {
            header = [NSString stringWithFormat:@"%@中的%@",contact.nickName,name];
        }else{
            header = [NSString stringWithFormat:@"%@群中的%@",contact.nickName,name];
        }
        
    }else if(contact.contactType == TypeFriend){
        name =  contact.remarkName.length>0 ? contact.remarkName : contact.nickName;
        header = name;
    }
    return header;
}

- (void)continueRead{
    while (YES) {
        if (self.msgList.count>0) {
            [self readMsg:self.msgList[0] fromResource:YES completion:^(BOOL isRead) {
                if (isRead) [self.msgList removeObjectAtIndex:0];
            }];
        }
    }
}

- (void)speekWithWords:(NSString*)words{
    if (words.length==0) {
        [self startListenOrder];
        return;
    }
    [self stopListenOrder];
    [self.iFlySpeechSynthesizer startSpeaking:words];
    [self startListenOrder];
}

#pragma mark IFlySpeechSynthesizerDelegate



- (void)speekStop{
    [self.iFlySpeechSynthesizer stopSpeaking];
}

//合成开始
- (void) onSpeakBegin{
    
}
//合成缓冲进度
- (void) onBufferProgress:(int) progress message:(NSString *)msg{
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}
//合成播放进度
- (void) onSpeakProgress:(int) progress{
    NSLog(@"speak progress %2d%%.", progress);
}

- (void)onCompleted:(IFlySpeechError *)error{
    NSString *text ;
    if (error.errorCode != 0) {
        text = [NSString stringWithFormat:@"错误码:%d",error.errorCode];
        return;
    }
   NSLog(@"读完");
}


- (void)startMaintainOnLineService{
    self.counter = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //保持在线状态,并轮询信息
        while ([WXAccess access] && self.connectedOK) {
            int state = [WXCoreHelper synccheck];
            
            if (state <-1 || state>7){
                self.connectedOK = NO;
                //抛通知消息
                 [self speekWithWords:@"连接失败了，请重新扫描登陆！"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kOnLineConnectFail object:self];
            }else if(state == 0){
                self.counter = 0;
                NSLog(@"正常长连接状态");
            }else if (state == 2){
                self.counter = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewMsgState object:self];
                
                NSLog(@"有新消息状态");
            }else if (state == 6){
                self.counter++;
                NSLog(@"进入消息状态6");
                if (self.counter>5) {
                    self.connectedOK = NO;
                    [self speekWithWords:@"连接失败了，请重新扫描登陆！"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOnLineConnectFail object:self];
                }
            }else if (state == 7){
                self.counter++;
                if(self.counter<=3){
                    NSLog(@"刚登陆正在检查状态");
                }else if (self.counter>3) {
                    self.connectedOK = NO;
                    [self speekWithWords:@"连接失败了，请重新扫描登陆！"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kOnLineConnectFail object:self];
                }else{
                    NSLog(@"手机微信进入聊天界面");
                }
            }
            sleep(2);
        }
        
        
    });
}


#pragma mark - getter

- (IFlyDataUploader *)uploader{
    if (!_uploader) {
        _uploader = [[IFlyDataUploader alloc] init];
    }
    return _uploader;
}



- (IFlySpeechRecognizer *)iflyRecognizer{
    if (!_iflyRecognizer) {
        NSString *initString = [NSString stringWithFormat:@"%@=56fdef8c", [IFlySpeechConstant APPID]];
        [IFlySpeechUtility createUtility:initString];
        
        _iflyRecognizer = [IFlySpeechRecognizer sharedInstance];
        _iflyRecognizer.delegate = self;
        
        [_iflyRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        [_iflyRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        [_iflyRecognizer setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    }
    return _iflyRecognizer;
}

- (IFlySpeechSynthesizer *)iFlySpeechSynthesizer{
    if (!_iFlySpeechSynthesizer) {
        
        TTSConfig *instance = [TTSConfig sharedInstance];
        if (instance == nil) {
            return nil;
        }
        
        //合成服务单例
        if (_iFlySpeechSynthesizer == nil) {
            _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
        }
        
        _iFlySpeechSynthesizer.delegate = self;
        
        //设置语速1-100
        [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
        
        //设置音量1-100
        [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
        
        //设置音调1-100
        [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
        
        //设置采样率
        [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        
        //设置发音人
        [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
        
        [_iFlySpeechSynthesizer setDelegate:self];
    }
    return _iFlySpeechSynthesizer;
}

- (NSMutableArray *)msgList{
    if (!_msgList) {
        _msgList = [[NSMutableArray alloc]init];
    }
    return _msgList;
}





@end
