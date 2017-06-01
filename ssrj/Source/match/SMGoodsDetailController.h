//
//  SMGoodsDetailController.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
// 商品详情（中间有个添加物品按钮）

#import "RJBasicViewController.h"

#import "RJBaseGoodModel.h"
@interface SMGoodsDetailController : RJBasicViewController
@property (nonatomic,strong)NSString *goodsId;
@property (nonatomic,strong)RJBaseGoodModel *model;
@end
