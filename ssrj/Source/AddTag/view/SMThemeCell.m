//
//  SMThemeCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMThemeCell.h"
#import "Masonry.h"
@interface SMThemeCell()//60 = height
@property (nonatomic,strong)UIImageView *picView;
@property (nonatomic,strong)UILabel *nameLabel;
@property (nonatomic,strong)UILabel *despLabel;
@property (nonatomic,strong)UILabel *pubStateLabel;
@end
@implementation SMThemeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _picView = [[UIImageView alloc]init];
        _picView.contentMode = UIViewContentModeScaleAspectFit;
        _picView.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
        _picView.layer.borderWidth = 1;
        [self addSubview:_picView];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_nameLabel];
        
        _despLabel = [[UILabel alloc]init];
        _despLabel.font = [UIFont systemFontOfSize:11];
        _despLabel.textColor = [UIColor colorWithHexString:@"#898e90"];
        [self addSubview:_despLabel];
        
        _pubStateLabel = [[UILabel alloc] init];
        _pubStateLabel.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
        _pubStateLabel.font = [UIFont systemFontOfSize:12];
        _pubStateLabel.textAlignment = NSTextAlignmentCenter;
        _pubStateLabel.layer.cornerRadius = 3;
        _pubStateLabel.layer.masksToBounds = YES;
        _pubStateLabel.text = @"未发布";
        _pubStateLabel.textColor = [UIColor colorWithHexString:@"#898e90"];
        [self addSubview:_pubStateLabel];
        _pubStateLabel.hidden = YES;
        
        [_picView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(6);
            make.left.equalTo(self).offset(10);
            make.size.mas_equalTo(CGSizeMake(45, 45));
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_picView.mas_right).offset(10);
            make.top.equalTo(_picView).offset(4);
            make.height.mas_equalTo(17);
            make.right.equalTo(self).offset(-100);
        }];
        [_despLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_nameLabel);
            make.top.mas_equalTo(_nameLabel.mas_bottom).offset(1);
            make.height.mas_equalTo(15);
        }];
        [_pubStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(60, 20));
        }];
    }
    return self;
}
- (void)setModel:(SMThemeModel *)model {
    _model = model;
    
    [_picView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"match_placeholder")];
    
    _pubStateLabel.hidden = model.is_publish;
    
    _nameLabel.text = model.title;
    _despLabel.text = model.desp;
}
@end
