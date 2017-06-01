//
//  MFDMineOrdersTableViewCell.h
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "myOrderCellModel.h"


@interface MFDMineOrdersTableViewCell : UITableViewCell
@property (nonatomic,strong)myOrderCellModel *model;

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UILabel *checkOrderLabel;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineHeightconstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end


@interface MFDMineOrdersCollectionViewCell : UICollectionViewCell
@property (nonatomic,weak)IBOutlet UIImageView *imageView;
@end