//
//  SMAllGoodsHeaderView.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMAllGoodsSearchView.h"
#import "Masonry.h"
@interface SMAllGoodsSearchView()

@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIImageView *searImageView;
@property (nonatomic,strong)UILabel *label;
@property (nonatomic,strong)UIButton *camaraBtn;


@end
@implementation SMAllGoodsSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 2;
        _bgView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSearch)];
        [_bgView addGestureRecognizer:tap];
        [self addSubview:_bgView];
        
        _searImageView = [[UIImageView alloc]init];
        _searImageView.image = [UIImage imageNamed:@"search_icon2"];
        _searImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_bgView addSubview:_searImageView];
        
        _label = [[UILabel alloc]init];
        _label.text = @"搜索单品";
        _label.font = [UIFont systemFontOfSize:13];
        _label.textColor = [UIColor grayColor];
        [_bgView addSubview:_label];
        
        _camaraBtn = [[UIButton alloc]init];
        _camaraBtn.backgroundColor = [UIColor whiteColor];
        _camaraBtn.layer.cornerRadius = 2;
        [_camaraBtn setImage:[UIImage imageNamed:@"match_camera"] forState:UIControlStateNormal];
        [_camaraBtn addTarget:self action:@selector(camaraBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_camaraBtn];
        
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(7, 7, 7, 65));
        }];
        [_searImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_bgView).offset(10);
            make.centerY.equalTo(_bgView);
            make.size.mas_equalTo(CGSizeMake(14, 14));
        }];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_searImageView);
            make.left.equalTo(_searImageView.mas_right).offset(7.5);
            make.right.equalTo(_bgView.mas_right);
        }];
        [_camaraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_bgView);
            make.left.equalTo(_bgView.mas_right).offset(10);
            make.right.equalTo(self).offset(-10);
        }];
    }
    NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
    _camaraBtn.trackingId = [NSString stringWithFormat:@"%@&SMAllGoodsSearchView&camaraBtn",vcName];
    _bgView.trackingId = [NSString stringWithFormat:@"%@&SMAllGoodsSearchView&bgView",vcName];
    return self;
}
- (void)clickSearch {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSearchView)]) {
        [self.delegate didClickSearchView];
    }
}
- (void)camaraBtnClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCamara)]) {
        [self.delegate didClickCamara];
    }
}
@end
