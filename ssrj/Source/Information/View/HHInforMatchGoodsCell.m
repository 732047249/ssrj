//
//  HHInforMatchGoodsCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforMatchGoodsCell.h"
#import "RJBaseGoodModel.h"
#import "Masonry.h"
@interface HHInforMatchGoodsCell()

@property (nonatomic,strong) UIImageView *picImageView;
@property (nonatomic,strong) UILabel *goodsNameLabel;
@property (nonatomic,strong) UILabel *brandNameLabel;
@property (nonatomic,strong) UILabel *marketPriceLabel;
@property (nonatomic,strong) UILabel *currentPriceLabel;
@end

@implementation HHInforMatchGoodsCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        
        _picImageView = [[UIImageView alloc] init];
        _picImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_picImageView];
        
        _goodsNameLabel = [[UILabel alloc]init];
        _goodsNameLabel.font = [UIFont systemFontOfSize:12];
        _goodsNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_goodsNameLabel];
        
        _brandNameLabel = [[UILabel alloc]init];
        _brandNameLabel.font = [UIFont systemFontOfSize:11];
        _brandNameLabel.textAlignment = NSTextAlignmentCenter;;
        _brandNameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_brandNameLabel];
        
        _currentPriceLabel = [[UILabel alloc]init];
        _currentPriceLabel.font = [UIFont boldSystemFontOfSize:12];
        _currentPriceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_currentPriceLabel];
        
        _marketPriceLabel = [[UILabel alloc]init];
        _marketPriceLabel.font = [UIFont systemFontOfSize:11];
        _marketPriceLabel.textColor = [UIColor grayColor];
        [self addSubview:_marketPriceLabel];
        
        [self setRect];
    }
    return self;
}

- (void)setRect {
    
    [_picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 69, 10));
    }];
    [_goodsNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_picImageView);
        make.top.equalTo(_picImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(13);
    }];
    [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_picImageView);
        make.top.equalTo(_goodsNameLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(12);
    }];
    [_currentPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.top.equalTo(_brandNameLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(13);
        make.right.equalTo(_picImageView.mas_centerX).offset(-3);
    }];
    [_marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_currentPriceLabel.mas_right).offset(5);
        make.top.bottom.equalTo(_currentPriceLabel);
        make.right.equalTo(self).offset(-5);
    }];
}

- (void)setModel:(RJBaseGoodModel *)model {
    _model = model;
    
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"placeHodler")];
    _goodsNameLabel.text = model.name;
    _brandNameLabel.text = model.brandName;
    
    _currentPriceLabel.text = [NSString stringWithFormat:@"¥ %@",model.effectivePrice];
//    CGSize size = [_currentPriceLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 18) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]} context:nil].size;
//    [_currentPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(size.width+0.5);
//    }];
    
    NSDictionary *attributDic = @{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@",model.marketPrice] attributes:attributDic];
    _marketPriceLabel.attributedText = attribtStr;
}


@end
