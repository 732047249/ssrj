//
//  SMAllGoodsAndSourceModel.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/15.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMAllGoodsAndSourceModel.h"

@implementation SMAllGoodsAndSourceModel
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"ID"
                                                       }];
}
@end
