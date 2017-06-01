//
//  RelationGoodsTableViewCell.m
//  ssrj
//
//  Created by MFD on 16/6/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RelationGoodsTableViewCell.h"
#import "GoodsDetailViewController.h"

@interface RelationGoodsTableViewCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

- (UIViewController *)viewController;

@end


@implementation RelationGoodsTableViewCell
//获取当前view所在的控制器
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

    // Configure the view for the selected state
}


#pragma -collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(80, 100);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RelationGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RelationGoodsCollectionViewCell" forIndexPath:indexPath];
    RJGoodDetailRelationGoodsModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.relationGoodsId.intValue];
    
    cell.model = model;
    return  cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    RJGoodDetailRelationGoodsModel *model = self.dataArray[indexPath.row];
    goodsDetaiVC.goodsId = model.relationGoodsId;
    [self.viewController.navigationController pushViewController:goodsDetaiVC animated:YES];
    
}

@end



@implementation RelationGoodsCollectionViewCell
- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setModel:(RJGoodDetailRelationGoodsModel *)model{
    if (model.thumbnail) {
        [self.relationGoodsImg sd_setImageWithURL:[NSURL URLWithString:model.thumbnail]];
    }
}
@end
