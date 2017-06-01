//
//  CouponCellTableViewCell.h
//  ssrj
//
//  Created by YiDarren on 16/6/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYLabel.h"

@interface CouponCellTableViewCell : UITableViewCell

// for Xib
//优惠券种类imageView
@property (weak, nonatomic) IBOutlet UIImageView *couponImageView;
//优惠券金额Label
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
//优惠券使用方式说明Label
@property (weak, nonatomic) IBOutlet YYLabel *howToUseLabel;
//优惠券有效期Label
@property (weak, nonatomic) IBOutlet UILabel *deadLineLabel;

@property (weak, nonatomic) IBOutlet UIImageView *couponStateImageView;

@property (weak, nonatomic) IBOutlet UIButton *topButton;

@property (weak, nonatomic) IBOutlet UIButton *useRuleButton;

@property (strong, nonatomic) UILabel *useRuleLabel;

@end
