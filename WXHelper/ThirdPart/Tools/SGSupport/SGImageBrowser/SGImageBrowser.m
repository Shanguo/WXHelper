//
//  SGImageBrowser.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/31.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "SGImageBrowser.h"
#import <SDWebImageDownloader.h>
#import <SDWebImageManager.h>


static CGRect oldframe;

@implementation SGImageBrowser


+ (void)showImageView:(UIImageView*)imageView biggerImageUrl:(id)imageUrl canBeSaved:(BOOL)canbeSaved{
//    if ([imageUrl isKindOfClass:[NSString class]]) imageUrl = [NSURL URLWithString:imageUrl];
    [[self class] showImageView:imageView BiggerImageURl:(NSURL*)imageUrl biggerImage:nil canBeSaved:canbeSaved];
}

+ (void)showImageView:(UIImageView*)imageView biggerImage:(UIImage*)biggerImage canBeSaved:(BOOL)canbeSaved{
    [[self class] showImageView:imageView BiggerImageURl:nil biggerImage:biggerImage canBeSaved:canbeSaved];
}

+ (void)showImageView:(UIImageView*)anImageView BiggerImageURl:(id)imageUrl biggerImage:(UIImage*)biggerImage canBeSaved:(BOOL)canbeSaved{
    UIImage *image=anImageView.image;
    if (biggerImage) image = biggerImage;
  
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe=[anImageView convertRect:anImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    if (canbeSaved) {
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
        [backgroundView addGestureRecognizer:longpress];
    }
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,
                                   ([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2,
                                   [UIScreen mainScreen].bounds.size.width,
                                   image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        if (imageUrl) {
//            if ([imageUrl isKindOfClass:[NSString class]]) imageUrl = [NSURL URLWithString:imageUrl];
//            SGHud(@"")
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:imageView animated:YES];
            [WXCoreHelper asyncImageWithURLStr:(NSString*)imageUrl Complete:^(BOOL isSuccess, UIImage *image) {
                imageView.image = image;
                [imageView setNeedsDisplay];
                [hud removeFromSuperview];
            }];
        }
    }];
}



#pragma mark - private




+ (void)longPressGesture:(UILongPressGestureRecognizer*)sender{
    //    if (sender.state == UIGestureRecognizerStateBegan) {
    //         UIImageView *imageView=(UIImageView*)[sender.view viewWithTag:1];
    //        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //        UIView *view = appDelegate.window.rootViewController.view;
    //        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存照片", nil];
    //        sheet.actionSheetStyle = UIAlertViewStyleSecureTextInput;
    //        [sheet showInView:view];
    //
    //        [[sheet rac_buttonClickedSignal] subscribeNext:^(id x) {
    //            if ([x integerValue]==0) {
    //                if (imageView&&imageView.image) {
    //                    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    //                }
    //            }
    //        }];
    //    }
    //
}
+ (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    //    NSString *message = @"呵呵";
    //    if (!error) {
    //        message = @"成功保存到相册";
    //        [YKBasic ConfirmAlertWithMsg:message];
    //    }else
    //    {
    //        message = [error description];
    ////        [YKBasic BDNotifyWithImageName:nil Text:@"保存照片失败!" YMove:0];
    //        [YKBasic ConfirmAlertWithMsg:@"保存照片失败!"];
    //    }
    //    NSLog(@"message is %@",message);
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}


@end
