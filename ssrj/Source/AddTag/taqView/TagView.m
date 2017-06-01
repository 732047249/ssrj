//
//  TagView.m
//  20161101
//
//  Created by MFD on 16/11/1.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "TagView.h"
#import "Masonry.h"
#import "DotView.h"
#import "BubbleView.h"

#define tagView_height 25
@interface TagView()
/** 容纳小圆点，label,点击翻转 */
@property (nonatomic,strong)UIView *containerView;
@property(nonatomic,strong)DotView *dotView;
@property (nonatomic,strong)BubbleView *bubbleView;
/** 点击编辑 */
@property (nonatomic,strong)UIView *textView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation TagView
//超出视图之外的子视图可以接受响应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configParams];
        
        self.containerView = [[UIView alloc] init];
        [self addSubview:self.containerView];
        
        self.dotView = [[DotView alloc] init];
        [self.containerView addSubview:self.dotView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dotTapHandle:)];
        [self.dotView addGestureRecognizer:tap];
        
        self.bubbleView = [[BubbleView alloc] initWithFrame:CGRectMake(0, 0, 130, 25)];
        self.bubbleView.direction = self.direction ? BubbleViewDirectionRight : BubbleViewDirectionLeft;
        self.bubbleView.fontSize = 9;
        self.bubbleView.bubbleHeight = 15;
        self.bubbleView.sharpConers = 7;
        [self.containerView addSubview:self.bubbleView];
        
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(tagView_height, tagView_height));
        }];
        [self.bubbleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.dotView.mas_right);
            make.right.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(tagView_height);
        }];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tagPanHandle:)];
        [self.containerView addGestureRecognizer:self.panGestureRecognizer];
        
    }
    return self;
}
- (void)configParams {
    self.direction = YES;
    self.allowSwitchDirection = YES;
    self.allowPan = YES;
}
//model 为实际现在在面板上的位置。所以如果是从网络加载的数据，model的位置是缩放到当前屏幕下的位置
- (void)setModel:(TagModel *)model {
    _model = model;
    self.bubbleView.title = model.tagText;
    //重新计算位置，自动调取layoutSubviews
    [self setNeedsLayout];
}

- (void)setAllowPan:(BOOL)allowPan {
    _allowPan = allowPan;
    if (_allowPan == NO) {
        [self.containerView removeGestureRecognizer:self.panGestureRecognizer];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = [_model.tagText boundingRectWithSize:CGSizeMake(self.superview.bounds.size.width - self.dotView.dotWidth -  self.bubbleView.sharpConers, self.bubbleView.bubbleHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.bubbleView.fontSize]} context:nil].size;
    
    CGFloat tagViewWidth = size.width + tagView_height + self.bubbleView.sharpConers + 1;
    CGPoint point = _model.point;
    //首先让标签在图片内部
    if (tagViewWidth + _model.point.x > self.superview.frame.size.width) {
        point.x = self.superview.frame.size.width - tagViewWidth;
    }
    if (_model.point.y + tagView_height * 0.5> self.superview.frame.size.height) {
        point.y = self.superview.frame.size.height - tagView_height * 0.5;
    }
    //如果右边更靠近中心点，则反转。
    if (fabs(point.x - self.model.point.x) > fabs(point.x + tagViewWidth - self.model.point.x)) {
        _model.direction = TagDirectionTypeRight;
        
        point.x = self.model.point.x - tagViewWidth;
        if (point.x < 0) {
            point.x = 0;
        }
    }
    //判断中心点距离左边的距离，如果可以大于或等于标签长度，可以反转。
    if (self.model.point.x > tagViewWidth) {
        if (point.x != self.model.point.x) {
            self.model.direction = TagDirectionTypeRight;
            point.x = self.model.point.x - tagViewWidth;
        }
    }
    _model.point = point;
    self.frame = CGRectMake(point.x, point.y - tagView_height * 0.5, tagViewWidth, tagView_height);
    [self displaySubView:_model];
}
- (void)displaySubView:(TagModel *)model {
    
    if (model.direction == TagDirectionTypeLeft) {
        [self.dotView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(tagView_height, tagView_height));
        }];
        [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.left.equalTo(self.dotView.mas_right);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(tagView_height);
        }];
        self.bubbleView.direction = BubbleViewDirectionLeft;
    }else {
        [self.dotView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(tagView_height, tagView_height));
        }];
        [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self.dotView.mas_left);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(tagView_height);
        }];
        self.bubbleView.direction = BubbleViewDirectionRight;
    }
    
}
#pragma mark - event
/** 点击翻转*/
- (void)dotTapHandle:(UITapGestureRecognizer *)recognizer {
    if (!self.allowSwitchDirection) {
        return;
    }
    if (self.model.direction == TagDirectionTypeLeft) {
        self.model.direction = TagDirectionTypeRight;
    }else {
        self.model.direction = TagDirectionTypeLeft;
    }
    [self displaySubView:self.model];
}
/** 拖拽 */
- (void)tagPanHandle:(UIPanGestureRecognizer *)recognizer {
    if (!self.allowPan) {
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        return;
    }
    CGPoint point = self.center;
    UIView *superView = recognizer.view.superview.superview;
    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGFloat pointX = point.x + translation.x;
    CGFloat pointY = point.y + translation.y;
    if (pointX < self.bounds.size.width * 0.5 || pointX > superView.bounds.size.width - self.bounds.size.width * 0.5) {
        pointX = point.x;
    }
    if (pointY < self.bounds.size.height * 0.5 || pointY > superView.bounds.size.height - self.bounds.size.height * 0.5) {
        pointY = point.y;
    }
    self.model.point = CGPointMake(pointX- self.bounds.size.width*0.5 , pointY);
    self.center = CGPointMake(pointX,pointY);
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
}

#pragma mark - set get

#pragma mark - system 
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//    if (action == @selector(cut:)) return YES;
    return NO;
}
@end
