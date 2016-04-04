//
//  SGSoundVibrate.h
//  SGiOSSummary
//
//  Created by 刘山国 on 16/3/8.
//  Copyright © 2016年 山国. All rights reserved.
//

/**
 *  系统声音，振动，开放方法无注解，顾名思义
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SGSoundId) {
    SoundNew_Mail           = 1000,
    SoundMail_Sent          = 1001,
    SoundVoice_Mail         = 1002,
    SoundReceive_Msg        = 1003,
    SoundSent_Msg           = 1004,
    SoundAlarm              = 1005,
    SoundLow_Power          = 1006,
    SoundSms1               = 1007,
    SoundSms2               = 1008,
    SoundSms3               = 1009,
    SoundSms4               = 1010,
    SoundSms5               = 1013,
    SoundSms6               = 1014,
    SoundTweet_Sent         = 1016,
    SoundAnticipate         = 1020,
    SoundBloom              = 1021,
    SoundCalypso            = 1022,
    SoundChoo_Choo          = 1023,
    SoundDescent            = 1024,
    SoundFanfare            = 1025,
    SoundLadder             = 1026,
    SoundMinuet             = 1027,
    SoundNews_Flash         = 1028,
    SoundNoir               = 1029,
    SoundSherwood_Forest    = 1030,
    
};

@interface SGSoundVibrate : NSObject

/**
 *  单例模式，请用shareInstance，快捷方法
 *
 *  @return SGSoundVibrate
 */
+ (instancetype)sharedInstance;

- (void)playSystemVibrate;
- (void)stopSystemVibrate;

- (void)playSystemSound;
- (void)playSystemSoundWithId:(SGSoundId)soundId;
- (void)playSystemSoundWithName:(NSString*)soundName;
- (void)playDesignSoundWithName:(NSString*)soundName;
- (void)stopSystemSound;

@end
