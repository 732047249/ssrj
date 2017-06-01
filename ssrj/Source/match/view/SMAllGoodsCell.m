//
//  SMAllGoodsCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMAllGoodsCell.h"
#import "Masonry.h"
//60
@implementation SMAllGoodsCell

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
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _picImageView = [[UIImageView alloc] init];
        _picImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_picImageView];
        
        _nameLabel = [[UILabel alloc]init];
        [self addSubview:_nameLabel];
        
        [_picImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self).offset(10);
            make.bottom.equalTo(self).offset(-10);
            make.width.mas_offset(40);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_picImageView.mas_right).offset(20);
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(50);
        }];
    }
    return self;
}
@end
