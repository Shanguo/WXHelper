//
//  WXAccess.m
//  WeiXin
//
//  Created by TanHao on 13-8-25.
//  Copyright (c) 2013年 http://www.tanhao.me. All rights reserved.
//

#import "WXAccess.h"

@implementation WXAccess
@synthesize wxuin,wxsid,deviceID,sKey,syncKey;

- (id)init
{
    self = [super init];
    if (self)
    {
        deviceID = [NSString stringWithFormat:@"e%u",arc4random()];
    }
    return self;
}

+ (instancetype)access
{
    static WXAccess *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WXAccess alloc] init];
    });
    return sharedInstance;
}

- (void)setOwner:(NSDictionary *)owner{
    _owner = owner;
    self.userName = owner[@"UserName"];
}

- (BOOL)isSelfWithUserName:(NSString *)userName{
    if ([userName isEqualToString:[self userName]]) return YES;
    return NO;
}


@end
