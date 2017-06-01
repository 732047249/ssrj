//
//  UIImage+Pixel.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Pixel)
/**
 将不透明的颜色转成固定颜色值
 */
+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue alpha:(CGFloat)alpha;
@end
