//
//  RelationGoodsTableViewCell.h
//  ssrj
//
//  Created by MFD on 16/6/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJGoodDetailModel.h"

@interface RelationGoodsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *RelationGoodsCollectionView;

@property (nonatomic, strong)NSArray *dataArray;

@end



@interface RelationGoodsCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong)RJGoodDetailRelationGoodsModel *model;

@property (weak, nonatomic)IBOutlet UIImageView *relationGoodsImg;

@end