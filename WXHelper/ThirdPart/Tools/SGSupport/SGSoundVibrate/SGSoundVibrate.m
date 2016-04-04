//
//  SGSoundVibrate.m
//  SGiOSSummary
//
//  Created by 刘山国 on 16/3/8.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "SGSoundVibrate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SGSoundVibrate()

@property (nonatomic,assign) SystemSoundID soundId;
@property (nonatomic,strong) NSDictionary *soundNameDic;

@end

@implementation SGSoundVibrate

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.soundId       = kSystemSoundID_Vibrate;
        self.soundNameDic  = @{
                               @1000:@"new-mail.caf",     @1001:@"mail-sent.caf",
                               @1002:@"Voicemail.caf",    @1003:@"ReceivedMessage.caf",
                               @1004:@"SentMessage.caf",  @1005:@"alarm.caf",
                               @1006:@"low_power.caf",    @1007:@"sms-received1.caf",
                               @1008:@"sms-received2.caf",@1009:@"sms-received3.caf",
                               @1010:@"sms-received4.caf",@1013:@"sms-received5.caf",
                               @1014:@"sms-received6.caf",@1016:@"tweet_sent.caf",
                               @1020:@"Anticipate.caf",   @1021:@"Bloom.caf",
                               @1022:@"Calypso.caf",      @1023:@"Choo_Choo.caf ",
                               @1024:@"Descent.caf",      @1025:@"Fanfare.caf ",
                               @1026:@"Ladder.caf",       @1027:@"Minuet.caf",
                               @1028:@"News_Flash.caf",   @1029:@"Noir.caf ",
                               @1030:@"Sherwood_Forest.caf",
                               };
    }
    return self;
}


+ (instancetype)sharedInstance
{
    static SGSoundVibrate *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SGSoundVibrate alloc] init];
    });
    return sharedInstance;
}
#pragma mark - 振动

- (void)playSystemVibrate{
    [self playWithId:kSystemSoundID_Vibrate];
}

- (void)stopSystemVibrate{
    [self stopWithId:kSystemSoundID_Vibrate];
}


#pragma mark - 声音

- (void)playSystemSound{
    [self playSystemSoundWithId:SoundSms1];
}

- (void)playSystemSoundWithId:(SGSoundId)soundId{
    [self playSystemSoundWithName:self.soundNameDic[@(soundId)]];
}

- (void)playSystemSoundWithName:(NSString*)soundName{
    NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.caf",soundName];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    [self playSoundWithFileURL:fileURL];
   
}

- (void)playDesignSoundWithName:(NSString*)soundName{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
    [self playSoundWithFileURL:fileURL];
}



- (void)stopSystemSound{
    [self stopWithId:self.soundId];
}

#pragma mark - private

- (void)playSoundWithFileURL:(NSURL*)fileUrl{
    if (fileUrl){
        SystemSoundID theSoundID;
        OSStatus error =AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileUrl, &theSoundID);
        if (error == kAudioServicesNoError){
            self.soundId = theSoundID;
            [self playWithId:theSoundID];
        }else{
            NSLog(@"Failed to create sound ");
        }
    }
}

- (void)playWithId:(SystemSoundID)theId{
    AudioServicesPlaySystemSound(theId);
}

- (void)stopWithId:(SystemSoundID)theId{
    AudioServicesDisposeSystemSoundID(theId);
}



@end
