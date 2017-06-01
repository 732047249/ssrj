//
//  LMTextStyle.m
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMTextStyle.h"
#import "UIFont+LMText.m"

@interface LMTextStyle ()

@end

@implementation LMTextStyle

- (instancetype)init {
    if (self = [super init]) {
        _fontSize = [UIFont systemFontSize];
        _textColor = [UIColor blackColor];
    }
    return self;
}

+ (instancetype)textStyleWithType:(LMTextStyleType)type {
    
    LMTextStyle *textStyle = [[self alloc] init];
    textStyle.bold = YES;
    textStyle.type = type;
    textStyle.textColor = [UIColor colorWithHexString:@"#2c2c2c"];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 10;
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.firstLineHeadIndent = 0;
    paragraphStyle.headIndent = 0;
    
    if (type == LMTextStyleFormatTitleSmall) {
        textStyle.fontSize = 16.f;
        textStyle.paragraphStyle = paragraphStyle;
    }else if (type == LMTextStyleFormatTitleLarge) {
        textStyle.fontSize = 18.f;
        textStyle.paragraphStyle = paragraphStyle;
    }else if (type == LMTextStyleFormatList) {
        textStyle.fontSize = 15.f;
        paragraphStyle.firstLineHeadIndent = 20;
        paragraphStyle.headIndent = 30;
        textStyle.paragraphStyle = paragraphStyle;
    }else {
        textStyle.fontSize = 15.f;
        textStyle.bold = NO;
        textStyle.paragraphStyle = paragraphStyle;
    }
    return textStyle;
}

- (LMTextStyleType)type {
    if (self.bold) {
        if (self.fontSize == 15.f) {
            return LMTextStyleFormatList;
        }else if (self.fontSize == 16.f) {
            return LMTextStyleFormatTitleSmall;
        }else {
            return LMTextStyleFormatTitleLarge;
        }
    }else {
        return LMTextStyleFormatNormal;
    }
}
- (UIFont *)font {
    return [UIFont lm_fontWithFontSize:self.fontSize bold:self.bold italic:self.italic];
}

@end
