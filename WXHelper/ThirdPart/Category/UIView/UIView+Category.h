//
//  UIView+Category.h
//  Toing
//
//  Created by 刘山国 on 7/5/15.
//  Copyright (c) 2015 山国. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Category)

/**
 *  设置View的圆角
 *
 *  @param radius 圆角半径
 */
- (void)setCircleRadius:(CGFloat)radius;

/**
 *  快捷方法设置边框
 *
 *  @param color color
 *  @param width width
 */
- (void)setBorder:(UIColor*)color With:(CGFloat)width;

/**
 *  快捷方法，获取view的x,y,width,height等
 *
 *  return CGFloat
 */
CGFloat widthOf(id view);

CGFloat heightOf(id view);

CGFloat minXOf(id view);

CGFloat midXOf(id view);

CGFloat maxXOf(id view);

CGFloat minYOf(id view);

CGFloat midYOf(id view);

CGFloat maxYOf(id view);
@end
