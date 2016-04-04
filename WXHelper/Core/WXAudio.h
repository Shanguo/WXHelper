//
//  WXAudio.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/9.
//  Copyright © 2016年 山国. All rights reserved.
//

/**
 *  录音器，音频播放器
 */

#import <Foundation/Foundation.h>

@interface WXAudio : NSObject


- (void)startRecord;

- (void)pauseRecord;

- (void)resumeRecod;

- (void)stopRecord;

-(float)audioPower;

- (void)playRecord;

@end
