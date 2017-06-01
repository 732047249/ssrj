//
//  HHInforSearchGoodsOrMatchView.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforSearchGoodsOrMatchView.h"

#import "Masonry.h"
@interface HHInforSearchGoodsOrMatchView()

@property (nonatomic,strong)UIView *bgView;
@property (nonatomic,strong)UIImageView *searImageView;
@property (nonatomic,strong)UILabel *label;
@property (nonatomic,strong)UIButton *camaraBtn;


@end
@implementation HHInforSearchGoodsOrMatchView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 3;
        _bgView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSearch)];
        [_bgView addGestureRecognizer:tap];
        [self addSubview:_bgView];
        
        _searImageView = [[UIImageView alloc]init];
        _searImageView.image = [UIImage imageNamed:@"search_icon2"];
        _searImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_bgView addSubview:_searImageView];
        
        _label = [[UILabel alloc]init];
        _label.textColor = [UIColor grayColor];
        _label.font = [UIFont systemFontOfSize:14];
        [_bgView addSubview:_label];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(7, 7, 7, 7));
        }];
        [_searImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_bgView).offset(10);
            make.centerY.equalTo(_bgView);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_searImageView);
            make.left.equalTo(_searImageView.mas_right).offset(6);
            make.right.equalTo(_bgView.mas_right);
        }];
        
        NSString *vcName = [[RJAppManager sharedInstance]currentViewControllerName];
        _bgView.trackingId = [NSString stringWithFormat:@"%@&HHInforSearchGoodsOrMatchView&bgView",vcName];
    }
    return self;
}
- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    _label.text = placeHolder;
}
- (void)clickSearch {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSearchView)]) {
        [self.delegate didClickSearchView];
    }
}
@end
