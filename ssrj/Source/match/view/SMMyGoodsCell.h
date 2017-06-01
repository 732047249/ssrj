//
//  SMMyGoodsCell.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMGoodsModel.h"
#import "RJBaseGoodModel.h"
#import "SMStuffDetailModel.h"
#import "HHCollectionBorderCell.h"
@interface SMMyGoodsCell : HHCollectionBorderCell
@property (nonatomic,strong) SMGoodsModel *goodsModel;
@property (nonatomic,strong) RJBaseGoodModel *model;
@property (nonatomic,strong) SMStuffDetailModel *stuffModel;
@property (nonatomic,assign) BOOL isFromAllGoods;
@property (nonatomic,strong) void (^clickAddBtnBlock)();
@end
