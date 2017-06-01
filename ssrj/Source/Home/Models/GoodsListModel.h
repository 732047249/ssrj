//
//  GoodsListModel.h
//  ssrj
//
//  Created by CC on 16/5/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RJBaseGoodModel.h"
@interface GoodsListModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> * start;
@property (strong, nonatomic) NSNumber<Optional> * isExist;
@property (copy, nonatomic) NSArray<RJBaseGoodModel,Optional> *data;
@property (strong, nonatomic) NSNumber * state;
@property (strong, nonatomic) NSString * msg;
@property (strong, nonatomic) NSString<Optional> * categoryImg2;
@property (strong, nonatomic) NSString<Optional> * categoryImg1;
@property (strong, nonatomic) NSString<Optional> * brandImg2;

/**
 *  忽略以下参数 只有在穿衣助手推荐地方才用到
 */
@property (strong, nonatomic) NSNumber<Optional> * goodsTotal;
@property (strong, nonatomic) NSNumber<Optional> * collocationTotal;

@end
