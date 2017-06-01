//
//  SMStuffDetailModel.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/17.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMStuffDetailModel.h"

@implementation SMStuffDetailModel
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"ID"
                                                       }];
}
@end
