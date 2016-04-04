//
//  SGMessageBar.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/7.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "SGMessageBar.h"

static CGFloat kSendBtnW    = 40.0f;
static CGFloat kLRSpace     = 8.0f;
static CGFloat kUDSpace     = 5.0f;

#define kHeight (CGRectGetHeight(self.frame)-kUDSpace*2)
#define kRealHeight kHeight>0 ? kHeight : 0

@interface SGMessageBar()

//初始frame
@property(assign,nonatomic)CGRect originalFrame;

@end

@implementation SGMessageBar

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        self.originalFrame = frame;
        self.textField.tag = 10000;
        self.sendBtn.tag = 10001;
        
        [self registerKeyboardNotification];
    }
    return self;
}

#pragma mark - action listenner

- (void)keyboardWillShow:(NSNotification*)notification{
    CGRect _keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self animationTransformWithY:-_keyboardRect.size.height];
}

- (void)keyboardWillHide:(NSNotification*)notification{
    [self animationTransformWithY:0];
}


-(void)sendBtnPress:(UIButton*)sender
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(sgMessageBarClickSendBtn:withText:)]) {
        [self.delegate sgMessageBarClickSendBtn:sender withText:self.textField.text];
    }
    if (self.clearInputWhenSend) {
        self.textField.text = @"";
    }
    if (self.resignFirstResponderWhenSend) {
        [self resignFirstResponder];
    }
}


#pragma mark - override

- (BOOL)resignFirstResponder{
    [self.textField resignFirstResponder];
    return [super resignFirstResponder];
}




#pragma mark - private

- (void)animationTransformWithY:(CGFloat)y{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, y);
                     } completion:nil];
}

- (void)resignKeyboardNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerKeyboardNotification{
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}



#pragma mark - getter
-(UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(kLRSpace, kUDSpace, CGRectGetWidth(self.frame)-kLRSpace-kSendBtnW-kLRSpace, kRealHeight)];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.layer.cornerRadius = 5;
        _textField.layer.masksToBounds = YES;
        [self addSubview:_textField];
    }
    return _textField;
}
-(UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setFrame:CGRectMake(CGRectGetWidth(self.frame)-kSendBtnW-kLRSpace, kUDSpace, kSendBtnW, kRealHeight)];
        [_sendBtn addTarget:self action:@selector(sendBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
    }
    return _sendBtn;
}


-(void)dealloc
{
    [self resignKeyboardNotification];
}


@end






#pragma mark - super override
//将坐标点y 在window和superview转化  方便和键盘的坐标比对
//-(float)convertYFromWindow:(float)Y
//{
//    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    CGPoint o = [appDelegate.window convertPoint:CGPointMake(0, Y) toView:self.superview];
//    return o.y;
//
//}
//-(float)convertYToWindow:(float)Y
//{
//    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    CGPoint o = [self.superview convertPoint:CGPointMake(0, Y) toView:appDelegate.window];
//    return o.y;
//
//}
//-(float)getHeighOfWindow
//{
//    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    return appDelegate.window.frame.size.height;
//}
