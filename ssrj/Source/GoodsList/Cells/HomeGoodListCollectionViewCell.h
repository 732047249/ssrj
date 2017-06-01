//
//  HomeGoodListCollectionViewCell.h
//  ssrj
//
//  Created by CC on 16/5/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBaseGoodModel.h"
#import "HHLongPressScrollView.h"
#import "CCButton.h"

//下级页面点赞回调Block
typedef void(^zanBackBlock)(NSInteger);

@protocol HomeGoodListCollectionViewCellDelegate <NSObject>

- (void)tapGsetureWithIndexRow:(NSInteger)tag;
@optional
- (void)longGsetureWithIndexRow:(NSInteger)tag;
@end

@interface HomeGoodListCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (weak, nonatomic) IBOutlet UIImageView *specialImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *markPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *effectivePriceLabel;
@property (strong, nonatomic) RJBaseGoodModel * model;
@property (weak, nonatomic) IBOutlet HHLongPressScrollView*imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *viewOne;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) id<HomeGoodListCollectionViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *zanImageView;
@property (nonatomic, strong) NSString *fatherViewControllerName;

@property (copy, nonatomic) zanBackBlock zanBlock;
- (void)showRightLine;
- (void)hideRightLine;

@end
