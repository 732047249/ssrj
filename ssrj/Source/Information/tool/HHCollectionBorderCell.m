//
//  HHCollectionBorderCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHCollectionBorderCell.h"
#import "Masonry.h"
@interface HHCollectionBorderCell()

@property (nonatomic,strong)UIView *topLine;
@property (nonatomic,strong)UIView *leftLine;
@property (nonatomic,strong)UIView *rightLine;
@property (nonatomic,strong)UIView *bottomLine;
@end

@implementation HHCollectionBorderCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _topLine  =[self createLine];
        [self addSubview:_topLine];
        _leftLine  =[self createLine];
        [self addSubview:_leftLine];
        _bottomLine  =[self createLine];
        [self addSubview:_bottomLine];
        _rightLine  =[self createLine];
        [self addSubview:_rightLine];
        
        [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(0.75);
        }];
        [_leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.width.mas_equalTo(0.75);
        }];
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(0.75);
        }];
        [_rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self);
            make.width.mas_equalTo(0.75);
        }];
    }
    return self;
}
- (UIView *)createLine {
    UIView * line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
    [self addSubview:line];
    return line;
}
- (void)showAllLine {
    _topLine.hidden = NO;
    _leftLine.hidden = NO;
    _bottomLine.hidden = NO;
    _rightLine.hidden = NO;
}
- (void)hiddenTopLine {
    _topLine.hidden = YES;
}
- (void)hiddenLeftLine {
    _leftLine.hidden = YES;
}
@end

