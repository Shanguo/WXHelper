//
//  WXFriendCell.m
//  WXHelper
//
//  Created by 刘山国 on 16/3/6.
//  Copyright © 2016年 山国. All rights reserved.
//

#import "WXFriendCell.h"
#import <UIImageView+WebCache.h>
#import "WXCoreHelper.h"
#import "WXMessage.h"
#import "WXContact.h"

@interface WXFriendCell()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation WXFriendCell

- (void)awakeFromNib {
    [self.nameLabel setText:@"无名字"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setContact:(WXContact *)contact{
    _contact = contact;
    
//    [self.headImageView sd_setImageWithURL:contact.headImgURL];
    
    if (!contact.headImage)  contact.headImage = [WXCoreHelper imageWithURL:contact.headImgURL];
    [self.headImageView setImage:contact.headImage];
    
    if (contact.remarkName.length>0) {
        [self.nameLabel setText:contact.remarkName];
    }else if(contact.nickName.length>0){
        [self.nameLabel setText:contact.nickName];
    }else{
        [self.nameLabel setText:contact.displayName];
    }
    
//    [self.messageLabel setText:contact.message];
//    [self.timeLabel setText:contact.timeStr];
    
}



- (void)setMessage:(WXMessage *)message{
    if (!message) {
        [self.timeLabel setText:@""];
        [self.messageLabel setText:@""];
        return;
    }
    
    _message = message;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *dateStr =[dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.createTime]];
    [self.timeLabel setText:dateStr];
    
    if (message.msgType         ==  MTypeText) {
        self.messageLabel.text  =   message.content;
    }else if (message.msgType   ==  MTypeImage){
        self.messageLabel.text  =   @"[图片]";
    }else if(message.msgType    ==  MTypeAnimationImg){
        self.messageLabel.text  =   @"[动画表情]";
    }else if(message.msgType    ==  MTypeVideo){
        self.messageLabel.text  =   @"[视频]";
    }else if(message.msgType    ==  MTypeVoice){
        self.messageLabel.text  =   @"[语音]";
    }
    
}




@end
