//
//  DotView.m
//  ssrj
//
//  Created by MFD on 16/11/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "DotView.h"
#import "Masonry.h"

@interface DotView()
/** 容纳小圆点和线，label,点击翻转 */
@property(nonatomic,strong)UIView *smallDot;
@property(nonatomic,strong)UIView *bigDot;
@property (nonatomic, assign) BOOL flag;

@end
@implementation DotView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configParams];
        
        self.smallDot = [[UIView alloc]init];
        [self addSubview:_smallDot];
        self.smallDot.backgroundColor = self.dotColor;
        self.smallDot.layer.cornerRadius = self.smallDotRadius;
        self.smallDot.layer.masksToBounds = YES;
        [self.smallDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(self.smallDotRadius * 2, self.smallDotRadius * 2));
        }];
    }
    return self;
}
- (void)configParams {
    self.smallDotRadius = 3;
    self.bigDotAlpha = 0.5;
    self.dotColor = [UIColor colorWithRed:81 / 256.0 green:44/256.0 blue:175/256.0 alpha:1];
    self.repeatCount = 2.5;
    self.animationTime = 0.6;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.flag) {
        [self beganAnimation];
    }
    self.flag = YES;
}
- (CGFloat)dotWidth {
    return self.smallDotRadius * 4;
}
- (void)beganAnimation {
    
    CGFloat scaleLayerWH = self.smallDotRadius * 2;
    CGPoint position = self.smallDot.center;
    
    CALayer *scaleLayer = [[CALayer alloc] init];
    scaleLayer.backgroundColor = [self.dotColor colorWithAlphaComponent:self.bigDotAlpha].CGColor;
    scaleLayer.bounds = CGRectMake(0, 0, scaleLayerWH, scaleLayerWH);
    scaleLayer.position = position;
    scaleLayer.shadowOffset = CGSizeMake(0, scaleLayerWH);
    scaleLayer.shadowRadius = 3.0f;
    scaleLayer.shadowOpacity = 0.5f;
    scaleLayer.cornerRadius = scaleLayerWH * 0.5;
    scaleLayer.masksToBounds = YES;
    [self.layer insertSublayer:scaleLayer below:_smallDot.layer];
    
    
    CABasicAnimation *scaleAnimation = [[CABasicAnimation alloc] init];
    scaleAnimation.keyPath = @"transform.scale"; // 设置动画的方式
    scaleAnimation.fromValue = [NSNumber numberWithInteger:1]; // 起点
    scaleAnimation.toValue = [NSNumber numberWithInteger:2]; // 终点
    scaleAnimation.duration = self.animationTime; // 设置动画的时间
    scaleAnimation.repeatCount = self.repeatCount; // 设置动画的次数
    scaleAnimation.autoreverses = YES; // 返回原始状态是否动画方式
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    [scaleLayer addAnimation:scaleAnimation forKey:@"scale"]; // 添加动画
}

@end
