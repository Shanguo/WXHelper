//
//  VedioPlayViewController.m
//  xiaoLongNvProjuct
//
//  Created by 魏月萍 on 15/6/23.
//  Copyright (c) 2015年 lhMac. All rights reserved.
//

#import "VedioPlayViewController.h"

#define DEVICE_OS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
@interface VedioPlayViewController ()<UIAlertViewDelegate>

@end

@implementation VedioPlayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (_videoPath != nil) {
        NSURL *url;
        if ([_videoPath isKindOfClass:[NSURL class]]) {
            url = _videoPath;
        }else{
            url = [NSURL URLWithString:_videoPath];
        }
        NSString *path = [url absoluteString];
        [self playerVideoWithPath:path];
    }
    if (_isPush) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }

//    [NSNotificationCenter defaultCenter]
    //监听重载
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finish) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
   
    
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finish{
     NSLog(@"--finished");
    if (_isPush) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [super dismissMoviePlayerViewControllerAnimated];
    }
}





- (void)playerVideoWithPath:(NSString *)videoPath {
    if (videoPath == nil || [videoPath isEqualToString:@""]) {
        return ;
    }
    NSURL *videoUrl = nil;
    if ([videoPath hasPrefix:@"http://"]) {
        videoUrl = [NSURL URLWithString:videoPath];
    }else{
        if([videoPath hasPrefix:@"file://"]){
            videoPath = [videoPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
        
        if(DEVICE_OS_VERSION <=7.0){
            if ([videoPath hasPrefix:@"localhost"]) {
                videoPath =[videoPath stringByReplacingOccurrencesOfString:@"localhost" withString:@""];
            }
        }
        videoUrl = [[NSURL alloc] initFileURLWithPath:videoPath];
    }
    
    NSLog(@"videoUrl = %@",videoUrl);
    MPMoviePlayerViewController *playViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoUrl];
    
    MPMoviePlayerController *player = [playViewController moviePlayer];
    player.scalingMode=MPMovieScalingModeAspectFit;
    
    // 注册一个播放结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    [player play];
    
    [_fatherViewController presentViewController:playViewController animated:YES completion:nil];
}


-(void)movieFinishedCallback:(NSNotification*)notify
{
    NSLog(@"视频播放完成");
    //视频播放对象
    MPMoviePlayerController* theMovie = [notify object];
    //销毁播放通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
    
    
}



@end
