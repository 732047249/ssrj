//
//  myOrderCellModel.m
//  ssrj
//
//  Created by YiDarren on 16/5/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "myOrderCellModel.h"

@implementation myOrderCellModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"myOrderCellModelId"}];
}
@end


#pragma mark --OrderItemListModel.m
@implementation OrderItemListModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"itemId"}];
}
@end


@implementation memberModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"memberId"}];
}
@end


@implementation MFDMineOrderModel

@end
