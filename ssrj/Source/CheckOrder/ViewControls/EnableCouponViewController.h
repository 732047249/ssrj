//
//  EnableCouponViewController.h
//  ssrj
//
//  Created by CC on 16/6/15.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "YYLabel.h"
@class RJCouPonModel;

@protocol EnableCouponDelegate <NSObject>

- (void)choseCouponWithModel:(RJCouPonModel *)model;
@end
@interface EnableCouponViewController : RJBasicViewController
@property (assign, nonatomic) id<EnableCouponDelegate> delegate;
@property (strong, nonatomic) NSNumber * selectId;
@property (strong, nonatomic) NSString * cartItemIds;

@end


@interface EnableCouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel * moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageLeftConstriant;
@property (strong, nonatomic) IBOutlet YYLabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *desLabelYConstriant;
@property (weak, nonatomic) IBOutlet UIButton *useRuleButton;

@end