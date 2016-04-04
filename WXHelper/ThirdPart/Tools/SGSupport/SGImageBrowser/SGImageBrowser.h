//
//  SGImageBrowser.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/31.
//  Copyright © 2016年 山国. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGImageBrowser : NSObject

+ (void)showImageView:(UIImageView*)imageView biggerImageUrl:(id)imageUrl canBeSaved:(BOOL)canbeSaved;

+ (void)showImageView:(UIImageView*)imageView biggerImage:(UIImage*)biggerImage canBeSaved:(BOOL)canbeSaved;

@end
