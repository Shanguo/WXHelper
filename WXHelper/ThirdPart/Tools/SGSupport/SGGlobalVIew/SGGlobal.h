//
//  SGGlobalb.h
//  ToingiOS
//
//  Created by 刘山国 on 15/10/27.
//  Copyright © 2015年 云葵科技. All rights reserved.
//

/**
 *  使用本文件需要同时使用第三方：
 *  pod 'MBProgressHUD', '~> 0.9.1'
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SGGlobal : NSObject

/**
 * A convenient way to show a MBProgressHUD with a message and it will be removed 2s later. 
 */
void SGHud(NSString* message);
void SGHudT(NSString* message,float duringTime);
/**
 * A convenient way to show a UIAlertView with a message.
 */
UIAlertView* SGAlert(NSString* message);
UIAlertView* SGTitleAlert(NSString* title , NSString* message);

/**
 * A convenient way to limit words number of a TextField or TextView
 */
id SGWordsLimit(id textField,NSInteger maxLength);

/**
 * A convenient way to get words size
 */
CGSize SGWordsSize(NSString* text,UIFont* font);

/**
 *  根据View获文字frame，注意：view必须有text属性(UILabel,UITextView),并且text已经被赋值，font已确定
 *
 *  @param labelOrTextView 有公开属性text的View
 *
 *  @return bounds
 */
CGRect SGWordsRectWithView(id labelOrTextView);

/**
 *  SGWordsRect
 *
 *  @param width 宽度
 *  @param words words
 *  @param font  font
 *
 *  @return bounds
 */
CGRect SGWordsRect(CGFloat width,NSString* words,UIFont* font);

/**
 *  距离1970年的时间戳，单位秒
 *
 *  @return 时间戳，秒
 */
double SGTimeStamp();
double SGMiliTimeStamp();

/**
 *  抛出通知
 *
 *  @param name     通知名称
 *  @param obj      self
 *  @param userinfo dic
 */
void SGPostNotificationWithName(NSString *name , id obj, NSDictionary *userinfo);

/**
 *  生成json
 *
 *  @param obj array or dictionary
 *
 *  @return string
 */
NSString* SGJsonStringWithObj(id obj);

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回obj，可能是nil
 */
id SGObjWithJsonString(NSString *jsonString);

/**
 *  Set 转 Array
 *
 *  @param set set
 *
 *  @return Array
 */
NSArray * SGArrayWithSet(NSSet *set);

@end
