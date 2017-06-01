//
//  RelatedGoodsCell.h
//  ssrj
//
//  Created by MFD on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RelatedGoodsCellDelegate <NSObject>

@end

@interface RelatedGoodsCell : UITableViewCell


@property (nonatomic, strong)NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UICollectionView *relatedGoodsCollectionView;


@end


@interface RelatedGoodsCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak)IBOutlet UIImageView * goodsImage;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabe;
@property (weak, nonatomic) IBOutlet UILabel *goodsBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabe;

@property (weak, nonatomic) IBOutlet UILabel *marketPriceLabel;

@end