//
//  VedioPlayViewController.h
//  xiaoLongNvProjuct
//
//  Created by 魏月萍 on 15/6/23.
//  Copyright (c) 2015年 lhMac. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface VedioPlayViewController : MPMoviePlayerViewController

@property (nonatomic,assign) id videoPath;
@property (nonatomic,strong) UIViewController *fatherViewController;
@property (nonatomic,assign) BOOL isPush;
@end
