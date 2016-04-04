//
//  SGGlobal.m
//  ToingiOS
//
//  Created by 刘山国 on 15/10/27.
//  Copyright © 2015年 云葵科技. All rights reserved.
//

#import "SGGlobal.h"
#import <MBProgressHUD.h>

@interface SGGlobal()<UIAlertViewDelegate>

@end

@implementation SGGlobal

void SGHudT(NSString* message,float duringTime){
    UIView *view = [[UIApplication sharedApplication]keyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:duringTime];
}

void SGHud(NSString* message){
    UIView *view = [[UIApplication sharedApplication]keyWindow];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

UIAlertView* SGAlert(NSString* message) {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil];
    [alert show];
    return alert;
}


UIAlertView* SGTitleAlert(NSString* title , NSString* message){
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil];
    [alert show];
    return alert;
}

id SGWordsLimit(id textField,NSInteger maxLength){
    UITextView *aTextid = (UITextView*)textField;
    NSString *toBeString = aTextid.text;
    NSString *lang = [aTextid.textInputMode primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxLength) {
                aTextid.text = [toBeString substringToIndex:maxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > maxLength) {
            aTextid.text = [toBeString substringToIndex:maxLength];
        }
    }
    return aTextid;
}


CGSize SGWordsSize(NSString* text,UIFont* font){
    return [text sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
}

CGRect SGWordsRect(CGFloat width,NSString* words,UIFont* font){
    return [words boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName] context:nil];
}

CGRect SGWordsRectWithView(id labelOrTextView){
    UILabel *label = labelOrTextView;
    return SGWordsRect(CGRectGetWidth(label.frame), label.text, label.font);
}

double SGTimeStamp(){
    return [[NSDate date] timeIntervalSince1970];
}

double SGMiliTimeStamp(){
    return  SGTimeStamp()*1000;
}

void SGPostNotificationWithName(NSString *name , id obj, NSDictionary *userinfo){
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj userInfo:userinfo];
}


NSString* SGJsonStringWithObj(id obj){
    if (!obj) return @"";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) return @"";
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonString) return @"";
    return jsonString;
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回obj，可能是nil
 */
id SGObjWithJsonString(NSString *jsonString) {
    if (!jsonString) return nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) return nil;
    id  obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if (!obj) return nil;
    return obj;
}

NSArray * SGArrayWithSet(NSSet *set){
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    NSArray *sortSetArray = [set sortedArrayUsingDescriptors:sortDesc];
    return sortSetArray;
}



@end