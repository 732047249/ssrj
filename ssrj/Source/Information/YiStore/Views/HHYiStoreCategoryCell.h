//
//  HHYiStoreCategoryCell.h
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHCollectionBorderCell.h"
#import "RJBaseGoodModel.h"

@interface HHYiStoreCategoryCell : HHCollectionBorderCell
@property (nonatomic, strong) RJBaseGoodModel *model;
@property (nonatomic, copy) void (^chooseBlock)(NSInteger);
@end
