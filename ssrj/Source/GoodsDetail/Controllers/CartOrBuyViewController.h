//
//  CartOrBuyViewController.h
//  ssrj
//
//  Created by MFD on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJGoodDetailModel.h"
#import "cartOrBuyModel.h"


@protocol CartOrBuyViewControllerDelegate <NSObject>
//修改了身体尺寸，回调
- (void)reloadGoodsDetailCloseCoverWithisReload:(BOOL)isReload;

@end

@interface CartOrBuyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImage;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *goodsBrandName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerLineHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *preSaleDescription;


@property (weak, nonatomic) IBOutlet UIButton *reduceButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@property (weak, nonatomic) IBOutlet UILabel *recommendLabel;

@property (weak, nonatomic) IBOutlet UIButton *recommentSizeButton;

@property (strong, nonatomic)id<CartOrBuyViewControllerDelegate> delegate;

@property (nonatomic,assign)NSInteger cartOrBuy;
@property (nonatomic,strong)cartOrBuyModel *cartorbuymodel;
@property (nonatomic,strong) NSNumber * fomeCollectionId;
@property (nonatomic, strong)RJGoodDetailModel *datamodel;
//记录加入购物车的单品ID add 12.20
@property (strong, nonatomic) NSNumber *fromGoodsId;
///*
// * 3.0.1
// */
//@property (strong, nonatomic) UIViewController *parentVC;


- (void)getNetData;
- (void)addViewToKeyWindow;
//- (void)removeViewFromKeyWindow;


@end

/**
 *  自定义按钮  用代码写颜色和尺寸按钮 CC
 */

@interface RJCartOrBuyCustomerButton : UIButton
@property (nonatomic,strong) RJGoodDetailProductsModel * model;
- (void)customInit;
- (void)setPreSaleState;
- (void)setNormalSaleState;
@end
