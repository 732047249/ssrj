//
//  CheckOrderViewController.h
//  ssrj
//
//  Created by CC on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "RJCheckOrderModel.h"
@interface AddressView : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@interface CheckOrderViewController : RJBasicViewController
@property (strong, nonatomic) RJCheckOrderModel * model;
@end


@interface CheckOrderHBTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *subPriceLabel;

@end


@interface CheckOrderTotalPriceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *savePriceLabel;
@end



@interface CheckOrderKuaiDiCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *choseIamge;

@end

@interface CheckOrderBalanceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *blacePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totoalPriceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *choseImage;

@end


@interface CheckOrderPayTitleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@end

@interface CheckOrderPayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *payImageView;

@property (weak, nonatomic) IBOutlet UILabel *payTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *chooseImage;

@end




@interface CheckOrderYouFeiCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ruleDescriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end



@interface CheckOrderJiFenCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *choseImage;
@property (strong, nonatomic) IBOutlet UILabel *jiFenLabel;
@end
