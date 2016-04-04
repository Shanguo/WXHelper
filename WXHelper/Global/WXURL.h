//
//  WXURL.h
//  WXHelper
//
//  Created by 刘山国 on 16/2/29.
//  Copyright © 2016年 山国. All rights reserved.
//

#ifndef WXURL_h
#define WXURL_h


/**
 *  所有 URL 注意其中的 %@
 */

//第一步，请求获取UUID的URL
//static NSString * const URL_UUIDGetting = @"https://login.weixin.qq.com/jslogin?appid=wx782c26e4c19acffb&redirect_uri=https%%3A%%2F%%2Fwx.qq.com%%2Fcgi-bin%%2Fmmwebwx-bin%%2Fwebwxnewloginpage&fun=new&lang=zh_CN&_=%@";
static NSString * const URL_UUIDGetting = @"https://login.weixin.qq.com/jslogin?appid=wx782c26e4c19acffb&redirect_uri=https%3A%2F%2Fwx.qq.com%2Fcgi-bin%2Fmmwebwx-bin%2Fwebwxnewloginpage&fun=new&lang=zh_CN&_=%@";//1456999369943

//第二步，根据UUID获取二维码图片的URL
static NSString * const URL_CodeImageGetting = @"https://login.weixin.qq.com/qrcode/%@?t=webwx";

//第三步，轮回请求手机扫描或者确认登录结果的URL，如果code==201代表已经扫描，如果有重定向URL则进入下一步，用重定向URL登录
static NSString * const URL_FetchPhoneLoginResult = @"https://login.weixin.qq.com/cgi-bin/mmwebwx-bin/login?uuid=%@&tip=1&_=%@";


//第四步，用重定向URL登录，获取基本个人信息。同时向微信服务器报告，只负责report不管结果，一下是报告URL
static NSString * const URL_ReportWebLogined = @"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxstatreport?type=1&r=%@";
static NSString * const BODY_JSON_Report_Atteched = @"{\"BaseRequest\":{\"Uin\":0,\"Sid\":0},\"Count\":1,\"List\":[{\"Type\":1,\"Text\":\"/cgi-bin/mmwebwx-bin/login, Second Request Success, uuid: %@, time: 2896ms\"}]}";

//第五步，POST init data
static NSString * const URL_Data_Init = @"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit?r=%@";
//static NSString * const URL_Data_Init = @"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxinit?r=%@&lang=zh_CN&pass_ticket=%@";
static NSString * const BODY_Data_Init = @"{\"BaseRequest\":{\"Uin\":\"%@\",\"Sid\":\"%@\",\"Skey\":\"\",\"DeviceID\":\"%@\"}}";

//第六步，POST 获取所有关注和好友Friend
static NSString * const URL_All_List = @"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxgetcontact?r=%@";
static NSString * const BODY_All_List = @"{}";

//第七步，POST 获取其他群
static NSString * const URL_Group_Others = @"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxbatchgetcontact?type=ex&r=%@";
static NSString * const BODY_Group_Others = @"{\"BaseRequest\":{\"Uin\":\"%@\",\"Sid\":\"%@\",\"Skey\":\"%@\",\"DeviceID\":\"%@\"},\"Count\":%ld,\"List\":%@}";

//第八步，获取顺序列表
static NSString * const URL_Ordered_Name_List = @"https://wx.qq.com/cgi-bin/mmwebwx-bin/webwxsync?sid=%@&skey=%@&lang=zh_CN";
static NSString * const BODY_Ordered_Name_List = @"{\"BaseRequest\":{\"Uin\":%@,\"Sid\":\"%@\",\"Skey\":\"%@\",\"DeviceID\":\"%@\"},\"SyncKey\":{\"Count\":%ld,\"List\":%@},\"rr\":\"-1201765963\"}";



#endif /* WXURL_h */
