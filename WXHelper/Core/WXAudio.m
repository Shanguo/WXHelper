//
//  WXAudio.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/9.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXAudio.h"
#import <AVFoundation/AVFoundation.h>

@interface WXAudio()<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder    *recorder;
@property (nonatomic,strong) AVAudioPlayer      *player;
@property (nonatomic,strong) NSTimer            *timer;

@end

@implementation WXAudio



- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setAudioSession];
    }
    return self;
}


/**
 *  设置音频会话
 */
- (void)setAudioSession{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];
}



#pragma mark - public 



/**
 *  录音按钮
 *
 *  @param sender button
 */
- (void)startRecord{
    if (![self.recorder isRecording]) {
        [self.recorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }
}


/**
 *  暂停按钮
 *
 *  @param sender button
 */
- (void)pauseRecord {
    if ([self.recorder isRecording]) {
        [self.recorder pause];
        self.timer.fireDate=[NSDate distantFuture];
    }
}

/**
 *  点击恢复按钮
 *  恢复录音只需要再次调用record，AVAudioSession会帮助你记录上次录音位置并追加录音
 *
 *  @param sender 恢复按钮
 */
- (void)resumeRecod {
    [self startRecord];
}

/**
 *  停止录音按钮
 *
 *  @param sender button
 */
- (void)stopRecord {
    [self.recorder stop];
    self.timer.fireDate=[NSDate distantFuture];
}


/**
 *  录音声波状态设置
 */
-(float)audioPower{
    [self.recorder updateMeters];//更新测量值
    float power= [self.recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    NSLog(@"power==%.f",power);
    
    return power;
}


/**
 *  播放录音
 */
- (void)playRecord{
    if (![self.player isPlaying]) {
        [self.player play];
    }
}


#pragma mark - delegate

/**
 *  代理方法，完成录音
 *
 *  @param recorder recorder
 *  @param flag     是否成功
 */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音完成!");
}


#pragma mark - private


/**
 *  取得录音保存文件路径
 *
 *  @return 录音文件路径
 */
- (NSURL *)getSavePath{
    
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"record.caf"]];
    NSLog(@"url-->%@",url);
    return url;
}


/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}


/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
- (AVAudioRecorder *)recorder{
    if (!_recorder) {
        NSURL *url = [self getSavePath];
        NSDictionary *setting = [self getAudioSetting];
        NSError * error = nil;
        _recorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
        
    }
    return _recorder;
}



/**
 *  创建播放器
 *
 *  @return 播放器
 */
- (AVAudioPlayer *)player{
    if (!_player) {
        NSURL *url = [self getSavePath];
        NSError *error = nil;
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _player.numberOfLoops=0;
        [_player prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _player;
    
//    NSURL *url = [NSURL URLWithString:_filePath];
//    NSError *error;
//    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
//    [_audioPlayer play];
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPower) userInfo:nil repeats:YES];
    }
    return _timer;
}




@end
