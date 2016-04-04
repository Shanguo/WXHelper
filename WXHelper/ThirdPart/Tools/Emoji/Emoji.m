//
//  Emoji.m
//  Emoji
//
//  Created by Aliksandr Andrashuk on 26.10.12.
//  Copyright (c) 2012 Aliksandr Andrashuk. All rights reserved.
//

#import "Emoji.h"
#import "EmojiEmoticons.h"
#import "EmojiMapSymbols.h"
#import "EmojiPictographs.h"
#import "EmojiTransport.h"

@implementation Emoji
+ (NSString *)emojiWithCode:(int)code {
    int sym = EMOJI_CODE_TO_SYMBOL(code);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}
+ (NSArray *)allEmoji {
//    NSMutableArray *array = [NSMutableArray new];
//    [array addObjectsFromArray:[EmojiEmoticons allEmoticons]];
//    [array addObjectsFromArray:[EmojiMapSymbols allMapSymbols]];
//    [array addObjectsFromArray:[EmojiPictographs allPictographs]];
//    [array addObjectsFromArray:[EmojiTransport allTransport]];
    
    NSString *fielPath = [[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:fielPath];
    return array;
}
@end
