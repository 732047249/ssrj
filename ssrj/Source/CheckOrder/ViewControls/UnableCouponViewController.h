//
//  UnableCouponViewController.h
//  ssrj
//
//  Created by CC on 16/6/15.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "YYLabel.h"

@interface UnableCouponViewController : RJBasicViewController
@property (strong, nonatomic) NSString * cartItemIds;

@end



@interface UnableCouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel * moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet YYLabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *desLabelYConstriant;
@property (weak, nonatomic) IBOutlet UIButton *useRuleButton;
@end