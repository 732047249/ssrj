//
//  HHMenuPullButton.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHMenuPullButton.h"
#import "Masonry.h"
@interface HHMenuPullButton()
@property (nonatomic,strong)UIImageView *picView;
@end

@implementation HHMenuPullButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        
        _picView = [[UIImageView alloc] init];
        _picView.contentMode = UIViewContentModeCenter;
        [self addSubview:_picView];
        
    }
    return self;
}
- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    
    _picView.image = GetImage(imageName);
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_picView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(14, 9));
        make.centerY.equalTo(self);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_picView.mas_left).offset(-5);
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(15);
    }];
}
- (void)selectedNone {
    self.nameLabel.text = @"选择专题";
    self.nameLabel.textColor = [UIColor colorWithHexString:@"#e5e5e5"];
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    self.imageName = @"infor_down_0";
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
    self.layer.borderWidth = 1;
    CGRect rect = self.frame;
    CGSize size = [self.nameLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 100, rect.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    rect.size.width = size.width + 56;
    self.frame = rect;
    [self setNeedsLayout];
}
- (void)selectedSpecialTopic:(NSString *)name {
    self.backgroundColor = [UIColor colorWithHexString:@"#bcbcbc"];
    self.imageName = @"infor_down_1";
    self.nameLabel.text = name;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.layer.borderWidth = 0;
    CGRect rect = self.frame;
    CGSize size = [name boundingRectWithSize:CGSizeMake(kScreenWidth - 100, rect.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    rect.size.width = size.width + 56;
    self.frame = rect;
    [self setNeedsLayout];
}
@end
