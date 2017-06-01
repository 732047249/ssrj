//
//  UIImage+New.h
//  CityWifi
//
//  Created by George on 14-7-9.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (New)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (instancetype)captureWithView:(UIView *)view;

@end
