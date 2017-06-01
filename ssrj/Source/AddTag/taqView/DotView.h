//
//  DotView.h
//  ssrj
//
//  Created by MFD on 16/11/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotView : UIView

@property (nonatomic, assign) CGFloat smallDotRadius;
@property (nonatomic, assign) CGFloat bigDotAlpha;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, assign) CGFloat repeatCount;
@property (nonatomic, assign) CGFloat animationTime;
@property (nonatomic, assign, readonly) CGFloat dotWidth;

- (void)beganAnimation;
@end
