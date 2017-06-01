//
//  SMGoodsDetailHeader.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMGoodsDetailHeader.h"
#import "UIButton+ImageTitleSpacing.h"
#import "Masonry.h"
@interface SMGoodsDetailHeader()
@property (nonatomic,strong)UILabel *goodsNameLabel;
@property (nonatomic,strong)UILabel *brandNameLabel;
@property (nonatomic,strong)UILabel *marketPriceLabel;
@property (nonatomic,strong)UILabel *currentPriceLabel;
@property (nonatomic,strong)UILabel *discountLabel;//打折
@property (nonatomic,strong)UILabel *specialPriceLabel;//特价
@property (nonatomic,strong)UILabel *manJianLabel;//特价
@end
@implementation SMGoodsDetailHeader


//screenWidth + 20 + addBtnWidth(80) + 10 + 1 + 20 + 18 + 8 + 15 + 8 + 18 + 20 + 1

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _goodsDetailScrollView = [[SMGoodsDetailScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
        [self addSubview:_goodsDetailScrollView];
        
        _addGoodsButton = [[UIButton alloc]init];
        [_addGoodsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:_addGoodsButton];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = GetImage(@"match_add");
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_addGoodsButton addSubview:imageView];
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.text = @"添加物品";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_addGoodsButton addSubview:titleLabel];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_addGoodsButton);
            make.top.equalTo(_addGoodsButton);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_addGoodsButton);
            make.bottom.equalTo(_addGoodsButton).offset(-10);
            make.height.mas_equalTo(20);
        }];
        
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
        [self addSubview:line];
        
        _goodsNameLabel = [[UILabel alloc]init];
        _goodsNameLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:_goodsNameLabel];
        
        
        _brandNameLabel = [[UILabel alloc]init];
        _brandNameLabel.font = [UIFont systemFontOfSize:14];
        _brandNameLabel.textColor = [UIColor grayColor];
        [self addSubview:_brandNameLabel];
        
        _currentPriceLabel = [[UILabel alloc]init];
        _currentPriceLabel.font = [UIFont boldSystemFontOfSize:17];
        [self addSubview:_currentPriceLabel];
        
        _marketPriceLabel = [[UILabel alloc]init];
        _marketPriceLabel.font = [UIFont systemFontOfSize:12];
        _marketPriceLabel.textColor = [UIColor grayColor];
        [self addSubview:_marketPriceLabel];
        
        
        _discountLabel = [[UILabel alloc]init];
        _discountLabel.font = [UIFont systemFontOfSize:14];
        _discountLabel.backgroundColor = [UIColor colorWithHexString:@"#270b42"];
        _discountLabel.layer.cornerRadius = 3;
        _discountLabel.layer.masksToBounds = YES;
        _discountLabel.textColor = [UIColor whiteColor];
        _discountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_discountLabel];
        
        _specialPriceLabel = [[UILabel alloc]init];
        _specialPriceLabel.font = [UIFont systemFontOfSize:14];
        _specialPriceLabel.backgroundColor = [UIColor colorWithHexString:@"#fb4b4a"];
        _specialPriceLabel.layer.cornerRadius = 3;
        _specialPriceLabel.layer.masksToBounds = YES;
        _specialPriceLabel.textColor = [UIColor whiteColor];
        _specialPriceLabel.textAlignment = NSTextAlignmentCenter;
        _specialPriceLabel.text = @"特价";
        [self addSubview:_specialPriceLabel];
        
        _manJianLabel = [[UILabel alloc]init];
        _manJianLabel.font = [UIFont systemFontOfSize:14];
        _manJianLabel.backgroundColor = [UIColor colorWithHexString:@"#5f31b5"];
        _manJianLabel.textColor = [UIColor whiteColor];
        [self addSubview:_manJianLabel];
        
        _starButton = [[UIButton alloc]init];
        [_starButton setImage:GetImage(@"zan_icon") forState:UIControlStateNormal];
        [_starButton setImage:GetImage(@"zan_icon_select") forState:UIControlStateSelected];
        [_starButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_starButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
        [self addSubview:_starButton];
        
        UIView *bottomLine = [[UIView alloc]init];
        bottomLine.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
        [self addSubview:bottomLine];
        
        [_goodsDetailScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.equalTo(self.mas_width);
        }];
        [_addGoodsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(_goodsDetailScrollView.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(90, 90));
        }];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_addGoodsButton.mas_bottom).offset(10);
            make.left.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.height.mas_equalTo(1);
        }];
        [_goodsNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(line.mas_bottom).offset(15);
            make.right.equalTo(self).offset(100);
            make.height.mas_equalTo(18);
        }];
        [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_goodsNameLabel);
            make.top.equalTo(_goodsNameLabel.mas_bottom).offset(8);
            make.height.mas_equalTo(15);
        }];
        [_currentPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_brandNameLabel.mas_left);
            make.top.equalTo(_brandNameLabel.mas_bottom).offset(8);
            make.height.mas_equalTo(18);
        }];
        [_marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_currentPriceLabel.mas_right).offset(5);
            make.bottom.equalTo(_currentPriceLabel);
        }];
        [_discountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_marketPriceLabel.mas_right).offset(10);
            make.bottom.equalTo(_marketPriceLabel);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(16);
        }];
        [_specialPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_discountLabel.mas_right).offset(10);
            make.bottom.equalTo(_marketPriceLabel);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(16);
        }];
        [_starButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(_goodsNameLabel);
        }];
        
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(line);
            make.top.equalTo(_marketPriceLabel.mas_bottom).offset(20);
            make.height.mas_equalTo(1);
        }];
        
        NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
        _addGoodsButton.trackingId = [NSString stringWithFormat:@"%@&SMGoodsDetailHeader&addGoodsButton",vcName];
        _starButton.trackingId = [NSString stringWithFormat:@"%@&SMGoodsDetailHeader&starButton",vcName];
    }
    return self;
}
- (void)setDataModel:(RJGoodDetailModel *)dataModel {
    _dataModel = dataModel;
    _goodsNameLabel.text = dataModel.name;
    _brandNameLabel.text = dataModel.brandName;
    
    _currentPriceLabel.text = [NSString stringWithFormat:@"¥ %@",dataModel.effectivePrice];
    CGSize size = [_currentPriceLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 18) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]} context:nil].size;
    [_currentPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width+0.5);
    }];
    
    NSDictionary *attributDic = @{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@",dataModel.marketPrice] attributes:attributDic];
    _marketPriceLabel.attributedText = attribtStr;
    CGSize marketWidth = [attribtStr.string boundingRectWithSize:CGSizeMake(MAXFLOAT, 13) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size;
    [_marketPriceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(marketWidth.width+0.5);
    }];
    
    _discountLabel.text = [NSString stringWithFormat:@"%.1f折",[dataModel.discount floatValue]];
    
    [_starButton setTitle:dataModel.thumbsupCount.stringValue forState:UIControlStateNormal];
    if (dataModel.isThumbsup.integerValue == 0) {
        _starButton.selected = NO;
    }else{
        _starButton.selected = YES;
    }
    if (dataModel.isSpecialPrice.intValue) {
        _specialPriceLabel.hidden = NO;
    }else {
        _specialPriceLabel.hidden = YES;
    }
}
@end
