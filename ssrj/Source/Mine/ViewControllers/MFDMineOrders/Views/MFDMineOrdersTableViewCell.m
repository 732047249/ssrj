//
//  MFDMineOrdersTableViewCell.m
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDMineOrdersTableViewCell.h"
#import "RJPayOrderDetailViewController.h"


@interface MFDMineOrdersTableViewCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;//改为订单号了 dataLabel.text = model.sn
//@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCount;
@property (weak, nonatomic) IBOutlet UILabel *allPrice;

@end

@implementation MFDMineOrdersTableViewCell
/**
 *  逻辑下版本重构！！！ 描述由后台返回！
 */

-(void)setModel:(myOrderCellModel *)model{
    
    _model = model;
    
    
    self.checkOrderLabel.layer.cornerRadius = 3.0;
    self.checkOrderLabel.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
    self.checkOrderLabel.layer.borderWidth = 0.35;
    
    self.btnRight.backgroundColor = [UIColor clearColor];
    [self.btnRight setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

    //改为订单号了 dataLabel.text = model.sn
    self.dataLabel.text = model.sn;
    self.dataLabel.textColor = [UIColor lightGrayColor];
    
    if ([model.status isEqualToString:@"pendingPayment"]) {
        
        if (model.hasExpired.intValue == 1) {
            
            self.stateLabel.text = @"已过期";
            
        } else if (model.hasExpired.intValue == 0 && ![model.type isEqualToString:@"swap"]) {
            
            self.stateLabel.text = @"待付款";
            self.btnRight.backgroundColor = [UIColor colorWithHexString:@"#5d32b5"];
            [self.btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [self.btnLeft setHidden:NO];
            [self.btnRight setHidden:NO];
            
            self.btnLeft.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
            self.btnLeft.layer.borderWidth = 0.35;
            self.btnLeft.layer.cornerRadius = 3.0;
            self.btnLeft.layer.masksToBounds = YES;
            
            self.btnRight.layer.borderColor = [UIColor colorWithHexString:@"#5d32b5"].CGColor;
            self.btnRight.layer.borderWidth = 0.35;
            self.btnRight.layer.cornerRadius = 3.0;
            self.btnRight.layer.masksToBounds = YES;
        }
        
    }
    else if ([model.status isEqualToString:@"shipped"]) {
        self.stateLabel.text = @"已发货";//原“待收货”状态
        
        [self.btnLeft setHidden:NO];
        [self.btnRight setHidden:NO];
        self.btnLeft.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
        self.btnLeft.layer.borderWidth = 0.35;
        self.btnLeft.layer.cornerRadius = 3.0;
        self.btnLeft.layer.masksToBounds = YES;
        self.btnRight.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
        self.btnRight.layer.borderWidth = 0.35;
        self.btnRight.layer.cornerRadius = 3.0;
        self.btnRight.layer.masksToBounds = YES;
        
    }
    else if ([model.status isEqualToString:@"received"] || [model.status isEqualToString:@"completed"]) {
        self.stateLabel.text = @"已完成";
        /*
         * v3.1.0
         */
        [self.btnRight setHidden:NO];
        self.btnRight.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
        self.btnRight.layer.borderWidth = 0.35;
        self.btnRight.layer.cornerRadius = 3.0;
        self.btnRight.layer.masksToBounds = YES;
    }
    
    // 已付款
    else if (([model.status isEqualToString:@"pendingReview"] || [model.status isEqualToString:@"pendingShipment"]) && ![model.type isEqualToString:@"swap"]) {
        self.stateLabel.text = @"等待发货";
        
        [self.btnRight setHidden:NO];
        self.btnRight.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
        self.btnRight.layer.borderWidth = 0.35;
        self.btnRight.layer.cornerRadius = 3.0;
        self.btnRight.layer.masksToBounds = YES;
        
    }
    
    // 已付款
    else if (([model.status isEqualToString:@"pendingReview"] || [model.status isEqualToString:@"pendingShipment"]) && [model.type isEqualToString:@"swap"]) {
        self.stateLabel.text = @"等待发货";
        
    }
    
    // 已失败
    else if ([model.status isEqualToString:@"failed"]) {
        self.stateLabel.text = @"已失败";
    }
    // 已取消
    else if ([model.status isEqualToString:@"canceled"]) {
        self.stateLabel.text = @"已取消";
    }
    // 已拒绝
    else if ([model.status isEqualToString:@"denied"]) {
        self.stateLabel.text = @"已拒绝";
    }
#warning 新增订单状态
    //add 11.17 v2.2.0新增状态
    else if ([model.status isEqualToString:@"refundsed"]) {
        self.stateLabel.text = @"已退款";
    }
    else if ([model.status isEqualToString:@"returnsed"]) {
        self.stateLabel.text = @"已退换货";
    }
    else if ([model.status isEqualToString:@"refundsing"]) {
        self.stateLabel.text = @"退款中";
    }
    else if ([model.status isEqualToString:@"returnsing"]) {
        self.stateLabel.text = @"退换货中";
        [self.btnRight setHidden:YES];
    }
    else if([model.status isEqualToString:@"paymentProcessing"]){
        self.stateLabel.text = @"支付处理中";

    }
    
    else if ([model.status isEqualToString:@"cancelPendingReview"]) {
        self.stateLabel.text = @"等待审核";
        
        [self.btnRight setHidden:NO];
        self.btnRight.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
        self.btnRight.layer.borderWidth = 0.35;
        self.btnRight.layer.cornerRadius = 3.0;
        self.btnRight.layer.masksToBounds = YES;

    }
#warning 新增未出现过的字段，在返回数据中出现    add 11.26
    else if ([model.status isEqualToString:@"returnsReview"]) {
        
        self.stateLabel.text = @"退换货审核";
    }
    
    else {
        
        [self.btnLeft setHidden:YES];
        [self.btnRight setHidden:YES];
        [self.btnLeft setTitle:@"" forState:UIControlStateNormal];
        [self.btnRight setTitle:@"" forState:UIControlStateNormal];
    }
    
    self.stateLabel.textColor = UIColorFromHex(@"#5d32b5");
    
    self.totalCount.text = [NSString stringWithFormat:@"共%@件商品", [model.quantity stringValue]];
    self.allPrice.text = [NSString stringWithFormat:@"合计 ¥%@",model.amount];
    [self.collectionView reloadData];
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.btnLeft setHidden:YES];
    [self.btnRight setHidden:YES];
    
    [self.btnLeft setTitle:@"" forState:UIControlStateNormal];
    [self.btnRight setTitle:@"" forState:UIControlStateNormal];
    
    self.stateLabel.text = @"";

    [self.btnLeft removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self.btnRight removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
}



- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.btnLeft setHidden:YES];
    [self.btnRight setHidden:YES];
    self.btnLeft.titleLabel.text = @"";
    self.btnRight.titleLabel.text = @"";
    self.stateLabel.text = @"";
    
    self.topLineHeightconstraints.constant = 0.7;
    self.middleLineHeightConstraint.constant = 0.7;
    self.bottomLineHeightConstraint.constant = 0.7;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.model.orderItemList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake((SCREEN_WIDTH-2*8-5*3)/4, (SCREEN_WIDTH-2*8-5*3)/4);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MFDMineOrdersCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MFDMineOrdersCollectionViewCell" forIndexPath:indexPath];
    OrderItemListModel *model = self.model.orderItemList[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.itemId.intValue];

    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = UIColorFromHex(@"#EFEFF4").CGColor;

    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end


@implementation MFDMineOrdersCollectionViewCell
- (void)awakeFromNib{
    [super awakeFromNib];
}
@end