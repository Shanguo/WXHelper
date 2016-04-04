//
//  WXMessage.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/3.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXMessage.h"
#import "WXContact.h"
#import "Emoji.h"

@implementation WXMessage

- (instancetype)initWithDic:(NSDictionary*)dic
{
    self = [super init];
    if (self) {
        self.msgId          = dic[@"MsgId"];
        self.createTime     = [dic[@"CreateTime"] doubleValue];
        self.msgType        = [dic[@"MsgType"] integerValue];
        self.content        = dic[@"Content"];
        self.fromUserName   = dic[@"FromUserName"];
        self.toUserName     = dic[@"ToUserName"];
        self.forwardFlag    = [dic[@"ForwardFlag"] integerValue];
        
        
        [self setUrlWithMsgType:self.msgType];
        [self getVoicelengthWithMType:self.msgType Content:self.content];
        [self resolveEmoji];
        [self forwardResolve];//重新判断是否消息是否是来自自己
       
    }
    return self;
}

- (instancetype)initWithSendTextMsg:(NSString*)content ToUserName:(NSString*)toUserName
{
    self = [super init];
    if (self) {
        self.createTime     = [[NSDate date] timeIntervalSince1970];
        self.msgType        = 1;
        self.content        = content;
        self.fromUserName   = [[WXAccess access] userName] ;
        self.toUserName     = toUserName;
        self.forwardFlag    = 1;
    }
    return self;
}

/**
 *  处理表情文字
 */
- (void)resolveEmoji{
    //"<span class="emoji emoji1f604"></span>"
    
    if (![self.content containsString:@"<span class=\"emoji"]) return;
    
    NSMutableString *mutStr = [NSMutableString stringWithString:self.content];
    
    while ([mutStr containsString:@"<span class=\"emoji"]) {
        NSRange range1 = [mutStr rangeOfString:@"emoji emoji"];
        NSString *emojiCodeStr = [mutStr substringWithRange:NSMakeRange(range1.location+range1.length, 5)];
        int emojiCode = (int)strtoul([[emojiCodeStr uppercaseString] UTF8String],0,16);
        NSString *emoji = [Emoji emojiWithCode:emojiCode];
        NSString *spanStr = [NSString stringWithFormat:@"<span class=\"emoji emoji%@\"></span>",emojiCodeStr];
        NSRange range2 = [mutStr rangeOfString:spanStr];
        [mutStr replaceCharactersInRange:range2 withString:emoji];
    }
    self.content = [mutStr copy];
}

#pragma - public resolve
/**
 *  如果是群组消息，那么获取发消息人的用户名
 *
 *  @return username
 */
- (NSString *)userNameInGroupMsg{
    NSRange range = [self.content rangeOfString:@":<br/>"];
    if (range.location>self.content.length) return nil;
    return [self.content substringToIndex:range.location];
}

/**
 *  群组消息内容处理，去掉头部的username
 *
 *  @return WXMessage
 */
- (WXMessage*)contentGroupResolve{
    NSRange range  =  [self.content  rangeOfString:@">"];
    if (range.location+1<self.content.length) {
        self.content = [self.content substringFromIndex:range.location+1];
    }
    [self removeBR];
    return self;
}

/**
 *  去除<br>
 *
 *  @return WXMessage
 */
- (WXMessage*)contentResolve{
    [self removeBR];
    return self;
}

/**
 *  重新判断是否消息是否是来自自己
 */
- (void)forwardResolve{
    if ([[WXAccess access] isSelfWithUserName:self.fromUserName]) self.forwardFlag = 1;
}

#pragma mark - private

- (void)setUrlWithMsgType:(WXMessageType)msgType{
    NSString *headerUrl = @"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxget";
    NSString *skey = [[WXAccess access] sKey];
    if (msgType == MTypeImage) { //图片
        self.msgUrlStr = [NSString stringWithFormat:@"%@msgimg?&MsgID=%@&skey=%@",headerUrl,self.msgId,skey];
        self.msgThumbnailUrlStr = [NSString stringWithFormat:@"%@&type=slave",self.msgUrlStr];
    } else if (msgType == MTypeVoice){ //语音
        self.msgUrlStr = [NSString stringWithFormat:@"%@voice?msgid=%@&skey=%@",headerUrl,self.msgId,skey];
    }else if (msgType == MTypeVideo){ //视频
        self.msgUrlStr = [NSString stringWithFormat:@"%@video?msgid=%@&skey=%@",headerUrl,self.msgId,skey];
        self.msgThumbnailUrlStr = [NSString stringWithFormat:@"%@msgimg?&MsgID=%@&skey=%@&type=slave",headerUrl,self.msgId,skey];
    }
}


- (void)getVoicelengthWithMType:(WXMessageType)msgType Content:(NSString*)content{
    if (msgType == MTypeVoice) {
        NSRange range1 = [content rangeOfString:@"voicelength=\""];
        NSRange range2 = [content rangeOfString:@"\" length="];
        NSString *strLength = [content substringWithRange:NSMakeRange(range1.location+range1.length, range2.location+range1.length-range1.location)];
        NSInteger realLength = [strLength integerValue];
        self.voiceLength = (realLength+1000)/1000;
    }
}

- (void)removeBR{
    [self.content stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
}

@end
