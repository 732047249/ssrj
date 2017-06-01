//
//  MoreGoodsCell.m
//  ssrj
//
//  Created by MFD on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MoreGoodsCell.h"

@implementation MoreGoodsCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.brandLogo.layer.borderColor = [UIColor colorWithHexString:@"#afafaf"].CGColor;
    self.brandLogo.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
