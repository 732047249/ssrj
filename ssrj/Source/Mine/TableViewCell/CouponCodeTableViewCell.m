//
//  CouponCodeTableViewCell.m
//  ssrj
//
//  Created by MFD on 16/8/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CouponCodeTableViewCell.h"

@implementation CouponCodeTableViewCell

- (void)awakeFromNib {
    
    self.duiHuanBtn.layer.cornerRadius = 4;
    self.duiHuanBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
