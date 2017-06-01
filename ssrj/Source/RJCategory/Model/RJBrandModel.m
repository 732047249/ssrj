//
//  RJBrandModel.m
//  ssrj
//
//  Created by MFD on 16/6/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBrandModel.h"

@implementation RJBrandModel

@end

@implementation data_Model

@end

@implementation category_data_Model
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"goodsId"}];
}

@end