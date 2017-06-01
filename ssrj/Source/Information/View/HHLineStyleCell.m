//
//  HHLineStyleCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHLineStyleCell.h"
#import "Masonry.h"
@interface HHLineStyleCell()

@property (nonatomic,strong)UIImageView *lineImageView;
@end
@implementation HHLineStyleCell

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
        _lineImageView = [[UIImageView alloc] init];
        _lineImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_lineImageView];
        [_lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}
- (void)setImageStyle:(HHImageStyle *)imageStyle {
    _imageStyle = imageStyle;
    _lineImageView.image = imageStyle.image;
    [_lineImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_lineImageView.image.size.height);
    }];
}
@end
