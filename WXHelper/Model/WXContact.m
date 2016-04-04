//
//  WXContact.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/3.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXContact.h"

static NSString * const kUin                = @"Uin";
static NSString * const kUserName           = @"UserName";
static NSString * const kNickName           = @"NickName";
static NSString * const kHeadImgUrl         = @"HeadImgUrl";
static NSString * const kContactFlag        = @"ContactFlag";
//static NSString * const kMemberList       = @"MemberList";
static NSString * const kRemarkName         = @"RemarkName";
static NSString * const kDisplayName        = @"DisplayName";
//static NSString * const kSex              = @"Sex";
static NSString * const kVerifyFlag         = @"VerifyFlag";
static NSString * const kPYInitial          = @"PYInitial";
static NSString * const kPYQuanPin          =@"PYQuanPin";
static NSString * const kEncryChatRoomId    = @"EncryChatRoomId";
static NSString * const kAlias              = @"Alias";
static NSString * const kContactType        = @"ContactType";

@implementation WXContact

- (instancetype)initWithDic:(NSDictionary *)infoDic
{
    self = [super init];
    if (self) {
//        self.uin              = [infoDic objectForKey:kUin];
        self.userName           = [infoDic objectForKey:kUserName];
        self.nickName           = [infoDic objectForKey:kNickName];
        NSString *path          = [infoDic objectForKey:kHeadImgUrl];
        self.headImgURL         = [NSURL URLWithString:[NSString stringWithFormat:@"https://wx.qq.com%@",path]];
//        self.contactFlag      = (NSInteger)[infoDic objectForKey:kContactFlag];
        self.verifyFlag         = [[infoDic objectForKey:kVerifyFlag] integerValue];
        self.remarkName         = [infoDic objectForKey:kRemarkName];
        self.displayName        = [infoDic objectForKey:kDisplayName];
        self.PYInitial          = [infoDic objectForKey:kPYInitial];
//        self.PYQuanPin        = [infoDic objectForKey:kPYInitial];
        self.encryChatRoomId    = [infoDic objectForKey:kEncryChatRoomId];
//        self.alias            = [infoDic objectForKey:kAlias];
        NSInteger memberCount   = [[infoDic objectForKey:@"MemberCount"] integerValue];
        if (self.verifyFlag>0) {
            self.contactType    = TypeOther;
        }else if (self.verifyFlag==0) {
            if (memberCount>0) {
                self.contactType    = TypeGroup;
            }else{
                self.contactType    = TypeFriend;
            }
        }
       
//        if ([self.userName isEqualToString:@"filehelper"]) self.contactType = TypeOther;
        if (self.userName.length<22) self.contactType = TypeOther;
        if ([self.userName isEqualToString:@"filehelper"]) self.contactType = TypeFriend;
//        self.message = @"";
//        self.timeStr = @"";
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
//        self.uin              = [coder decodeObjectForKey:kUin];
        self.userName           = [coder decodeObjectForKey:kUserName];
        self.nickName           = [coder decodeObjectForKey:kNickName];
        self.headImgURL         = [coder decodeObjectForKey:kHeadImgUrl];
//        self.contactFlag      = (NSInteger)[coder decodeObjectForKey:kContactFlag];
        self.verifyFlag         = (NSInteger)[coder decodeObjectForKey:kVerifyFlag];
        self.remarkName         = [coder decodeObjectForKey:kRemarkName];
        self.displayName        = [coder decodeObjectForKey:kDisplayName];
        self.PYInitial          = [coder decodeObjectForKey:kPYInitial];
//        self.PYQuanPin        = [coder decodeObjectForKey:kPYQuanPin];
        self.encryChatRoomId    = [coder decodeObjectForKey:kEncryChatRoomId];
//        self.alias            = [coder decodeObjectForKey:kAlias];
        self.contactType        = (WXContactType)[coder decodeObjectForKey:kContactType];
//        self.message          = [coder decodeObjectForKey:@"Message"];
//        self.timeStr          = [coder decodeObjectForKey:@"Time"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:self.uin forKey:kUin];
    [aCoder encodeObject:self.userName forKey:kUserName];
    [aCoder encodeObject:self.nickName forKey:kNickName];
    [aCoder encodeObject:self.headImgURL forKey:kHeadImgUrl];
//    [aCoder encodeObject:@(self.contactFlag) forKey:kContactFlag];
    [aCoder encodeObject:@(self.verifyFlag) forKey:kVerifyFlag];
    [aCoder encodeObject:self.remarkName forKey:kRemarkName];
    [aCoder encodeObject:self.displayName forKey:kDisplayName];
    [aCoder encodeObject:self.PYInitial forKey:kPYInitial];
//    [aCoder encodeObject:self.PYQuanPin forKey:kPYQuanPin];
    [aCoder encodeObject:self.encryChatRoomId forKey:kEncryChatRoomId];
//    [aCoder encodeObject:self.alias forKey:kAlias];
    [aCoder encodeObject:@(self.contactType) forKey:kContactType];
//    [aCoder encodeObject:self.message forKey:@"Message"];
//    [aCoder encodeObject:self.timeStr forKey:@"Time"];
}

@end
