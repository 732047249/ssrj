//
//  CartTableViewCell.h
//  ssrj
//
//  Created by CC on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartItemModel.h"
@interface CartTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UIButton *choceButton;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (strong, nonatomic) CartItemModel * model;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIButton *subtractButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *editCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *preSaleLabel;
@property (weak, nonatomic) IBOutlet UILabel *preSaleDesLabel;

@end



@interface CartSoldOutTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UIButton *choceButton;
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodPriceLabel;
@property (strong, nonatomic) CartItemModel * model;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeftWithImageViewConstrant;

@property (weak, nonatomic) IBOutlet UIView *editView;

@end