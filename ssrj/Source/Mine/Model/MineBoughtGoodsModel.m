//
//  MineBoughtGoodsModel.m
//  ssrj
//
//  Created by YiDarren on 16/8/6.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MineBoughtGoodsModel.h"

@implementation MineBoughtGoodsModel

+ (JSONKeyMapper *)keyMapper{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"MineBoughtGoodsId"}];
}

@end
