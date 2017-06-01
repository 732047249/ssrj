//
//  HomePageFourCell.h
//  ssrj
//
//  Created by CC on 16/5/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJHomeItemTypeZeroModel.h"
#import "HHLongPressedImageView.h"
@protocol HomePageFourCellDelegate <NSObject>
- (void)bigImageTapedWithDic:(NSDictionary *)dic;
- (void)bigImageBrandTapedWithDic:(NSDictionary *)dic brandId:(NSNumber *)brandid;
- (void)collectionTapedWithGoodId:(NSString *)goodId;
@end

@interface HomePageFourCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bigImageBgView;
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (copy, nonatomic) NSArray * goodsArray;
@property (strong, nonatomic) RJHomeItemTypeZeroModel * model;
@property (assign, nonatomic) id<HomePageFourCellDelegate> delegate;
@property (nonatomic,strong) NSString *fatherViewClassName;
@end




@interface HomeFourCollectionCell : UICollectionViewCell
@property (assign, nonatomic) IBOutlet HHLongPressedImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *marketPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (strong, nonatomic) RJBaseGoodModel * model;
@end


@interface HomeFourCollectionFooterView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end

