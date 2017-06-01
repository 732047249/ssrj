//
//  HHMyGoodsCell.h
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHCollectionBorderCell.h"
#import "RJBaseGoodModel.h"
@interface HHYiStoreMyGoodsCell : HHCollectionBorderCell
@property (nonatomic, strong) RJBaseGoodModel *goodsModel;
@property (nonatomic, copy) void (^deleteBlcok)(NSString *);
@end
