//
//  SGMessageBar.h
//  WXHelper
//
//  Created by 刘山国 on 16/3/7.
//  Copyright © 2016年 山国. All rights reserved.
//


/**
 *  简单版，只用发送按钮
 */

#import <UIKit/UIKit.h>

@protocol SGMessageBarDelegate <NSObject>

- (void)sgMessageBarClickSendBtn:(UIButton*)sendBtn withText:(NSString*)text;

@end

@interface SGMessageBar : UIView

@property (nonatomic,assign) id<SGMessageBarDelegate> delegate;
//这两个可以自己付值
@property(strong,nonatomic)UITextField *textField;
@property(strong,nonatomic)UIButton *sendBtn;

//点击btn时候 清空textfield  默认NO
@property(assign,nonatomic)BOOL clearInputWhenSend;
//点击btn时候 隐藏键盘  默认NO
@property(assign,nonatomic)BOOL resignFirstResponderWhenSend;


//隐藏键盘
-(BOOL)resignFirstResponder;
@end
