//
//  UIImage+StretchImage.m
//  TingIPhone
//
//  Created by zhou wen on 13-3-13.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import "UIImage+StretchImage.h"

@implementation UIImage (StretchImage)

- (UIImage *)stretchableImageWithCenter {
    UIEdgeInsets inset = UIEdgeInsetsMake(self.size.height/2-1, self.size.width/2-1, self.size.height/2-1, self.size.width/2-1);
    return [self stretchableImageWithEdgeInsets:inset];
}

- (UIImage *)stretchableImageWithEdgeInsets:(UIEdgeInsets)insets {
    UIImage *stretchImg = nil;
    if ([self respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        stretchImg = [self resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    } else if ([self respondsToSelector:@selector(stretchableImageWithLeftCapWidth:topCapHeight:)]) {
        stretchImg = [self stretchableImageWithLeftCapWidth:insets.left topCapHeight:insets.top];
    }
    return stretchImg;

}

- (UIImage *)safeStretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0) {
        return [self resizableImageWithCapInsets:UIEdgeInsetsMake(topCapHeight, leftCapWidth, topCapHeight, leftCapWidth)];
    } else {
        return [self stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    }
}

@end
