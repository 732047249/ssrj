//
//  MineFavoriteGoodsListCollectionViewCell.h
//  ssrj
//
//  Created by YiDarren on 16/8/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineBoughtGoodsModel.h"
#import "HHLongPressScrollView.h"
#import "CCButton.h"

/**
 *  我的单品－－赞过的单品 cell
 */

@protocol MineFavoriteGoodsListCollectionViewCellDelegate <NSObject>

- (void)tapGsetureWithIndexRow:(NSInteger)tag;
@end

@interface MineFavoriteGoodsListCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (weak, nonatomic) IBOutlet UIImageView *specialImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *markPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *effectivePriceLabel;
@property (weak, nonatomic) IBOutlet HHLongPressScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *zanImageView;

@property (weak, nonatomic) id<MineFavoriteGoodsListCollectionViewCellDelegate> delegate;
@property (strong, nonatomic) MineBoughtGoodsModel * model;


- (void)showRightLine;
- (void)hideRightLine;

@end
