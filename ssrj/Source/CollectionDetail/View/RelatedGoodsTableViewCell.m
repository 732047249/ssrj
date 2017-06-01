//
//  RelatedGoodsTableViewCell.m
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RelatedGoodsTableViewCell.h"
#import "GoodsDetailViewController.h"

@interface RelatedGoodsTableViewCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end


@implementation RelatedGoodsTableViewCell

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self.relatedGoodsCollectionView reloadData];
}


//获取当前视图所在控制器
- (UIViewController *)viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/320*160 , SCREEN_WIDTH/320*160+65);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RelatedGoodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelatedGoodCollectionViewCell" forIndexPath:indexPath];
    cell.dataModel = self.dataArray[indexPath.row];
    /**
     *  统计ID
     */
    SingleProductModel *model = self.dataArray[indexPath.row];
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodsId.intValue];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    SingleProductModel *model = self.dataArray[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = model.goodsId;
    goodsDetaiVC.fomeCollectionId = self.fromCollectionId;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = @"CollectionsViewController";
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = _fromCollectionId;
//    statisticalDataModel.entranceTypeId = model.goodsId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.viewController.navigationController pushViewController:goodsDetaiVC animated:YES];
}

@end

#pragma  RelatedGoodsCollectionViewCell
@implementation RelatedGoodCollectionViewCell
- (void)setDataModel:(SingleProductModel *)dataModel{
    [self.relatedGoodsImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.image]];
    self.currentPrice.textColor = [UIColor blackColor];
    self.specialImageView.image = nil;
    
    if (dataModel.isNewProduct.boolValue) {
        self.specialImageView.image = [UIImage imageNamed:@"xinping_left"];
        
    }
    if (dataModel.isSpecialPrice.boolValue) {
        self.specialImageView.image = [UIImage imageNamed:@"tejia_left"];
        self.currentPrice.textColor = [UIColor colorWithHexString:@"#F63649"];

    }
    self.relatedGoodsName.text = dataModel.name;
    self.currentPrice.text =  [NSString stringWithFormat:@"¥%@",dataModel.effectivePrice];
    self.marketPrice.attributedText = [NSString effectivePriceWithString:dataModel.marketPrice.stringValue];
    self.relatedGoodsBrand.text = dataModel.brandName;
    
}

- (void)awakeFromNib{
}

@end