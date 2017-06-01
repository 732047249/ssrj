//
//  GoodsDetailViewController.h
//  ssrj
//
//  Created by MFD on 16/5/31.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
typedef void(^zanBackBlock)(NSInteger);


@interface GoodsDetailViewController : RJBasicViewController


@property (nonatomic,strong)NSNumber *goodsId;


@property (nonatomic, assign)BOOL hasClickZanBtn;


@property (nonatomic,copy)zanBackBlock zanBlock;
@property (nonatomic,strong) NSNumber * fomeCollectionId;

@end


/**
 *  颜色button
 */
@interface RJGoodDetailColorButton : CCButton
- (void)showSelected;
- (void)showNormal;
@end
