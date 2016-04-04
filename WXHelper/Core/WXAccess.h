//
//  WXAccess.h
//  WeiXin
//
//  Created by TanHao on 13-8-25.
//  Copyright (c) 2013年 http://www.tanhao.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXAccess : NSObject

@property (nonatomic, readonly) NSString *deviceID;
@property (nonatomic, strong) NSString *wxuin;//UUID
@property (nonatomic, strong) NSString *wxsid;//SID
@property (nonatomic, strong) NSString *sKey;
@property (nonatomic, strong) NSArray *syncKey;
@property (nonatomic, strong) NSDictionary *owner;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,strong) UIImage *headImage;
@property (nonatomic,copy) NSString *passTicket;
//@property (nonatomic,assign) BOOL state;

+ (instancetype)access;

- (BOOL)isSelfWithUserName:(NSString*)userName;

@end
