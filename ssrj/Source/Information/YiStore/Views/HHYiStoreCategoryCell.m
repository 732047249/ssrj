//
//  HHYiStoreCategoryCell.m
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHYiStoreCategoryCell.h"
#import "Masonry.h"

@interface HHYiStoreCategoryCell ()

@property (nonatomic,strong)UIImageView *picImageView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *detailLabel;
@property (nonatomic, strong) UIButton *chooseButton;
@end

@implementation HHYiStoreCategoryCell

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
        
        _chooseButton = [[UIButton alloc] init];
        [_chooseButton setImage:GetImage(@"gouxuan_none") forState:UIControlStateNormal];
        [_chooseButton setImage:GetImage(@"gouxuan") forState:UIControlStateSelected];
        [_chooseButton addTarget:self action:@selector(chooseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_chooseButton];
        
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
        [_chooseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(4);
            make.right.equalTo(self).offset(-4);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
    return self;
}
- (void)setModel:(RJBaseGoodModel *)model {
    _model = model;
    [_picImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail] placeholderImage:[UIImage imageNamed:@"match_placeholder"]];
    _nameLabel.text = model.name;
    _detailLabel.text = model.brandName;
    _chooseButton.selected = [model.selected boolValue];
    [self showAllLine];
    
}
- (void)chooseBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.chooseBlock) {
        self.chooseBlock(sender.selected);
    }
}
@end
