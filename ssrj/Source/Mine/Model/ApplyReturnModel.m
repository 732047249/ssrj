//
//  ApplyReturnModel.m
//  ssrj
//  申请退换货文案模型，用于显示售后服务条目
//  Created by YiDarren on 16/12/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ApplyReturnModel.h"

@implementation ApplyReturnModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"serviceId"}];
}

@end


@implementation ApplyReasonModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"reasonId"}];
}

@end