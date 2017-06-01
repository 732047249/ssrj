//
//  RJPayOrderDetailViewController.h
//  ssrj
//
//  Created by CC on 16/6/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "RJPayOrderDetailModel.h"

//add 11.29 代理刷新订单状态
@protocol RJPayOrderDetailViewControllerDelegate <NSObject>
- (void)reloadOrderStateData;
@end

@interface RJPayOrderDetailViewController : RJBasicViewController
@property (strong, nonatomic) NSNumber * orderId;

@property (strong, nonatomic) id<RJPayOrderDetailViewControllerDelegate>delegate;

@end



@interface RJPayOrderDetailAddressCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@end



@interface RJPayOrderDetailOrderIdCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *orderIdLabel;

@end


#pragma -OrderDateCell

@interface RJPayOrderDetailOrderDateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderDateLabel;

@end


@interface RJPayOrderDetailPaySuccessCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;

@end


@interface RJPayOrderDetailPayFailureCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *payButton;

@end

@interface RJPayOrderDetailGoodCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *markPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *shouHouButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeftWithImageViewConstrant;

@property (strong, nonatomic) PayOrderDeatailItemModel * model;

@property (weak, nonatomic) IBOutlet UILabel *preSaleDescLabel;

@end