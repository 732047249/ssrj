//
//  RecommendedGoodsCollectionViewCell.h
//  ssrj
//
//  Created by MFD on 16/6/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJUserCenteRootViewController.h"
//改变按钮状态回调处理模型的block
#import "RJGoodDetailModel.h"

typedef void (^ChangeStateBlock)(NSNumber *);


@interface RecommendedGoodsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *recommendGoodsImage;
@property (weak, nonatomic) IBOutlet UILabel *recomendName;

@property (weak, nonatomic) IBOutlet UIImageView *authorImg;
@property (weak, nonatomic) IBOutlet UILabel *recommendAuthor;

@property (weak, nonatomic) IBOutlet UIButton *addToThemeBtn;
@property (weak, nonatomic) IBOutlet UIButton *zanBtn;
@property (weak, nonatomic) IBOutlet UIView *sepView;

@property (assign, nonatomic)BOOL hasClickShouCang;
@property (weak, nonatomic) IBOutlet UIButton *shoucangBtn;
@property (weak, nonatomic) IBOutlet UIButton *shoucangMaskBtn;

@property (strong,nonatomic) NSNumber *colloctionId;


@property (copy, nonatomic)ChangeStateBlock changeStateBlock;
@property (weak, nonatomic) id<RJTapedUserViewDelegate> userDelegate ;
@property (strong, nonatomic)  RJGoodDetailRelationCollocationModel *model;
- (IBAction)addToTheme:(id)sender;
- (IBAction)zan:(id)sender;


- (void)showRightLine;
- (void)hideRightLine;

/**
 *  3.0.0
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLineWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;



@end
