//
//  WXHGlobal.m
//  WXHelper
//
//  Created by 刘山国 on 16/2/28.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXHGlobal.h"

@implementation WXHGlobal

+ (NSString *)timeStampStr{
    return [NSString stringWithFormat:@"%.0f",SGTimeStamp()*1000];
}

@end
