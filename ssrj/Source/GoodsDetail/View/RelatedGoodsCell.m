//
//  RelatedGoodsCell.m
//  ssrj
//
//  Created by MFD on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RelatedGoodsCell.h"
#import "RJGoodDetailModel.h"
#import "GoodsDetailViewController.h"

@interface RelatedGoodsCell ()<UICollectionViewDataSource,UICollectionViewDelegate>

@end
@implementation RelatedGoodsCell

- (void)awakeFromNib{
    [super awakeFromNib];

}

- (UIViewController *)viewController{
    for (UIView *next = [self superview]; next; next = [next superview]) {
        UIResponder *responder = [next nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (NSArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RelatedGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelatedGoodsCollectionViewCell" forIndexPath:indexPath];
    RJGoodDetailRelationGoodsModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.relationGoodsId.intValue];

    
    [cell.goodsImage sd_setImageWithURL:[NSURL URLWithString:model.maxImage] placeholderImage:nil];
    cell.goodsNameLabe.text = model.name;
    cell.goodsBrandLabel.text = model.brandName;
    
    cell.currentPriceLabe.text = [NSString stringWithFormat:@"¥ %@",model.price];
    
    cell.currentPriceLabe.textColor = [UIColor blackColor];
    if (model.isSpecialPrice.boolValue) {
        cell.currentPriceLabe.textColor = [UIColor colorWithHexString:@"#F63649"];

    }
    
    NSDictionary *attributDic = @{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@",model.marketPrice]
 attributes:attributDic];
    cell.marketPriceLabel.attributedText = attribtStr;
    return  cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/320*118 +5 +5, SCREEN_WIDTH/320*118 +55 +22);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    RJGoodDetailRelationGoodsModel *model = self.dataArray[indexPath.row];
    goodsDetaiVC.goodsId = model.relationGoodsId;
    [self.viewController.navigationController pushViewController:goodsDetaiVC animated:YES];
}

-(void)prepareForReuse{
    [super prepareForReuse];
}

@end


#pragma mark --RelatedGoodsCollectionViewCell
@implementation RelatedGoodsCollectionViewCell
- (void)awakeFromNib{
    [super awakeFromNib];
}


@end