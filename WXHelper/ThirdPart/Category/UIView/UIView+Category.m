//
//  UIView+Category.m
//  Toing
//
//  Created by 刘山国 on 7/5/15.
//  Copyright (c) 2015 山国. All rights reserved.
//

#import "UIView+Category.h"

@implementation UIView(Category)

-(void)setCircleRadius:(CGFloat)radius{
    self.layer.cornerRadius=radius;
    [self.layer setMasksToBounds:YES];
}

-(void)setBorder:(UIColor *)color With:(CGFloat)width{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

CGFloat widthOf(id view){
    return CGRectGetWidth(((UIView*)view).bounds);
}

CGFloat heightOf(id view){
    return CGRectGetHeight(((UIView*)view).bounds);
}

CGFloat minXOf(id view){
    return CGRectGetMinX(((UIView*)view).frame);
}

CGFloat midXOf(id view){
    return CGRectGetMidX(((UIView*)view).frame);
}

CGFloat maxXOf(id view){
    return CGRectGetMaxX(((UIView*)view).frame);
}

CGFloat minYOf(id view){
    return CGRectGetMinY(((UIView*)view).frame);
}

CGFloat midYOf(id view){
    return CGRectGetMidY(((UIView*)view).frame);
}

CGFloat maxYOf(id view){
    return CGRectGetMaxY(((UIView*)view).frame);
}

@end
