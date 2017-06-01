//
//  RelatedGoodsTableViewCell.h
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendCollectionsModel.h"

@interface RelatedGoodsTableViewCell : UITableViewCell
/**
 *  Add By Can
    点击里面的单品需要知道是从哪个搭配点击进去的
 */
@property (nonatomic,strong) NSNumber * fromCollectionId;
@property (weak, nonatomic) IBOutlet UICollectionView *relatedGoodsCollectionView;

@property (nonatomic,strong) NSArray *dataArray;

@end


@interface RelatedGoodCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *relatedGoodsImageView;
@property (weak, nonatomic) IBOutlet UIButton *relatedGoodsZanBtn;
@property (weak, nonatomic) IBOutlet UIImageView *specialImageView;
@property (weak, nonatomic) IBOutlet UILabel *relatedGoodsName;
@property (weak, nonatomic) IBOutlet UILabel *relatedGoodsBrand;
@property (weak, nonatomic) IBOutlet UILabel *currentPrice;
@property (weak, nonatomic) IBOutlet UILabel *marketPrice;

@property (nonatomic,strong)SingleProductModel *dataModel;

@end
