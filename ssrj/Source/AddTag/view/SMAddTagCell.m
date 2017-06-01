//
//  SMAddTagCell.m
//  ssrj
//
//  Created by MFD on 16/11/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMAddTagCell.h"
#import "Masonry.h"
@interface SMAddTagCell()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *goodsNameLabel;
@property (nonatomic,strong)UILabel *brandNameLabel;
@property (nonatomic,strong)UILabel *currentPriceLabel;
@property (nonatomic,strong)UILabel *deprecedPriceLabel;
@end
@implementation SMAddTagCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self).offset(15);
            make.height.mas_equalTo(114);
        }];
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:[UIImage imageNamed:@"tag_delete"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_imageView.mas_right);
            make.centerY.equalTo(_imageView.mas_top);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        _goodsNameLabel = [[UILabel alloc]init];
        _goodsNameLabel.font = [UIFont boldSystemFontOfSize:14];
        _goodsNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_goodsNameLabel];
        
        _brandNameLabel = [[UILabel alloc]init];
        _brandNameLabel.textAlignment = NSTextAlignmentCenter;
        _brandNameLabel.font = [UIFont systemFontOfSize:11];
        _brandNameLabel.textColor = [UIColor colorWithHexString:@"#aaabae"];
        [self addSubview:_brandNameLabel];
        
        _currentPriceLabel = [[UILabel alloc]init];
        _currentPriceLabel.font = [UIFont systemFontOfSize:11];
        _currentPriceLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_currentPriceLabel];
        
        _deprecedPriceLabel = [[UILabel alloc]init];
        _deprecedPriceLabel.font = [UIFont systemFontOfSize:11];
        _deprecedPriceLabel.textAlignment = UIViewContentModeCenter;
        _deprecedPriceLabel.textColor = [UIColor colorWithHexString:@"#aaabae"];
        [self addSubview:_deprecedPriceLabel];
        
        //frame
        [_goodsNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_imageView);
            make.height.mas_equalTo(16);
            make.top.equalTo(_imageView.mas_bottom).offset(4);
        }];
        [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_imageView);
            make.top.equalTo(_goodsNameLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(12);
        }];
        [_currentPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_imageView);
            make.width.equalTo(_imageView).multipliedBy(0.5);
            make.top.equalTo(_brandNameLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(12);
        }];
        [_deprecedPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_currentPriceLabel);
            make.left.equalTo(_currentPriceLabel.mas_right);
            make.right.equalTo(_imageView);
        }];
        
    }
    return self;
}
- (void)btnClick:(UIButton *)sender {
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}
- (void)setModel:(SMGoodsModel *)model {
    _model = model;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    _brandNameLabel.text = model.brand_name;
    _goodsNameLabel.text = model.name;
    _currentPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",model.price];
    _deprecedPriceLabel.text = [NSString stringWithFormat:@"￥%.2f",model.market_price];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_deprecedPriceLabel.text ];
    [string addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, string.string.length)];
    _deprecedPriceLabel.attributedText = string;
}
@end
