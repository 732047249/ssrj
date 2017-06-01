//
//  BubbleView.m
//  ssrj
//
//  Created by MFD on 16/11/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "BubbleView.h"
#import "Masonry.h"
@interface BubbleView()
@property (nonatomic,strong)UILabel *label;
@property (nonatomic,strong)CAShapeLayer *shapeLayer;

@property (nonatomic, strong) UIColor *bubbleColor;
@property (nonatomic, strong) UIColor *titleColor;

@end

@implementation BubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configParams];
        self.backgroundColor = [UIColor clearColor];
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = self.bubbleColor.CGColor;
        [self.layer addSublayer:self.shapeLayer];
        
        _label = [[UILabel alloc]init];
        _label.font = [UIFont systemFontOfSize:self.fontSize];
        _label.textColor = self.titleColor;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
    }
    return self;
}
- (void)configParams {
    self.direction = BubbleViewDirectionLeft;
    self.bubbleHeight = 15;
    self.fontSize = 9;
    self.sharpConers = 7;
    self.bubbleColor = [[UIColor colorWithRed:20 / 256.0 green:13 / 256.0 blue:49 / 256.0 alpha:1] colorWithAlphaComponent:0.8];
    self.titleColor = [UIColor whiteColor];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _label.text = title;
}
- (void)setDirection:(BubbleViewDirection)direction {
    _direction = direction;
    _direction = BubbleViewDirectionArc;
    [self setNeedsLayout];
}
- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    self.label.font = [UIFont systemFontOfSize:fontSize];
}

- (void)setSharpConers:(CGFloat)sharpConers {
    _sharpConers = sharpConers;
    [self setNeedsLayout];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat leftPage = 0;
    CGFloat rightPage = 0;
    switch (self.direction) {
        case BubbleViewDirectionArc:
        {
            CGPoint one = CGPointMake(self.sharpConers, self.frame.size.height * 0.5 - self.bubbleHeight * 0.5);
            CGPoint two = CGPointMake(self.bounds.size.width - self.sharpConers, one.y);
            CGPoint three = CGPointMake(two.x,two.y + self.bubbleHeight);
            CGPoint four = CGPointMake(one.x, three.y);
            
            [path moveToPoint:one];
            [path addLineToPoint:two];
            [path addArcWithCenter:CGPointMake(two.x, self.bounds.size.height * 0.5) radius:self.bubbleHeight * 0.5 startAngle:1.5 *M_PI endAngle:M_PI_2 clockwise:YES];
            [path addLineToPoint:four];
            [path addArcWithCenter:CGPointMake(one.x, self.bounds.size.height * 0.5) radius:self.bubbleHeight * 0.5 startAngle:M_PI_2 endAngle:1.5 * M_PI clockwise:YES];
            
            leftPage = self.sharpConers * 0.5;
            rightPage = - self.sharpConers * 0.5;
        }
            break;
           
        case BubbleViewDirectionLeft:
        {
            CGPoint pointOne = CGPointMake(0, self.frame.size.height * 0.5);
            CGPoint pointTwo = CGPointMake(self.sharpConers, pointOne.y - self.bubbleHeight * 0.5);
            CGPoint pointThree = CGPointMake(self.frame.size.width, pointOne.y - self.bubbleHeight * 0.5);
            CGPoint pointFore = CGPointMake(pointThree.x, pointOne.y + self.bubbleHeight * 0.5);
            CGPoint pointFive = CGPointMake(pointTwo.x, pointFore.y);
            path = [[UIBezierPath alloc] init];
            [path moveToPoint:pointOne];
            [path addLineToPoint:pointTwo];
            [path  addLineToPoint:pointThree];
            [path addLineToPoint:pointFore];
            [path addLineToPoint:pointFive];
            [path closePath];
            
            leftPage = self.sharpConers;
        }
            break;
            
        case BubbleViewDirectionRight:
        {
            CGPoint right_pointOne = CGPointMake(0, self.frame.size.height * 0.5 - self.bubbleHeight * 0.5);
            CGPoint right_pointTwo = CGPointMake(self.frame.size.width - self.sharpConers, right_pointOne.y);
            CGPoint right_pointThree = CGPointMake(self.frame.size.width, self.frame.size.height * 0.5);
            CGPoint right_pointFore = CGPointMake(right_pointTwo.x, right_pointThree.y + self.bubbleHeight * 0.5);
            CGPoint right_pointFive = CGPointMake(0, self.bubbleHeight * 0.5 + self.frame.size.height * 0.5);
            
            path = [[UIBezierPath alloc] init];
            [path moveToPoint:right_pointOne];
            [path addLineToPoint:right_pointTwo];
            [path  addLineToPoint:right_pointThree];
            [path addLineToPoint:right_pointFore];
            [path addLineToPoint:right_pointFive];
            [path closePath];
            
            rightPage = -self.sharpConers;
        }
            break;
        default:
            break;
    }
    
    _shapeLayer.path = path.CGPath;
    
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(leftPage);
        make.right.equalTo(self).offset(rightPage);
    }];
}


@end
