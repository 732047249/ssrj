//
//  SMMatchImage.m
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "SMMatchImageView.h"
@interface SMMatchImageView()
@property (nonatomic,strong)UIBezierPath *path;
@end
@implementation SMMatchImageView
{
    BOOL panState,rotateState,pinchState;
}
/** 为图片添加手势 */
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        panState = YES;
        rotateState = YES;
        pinchState = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [self addGestureRecognizer:oneTap];
        UIPanGestureRecognizer *onePan = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(handlePan:)];
        onePan.delegate = self;
        [self addGestureRecognizer:onePan];
        //pinch缩放
        UIPinchGestureRecognizer *onePinch = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(handlePinch:)];
        onePinch.delegate = self;
        [self addGestureRecognizer:onePinch];
        //旋转
        UIRotationGestureRecognizer *rotateOne = [[UIRotationGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(handleRotate:)];
        rotateOne.delegate = self;
        [self addGestureRecognizer:rotateOne];
        [oneTap requireGestureRecognizerToFail:onePan];
        
        [self configLayer];
        
    }
    return self;
}
- (void)configLayer {
    _borderLayer = [[CAShapeLayer alloc] init];
    _borderLayer.strokeColor = [UIColor colorWithHexString:@"#5d32b5"].CGColor;
    _borderLayer.fillColor = [UIColor clearColor].CGColor;
    _borderLayer.hidden = YES;
    _borderLayer.lineWidth = 1;
    [self.layer addSublayer:_borderLayer];
    
    _path = [[UIBezierPath alloc] init];
}
- (void)setTransform:(CGAffineTransform)transform {
    [super setTransform:transform];
    //解决边框width变宽
    CGFloat scale = [self getScaleFromTransform:transform];
    self.borderLayer.lineWidth = 1.0 / scale;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [_path removeAllPoints];
    [_path moveToPoint:CGPointMake(0, 0)];
    [_path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [_path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [_path addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    [_path closePath];
    _borderLayer.path = _path.CGPath;
}
/**点击图片*/
- (void)imageTap:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapMatchImage:)]) {
        [self.delegate didTapMatchImage:self];
    }
}

/** ImageView拖动 */
- (void)handlePan:(UIPanGestureRecognizer*) recognizer
{
    CGPoint originalCenter = recognizer.view.center;
    
    CGPoint translation = [recognizer translationInView:self.superview];
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
//    /**
//     限制边距
//     */
//    CGPoint center = recognizer.view.center;
//    CGRect frame = recognizer.view.frame;
//    if (CGRectGetMaxX(frame) >= kScreenWidth) {
//        if (center.x > originalCenter.x) {
//            center.x = originalCenter.x;
//        }
//    }
//    if (CGRectGetMinX(frame) <= 0) {
//        if (center.x < originalCenter.x) {
//            center.x = originalCenter.x;
//        }
//    }
//    if (CGRectGetMaxY(frame) >= kScreenWidth) {
//        if (center.y > originalCenter.y) {
//            center.y = originalCenter.y;
//        }
//    }
//    if (CGRectGetMinY(frame) <= 0) {
//        if (center.y < originalCenter.y) {
//            center.y = originalCenter.y;
//        }
//    }
//    recognizer.view.center = center;
    
    [recognizer setTranslation:CGPointZero inView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        panState = NO;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        panState = YES;
    }
    if (rotateState && pinchState && panState) {
//        NSLog(@"frame  -- %@",NSStringFromCGRect(self.frame));
//        NSLog(@"bounds -- %@",NSStringFromCGRect(self.bounds));
//        NSLog(@"center -- %@",NSStringFromCGPoint(self.center));
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReseiveImageRegesture:)]) {
            [self.delegate didReseiveImageRegesture:recognizer];
        }
    }
}
/** imageView缩放 */
- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer
{
    
    /**
     
     限制缩放在固定尺寸
     
     */
    CGAffineTransform transform = CGAffineTransformScale(self.transform, recognizer.scale, recognizer.scale);
    if (self.bounds.size.width * [self getScaleFromTransform:transform] <= 40 || self.bounds.size.height * [self getScaleFromTransform:transform] <= 40) {
        return;
    }
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        pinchState = NO;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        pinchState = YES;
    }
    if (rotateState && pinchState && panState) {
//        NSLog(@"frame  -- %@",NSStringFromCGRect(self.frame));
//        NSLog(@"bounds -- %@",NSStringFromCGRect(self.bounds));
//        NSLog(@"center -- %@",NSStringFromCGPoint(self.center));
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReseiveImageRegesture:)]) {
            [self.delegate didReseiveImageRegesture:recognizer];
        }
    }
}
/** imageView旋转 */
- (void) handleRotate:(UIRotationGestureRecognizer*) recognizer
{
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, (self.isFlipX ? (-1):1) *  recognizer.rotation);
    recognizer.rotation = 0;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        rotateState = NO;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        rotateState = YES;
    }
    if (rotateState && pinchState && panState) {
//        NSLog(@"frame  -- %@",NSStringFromCGRect(self.frame));
//        NSLog(@"bounds -- %@",NSStringFromCGRect(self.bounds));
//        NSLog(@"center -- %@",NSStringFromCGPoint(self.center));
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReseiveImageRegesture:)]) {
            [self.delegate didReseiveImageRegesture:recognizer];
        }
    }
    
}
//根据transform 获得放大倍数
- (CGFloat)getScaleFromTransform:(CGAffineTransform)transform {
    CGFloat angle = atanf(transform.b / transform.a);
    CGFloat scale = transform.a / cos(angle);
//    NSLog(@"不考虑flip--  scale --- %f",scale);
    //翻转scale会变为负数。取绝对值
    return fabs(scale);
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
@end
