//
//  LMTextStyle.h
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LMTextStyleType) {
    LMTextStyleFormatTitleLarge = 1,
    LMTextStyleFormatTitleSmall,
    LMTextStyleFormatNormal,
    LMTextStyleFormatList,
};

@interface LMTextStyle : NSObject

@property (nonatomic, assign) BOOL bold;
@property (nonatomic, assign) BOOL italic;
@property (nonatomic, assign) BOOL underline;

@property (nonatomic, assign) float fontSize;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSParagraphStyle *paragraphStyle;

@property (nonatomic, readonly) UIFont *font;

@property (nonatomic, assign) LMTextStyleType type;
+ (instancetype)textStyleWithType:(LMTextStyleType)type;

@end