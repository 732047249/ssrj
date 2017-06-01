//
//  HHTextAttachment.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HHImageStyle.h"
@interface HHTextAttachment : NSTextAttachment


+ (instancetype)attachmentWithImage:(UIImage *)image width:(CGFloat)width;

@property (nonatomic, strong) HHImageStyle *imageStyle;
@end
