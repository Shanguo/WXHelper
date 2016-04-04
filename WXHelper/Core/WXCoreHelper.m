//
//  WXLoginHelper.m
//  WeiXin
//
//  Created by TanHao on 13-8-25.
//  Copyright (c) 2013年 http://www.tanhao.me. All rights reserved.
//

#import "WXCoreHelper.h"
#import "THWebService.h"
#import "WXMessage.h"
#import "WXURL.h"

@interface WXCoreHelper()

@end

@implementation WXCoreHelper

+ (NSString *)timeString
{
    return [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
}

//由微信服务器返回一个会话ID
+ (NSString *)wxUUID
{
    NSString *urlString = [NSString stringWithFormat:URL_UUIDGetting,[self timeString]];
    
    NSData *data = [THWebService dataWithUrl:[NSURL URLWithString:urlString]];
    if (!data)
    {
        return nil;
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange range = [string rangeOfString:@"window.QRLogin.uuid = \""];
    if (range.location != NSNotFound)
    {
        NSString *uuid = [string substringFromIndex:range.location+range.length];
        uuid = [uuid substringToIndex:uuid.length-2];
        return uuid;
    }
    return nil;
}

//获取登录的二维码
+ (UIImage *)qrCode:(NSString *)uuid
{
    NSString *urlString = [NSString stringWithFormat:URL_CodeImageGetting,uuid];
    NSData *data = [THWebService dataWithUrl:[NSURL URLWithString:urlString]];
    if (!data) return nil;
    return [[UIImage alloc] initWithData:data];
}


//获取登录的页面地址
+ (NSString *)loginPage:(NSString *)uuid state:(int *)state
{
    NSString *urlString = [NSString stringWithFormat:URL_FetchPhoneLoginResult,uuid,[self timeString]];
    NSData *data = [THWebService dataWithUrl:[NSURL URLWithString:urlString]];
    if (!data)
    {
        return nil;
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //已经点击了确认登录
    NSRange range = [string rangeOfString:@"window.redirect_uri=\""];
    if (range.location != NSNotFound)
    {
        NSString *loginPage = [string substringFromIndex:range.location+range.length];
        loginPage = [loginPage substringToIndex:loginPage.length-2];
        return loginPage;
    }
    
    //已经扫描成功
    range = [string rangeOfString:@"window.code=201"];
    if (range.location != NSNotFound)
    {
        if (state) *state = 201;
    }
    return nil;
}

//通过登录页登录
+ (WXAccess *)login:(NSString *)loginPage
{
    NSURL *url = [NSURL URLWithString:loginPage];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = NULL;
    
//    [request setHTTPMethod:@"GET"];
//    NSString *response;
//    NSData *returnData =
    [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:&error];
    if (error)
    {
        return nil;
    }
    
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    WXAccess *access = [WXAccess access];
    for (NSHTTPCookie *cookie in [cookieStorage cookies])
    {
        if ([cookie.name isEqualToString:@"wxuin"])
        {
            access.wxuin = [cookie value];
        }
        if ([cookie.name isEqualToString:@"wxsid"])
        {
            access.wxsid = [cookie value];
        }
//        if ([cookie.name isEqualToString:@"pass_ticket"]) {
//            access.passTicket = [cookie value];
//        }
    }
//    NSString *string = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    if (access.wxuin && access.wxsid)
    {
        return access;
    }
    return nil;
}

+ (void)webwxstatreport:(NSString *)uuid
{
    NSString *urlString = [NSString stringWithFormat:URL_ReportWebLogined,[self timeString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSString *bodyString = [NSString stringWithFormat:BODY_JSON_Report_Atteched,uuid];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
}

//微信初使化
+ (NSDictionary *)wxInit
{
    WXAccess *access = [WXAccess access];
    NSString *urlString = [NSString stringWithFormat:URL_Data_Init,[self timeString]];
//    NSString *urlString = [NSString stringWithFormat:URL_Data_Init,[self timeString],access.passTicket];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSString *bodyString = [NSString stringWithFormat:BODY_Data_Init,access.wxuin,access.wxsid,access.deviceID];
    NSDictionary *wxInfo = [WXCoreHelper postWithRequest:request Body:bodyString];
    access.owner = [wxInfo objectForKey:@"User"];
    NSString *headUrlPath = [NSString stringWithFormat:@"https://wx.qq.com%@",[access.owner objectForKey:@"HeadImgUrl"]];
    access.headImage = [WXCoreHelper imageWithURL:[NSURL URLWithString:headUrlPath]];
    access.sKey = [wxInfo objectForKey:@"SKey"];
    access.syncKey = [[wxInfo objectForKey:@"SyncKey"] objectForKey:@"List"];
    return wxInfo;
}

/**
 *  获取所有好友，订阅号等，没有群
 *
 *  @return array
 */
+ (NSArray *)allFriendsOthers
{
    
//    NSString *urlString = [NSString stringWithFormat:URL_All_List,[self timeString]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    NSString *bodyString = [NSString stringWithFormat:BODY_All_List];
//    return [WXCoreHelper postWithRequest:request Body:bodyString];
    
    NSString *urlString = [NSString stringWithFormat:@"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxgetcontact?lang=zh_CN&r=%@&seq=0&skey=%@",[self timeString],[WXAccess access].sKey];
    NSData *data = [THWebService dataWithUrl:[NSURL URLWithString:urlString]];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    return dic[@"MemberList"];
}


/**
 *  根据ChatSet里面的Usernames 请求
 *
 *  @param count   username的数量
 *  @param jsonStr part json
 *
 *  @return 请求的Contacts array
 */
+ (NSArray *)postGroupWithCount:(NSInteger)count JsonStr:(NSString*)jsonStr
{
    WXAccess *access = [WXAccess access];
    NSString *urlString = [NSString stringWithFormat:URL_Group_Others,[self timeString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSString *bodyString = [NSString stringWithFormat:BODY_Group_Others,access.wxuin,access.wxsid,access.sKey,access.deviceID,(long)count,jsonStr];
    return [WXCoreHelper postWithRequest:request Body:bodyString][@"ContactList"];
}


/**
 *  请求顺序，但是这个请求结果不理想，没有想网页一样的大想要的结果
 *
 *  @return dic
 */
+ (NSDictionary *)postGetOrderList
{
    WXAccess *access = [WXAccess access];
    NSString *urlString = [NSString stringWithFormat:URL_Ordered_Name_List,access.wxsid,access.sKey];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    NSMutableString *syncKeyString = [NSMutableString stringWithString:@"["];
    for (NSDictionary *dic in access.syncKey)
    {
        [syncKeyString appendFormat:@"{\"Key\":%@,\"Val\":%@},",[dic objectForKey:@"Key"],[dic objectForKey:@"Val"]];
    }
    NSRange range = NSMakeRange(syncKeyString.length-1, 1);
    [syncKeyString deleteCharactersInRange:range];
    [syncKeyString appendString:@"]"];
    
//    NSString *bodyString = [NSString stringWithFormat:@"{\"BaseRequest\":{\"Uin\":%@,\"Sid\":\"%@\",\"Skey\":\"%@\",\"DeviceID\":\"%@\"},\"SyncKey\":{\"Count\":%ld,\"List\":%@},\"rr\":\"-1201765963\"}",access.wxuin,access.wxsid,access.sKey,access.deviceID,access.syncKey.count,syncKeyString];
    NSString *bodyString = [NSString stringWithFormat:@"{\"BaseRequest\":{\"Uin\":%@,\"Sid\":\"%@\",\"Skey\":\"%@\",\"DeviceID\":\"%@\"},\"SyncKey\":{\"Count\":%ld,\"List\":%@},\"rr\":%@}",access.wxuin,access.wxsid,access.sKey,access.deviceID,(long)access.syncKey.count,syncKeyString,[self timeString]];
    return [WXCoreHelper postWithRequest:request Body:bodyString];
    
}


+ (id)postWithRequest:(NSMutableURLRequest *)request Body:(NSString*)bodyString{
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    if (!data)
    {
        return nil;
    }
    
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
}

+ (NSArray*)groupOthers{
    return nil;
}


+ (BOOL)webwxstatusnotify
{
    WXAccess *access = [WXAccess access];
    NSString *timeString = [self timeString];
    NSString *urlString = [NSString stringWithFormat:@"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsendmsg?sid=%@&r=%@",access.wxsid,timeString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary *bodyInfo =
    @{
    @"BaseRequest" : @{@"Uin":access.wxuin,@"Sid":access.wxsid,@"Skey":access.sKey,@"DeviceID":access.deviceID},
    @"Msg" : @{@"FromUserName":access.userName,
    @"ToUserName":access.userName,@"Type":@(3),@"ClientMsgId":timeString}
    };
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyInfo options:0 error:NULL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    if (!data)
    {
        return NO;
    }
    
    NSDictionary *resultInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    int state = [[[resultInfo objectForKey:@"BaseResponse"] objectForKey:@"Ret"] intValue];
    if (state == 0) {
        return YES;
    }
    return NO;
}

//保持与服务器的同步
+ (int)synccheck
{
    WXAccess *access = [WXAccess access];
    NSMutableString *syncKeyString = [NSMutableString stringWithString:@""];
    for (NSDictionary *key in access.syncKey)
    {
        [syncKeyString appendFormat:@"%@%@_%@",syncKeyString.length>0?@"%7C":@"",
         [key objectForKey:@"Key"],[key objectForKey:@"Val"]];
    }
    
//    NSString *urlString = [NSString stringWithFormat:@"https://webpush.weixin.qq.com/cgi-bin/mmwebwx-bin/synccheck?callback=jQuery18309326978388708085_%@&r=%@&sid=%@&uin=%@&deviceid=%@&synckey=%@&_=%@",[self timeString],[self timeString],access.wxsid,access.wxuin,access.deviceID,syncKeyString,[self timeString]];
    
    NSString *urlString = [NSString stringWithFormat:@"https://webpush.weixin.qq.com/cgi-bin/mmwebwx-bin/synccheck?r=%@&skey=%@&sid=%@&uin=%@&deviceid=%@&synckey=%@&_=%@",[self timeString],access.sKey,access.wxsid,access.wxuin,access.deviceID,syncKeyString,[self timeString]];

    
    
    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                         returningResponse:NULL error:NULL];
    if (!data)
    {
        return -1;
    }
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",string);
    
    NSRange range = [string rangeOfString:@"retcode:\""];
    if (range.location == NSNotFound) {
        return -1;
    }
    string = [string substringFromIndex:range.location+range.length];
    
    range = [string rangeOfString:@"selector:\""];
    if (range.location == NSNotFound)
    {
        return -1;
    }
    
    NSString *retcodeString = [string substringToIndex:range.location-2];
    int retcode = [retcodeString intValue];
    if (retcode != 0) {
        return -2;
    }
    
    NSString *stateString = [string substringFromIndex:range.location+range.length];
    stateString = [stateString substringToIndex:stateString.length-2];
    
     NSLog(@"state==%@",stateString);
    return [stateString intValue];
}

+ (NSArray *)receiveMessage
{
    WXAccess *access = [WXAccess access];
    NSString *urlString = [NSString stringWithFormat:@"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsync?sid=S11EXjyZcBEjzlFh&r=%@",[self timeString]];
//     NSString *urlString = [NSString stringWithFormat:@"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsync?sid=S11EXjyZcBEjzlFh&skey=%@&lang=zh_CN",access.sKey];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary *bodyInfo =
    @{
    @"BaseRequest" : @{@"Uin":access.wxuin,@"Sid":access.wxsid},
    @"SyncKey" : @{@"Count":@(access.syncKey.count),@"List":access.syncKey},
    @"rr" : @"-1201765963"
    };
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyInfo options:0 error:NULL];    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    if (!data)
    {
        return nil;
    }
    
    NSDictionary *synKeyInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    NSArray *syncKey = [[synKeyInfo objectForKey:@"SyncKey"] objectForKey:@"List"];
    if (syncKey) access.syncKey = syncKey;
    NSString *sKey = [synKeyInfo objectForKey:@"SKey"];
    if (sKey) access.sKey = sKey;
    
    return [synKeyInfo objectForKey:@"AddMsgList"];
}

//发送消息
+ (BOOL)sendMeaageToUser:(NSString *)user message:(NSString *)message
{
    WXAccess *access = [WXAccess access];
    NSString *timeString = [self timeString];
    NSString *urlString = [NSString stringWithFormat:@"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsendmsg?sid=%@&r=%@",access.wxsid,timeString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary *bodyInfo =
    @{
    @"BaseRequest" : @{@"Uin":access.wxuin,@"Sid":access.wxsid,@"Skey":access.sKey,@"DeviceID":access.deviceID},
    @"Msg" : @{@"FromUserName":access.userName,
               @"ToUserName":user,@"Type":@(1),@"Content":message,@"ClientMsgId":timeString,@"LocalID":timeString},
    @"rr" : [self timeString]
    };
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyInfo options:0 error:NULL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:NULL];
    if (!data)
    {
        return NO;
    }
    
    NSDictionary *resultInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    int state = [[[resultInfo objectForKey:@"BaseResponse"] objectForKey:@"Ret"] intValue];
    if (state == 0) {
        return YES;
    }
    return NO;
}



+ (void)sendTextMsg:(NSString*)aMsg ToUserName:(NSString*)userName Result:(void(^)(BOOL success))result{
    if (aMsg.length>0)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL state = [WXCoreHelper sendMeaageToUser:userName message:aMsg];
            if (state) {
                NSLog(@"发送成功!");
                
            }else{
                NSLog(@"发送失败");
            }
            if (result) result(state);
        });
    }else{
        NSLog(@"没有内容");
    }
}


+ (UIImage *)imageWithURL:(NSURL*)url{
    NSData *data = [THWebService dataWithUrl:url];
    if (!data) return nil;
    return [[UIImage alloc] initWithData:data];
}


+ (UIImage *)syncImageWithUrlStr:(NSString*)urlStr{
    if (!urlStr) return nil;
    UIImage *image = [[self class] readImageFromCacheWithUrlStr:urlStr];
    if (image) return image;
    return [[self class] imageWithURL:[NSURL URLWithString:urlStr]];
}

+ (void)asyncImageWithURLStr:(NSString*)urlStr Complete:(void (^)(BOOL isSuccess,UIImage *image))complete{
    if (!urlStr) {
        complete(NO,nil);
        return;
    }
    
    UIImage *image = [[self class] readImageFromCacheWithUrlStr:urlStr];
    if (image && complete) {
        complete(YES,image);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = [[self class] imageWithURL:[NSURL URLWithString:urlStr]];
        if (image) {
            [[SDImageCache sharedImageCache] storeImage:image forKey:urlStr];
            if (complete) complete(YES,image);
            return ;
        }
        
        if (complete) complete(NO,nil);
    });
}

+ (UIImage*)readImageFromCacheWithUrlStr:(NSString*)urlStr{
    if (!urlStr) return nil;
    UIImage *image = nil;
    SDImageCache *cache = [SDImageCache sharedImageCache];
    image = [cache imageFromMemoryCacheForKey:urlStr];
    if (image) return image;
    image = [cache imageFromDiskCacheForKey:urlStr];
    return image;
}


@end
