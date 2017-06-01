//
//  UIImage+StretchImage.h
//  TingIPhone
//
//  Created by zhou wen on 13-3-13.
//  Copyright (c) 2013年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (StretchImage)

- (UIImage *)stretchableImageWithCenter;
- (UIImage *)stretchableImageWithEdgeInsets:(UIEdgeInsets)insets;

- (UIImage *)safeStretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end
