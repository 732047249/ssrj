//
//  SMMyGoodsCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMyGoodsCell.h"

#import "Masonry.h"
@interface SMMyGoodsCell ()
@property (nonatomic,strong)UIImageView *picImageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *detailLabel;
@property (nonatomic,strong)UIButton *addBtn;

@end
@implementation SMMyGoodsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _picImageView = [[UIImageView alloc] init];
        _picImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_picImageView];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_nameLabel];
        
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel.textColor = [UIColor grayColor];
        [self addSubview:_detailLabel];
        
        _addBtn = [[UIButton alloc] init];
        [_addBtn setImage:[UIImage imageNamed:@"match_add_mid"] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_addBtn];
        
        [_picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(17, 20, 43, 20));
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.top.equalTo(_picImageView.mas_bottom).offset(5);
            make.right.equalTo(self).offset(-10);
            make.height.mas_equalTo(15);
        }];
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_nameLabel);
            make.top.equalTo(_nameLabel.mas_bottom).offset(5);
            make.height.mas_equalTo(12);
        }];
        
        [_addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(4);
            make.right.equalTo(self).offset(-4);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    return self;
}
- (void)clickAddBtn {
    if (self.clickAddBtnBlock) {
        self.clickAddBtnBlock();
    }
}
- (void)setGoodsModel:(SMGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:goodsModel.image] placeholderImage:[UIImage imageNamed:@"match_placeholder"]];
    _nameLabel.text = goodsModel.name;
    _detailLabel.text = goodsModel.brand_name;
    [self showAllLine];
    
}
- (void)setModel:(RJBaseGoodModel *)model {
    _model = model;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail] placeholderImage:[UIImage imageNamed:@"match_placeholder"]];
    _nameLabel.text = model.name;
    _detailLabel.text = model.brandName;
    [self showAllLine];
    
}
- (void)setStuffModel:(SMStuffDetailModel *)stuffModel {
    _stuffModel = stuffModel;
    
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:stuffModel.src] placeholderImage:[UIImage imageNamed:@"match_placeholder"]];
    _nameLabel.text = stuffModel.title;
    _detailLabel.text = @"";
    [self showAllLine];
}
@end
