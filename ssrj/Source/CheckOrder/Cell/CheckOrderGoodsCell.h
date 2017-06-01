//
//  CheckOrderGoodsCell.h
//  ssrj
//
//  Created by CC on 16/6/13.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartItemModel.h"
@interface CheckOrderGoodsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *markPriceLabel;
@property (strong, nonatomic) CartItemModel * model;
@property (weak, nonatomic) IBOutlet UILabel *preSaleDescLabel;

@end
